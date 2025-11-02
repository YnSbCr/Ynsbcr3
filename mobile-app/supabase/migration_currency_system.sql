-- ?oklu Para Birimi ve D?viz Kuru Sistemi - Migration
-- Bu dosyay? migration_portfolio_assets.sql'den SONRA ?al??t?r?n

-- Exchange Rates Tablosu (Tarihsel d?viz kurlar?)
CREATE TABLE IF NOT EXISTS public.exchange_rates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  base_currency TEXT NOT NULL DEFAULT 'TRY',
  quote_currency TEXT NOT NULL CHECK (quote_currency IN ('USD', 'EUR', 'GBP', 'JPY')),
  rate DECIMAL(15, 6) NOT NULL,
  rate_date DATE NOT NULL,
  source TEXT NOT NULL DEFAULT 'TCMB' CHECK (source IN ('TCMB', 'API', 'manual')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(base_currency, quote_currency, rate_date)
);

-- Transactions tablosuna ?oklu para birimi deste?i ekle
ALTER TABLE public.transactions
  ADD COLUMN IF NOT EXISTS transaction_currency TEXT DEFAULT 'TRY' CHECK (transaction_currency IN ('TRY', 'USD', 'EUR')),
  ADD COLUMN IF NOT EXISTS exchange_rate_usd DECIMAL(15, 6),
  ADD COLUMN IF NOT EXISTS exchange_rate_eur DECIMAL(15, 6),
  ADD COLUMN IF NOT EXISTS exchange_rate_date DATE;

-- Portfolio Items tablosuna ?oklu para birimi deste?i ekle
ALTER TABLE public.portfolio_items
  ADD COLUMN IF NOT EXISTS base_currency TEXT DEFAULT 'TRY' CHECK (base_currency IN ('TRY', 'USD', 'EUR')),
  ADD COLUMN IF NOT EXISTS average_exchange_rate_usd DECIMAL(15, 6),
  ADD COLUMN IF NOT EXISTS average_exchange_rate_eur DECIMAL(15, 6);

-- BES Transactions tablosuna ?oklu para birimi deste?i ekle
ALTER TABLE public.bes_transactions
  ADD COLUMN IF NOT EXISTS transaction_currency TEXT DEFAULT 'TRY' CHECK (transaction_currency IN ('TRY', 'USD', 'EUR')),
  ADD COLUMN IF NOT EXISTS exchange_rate_usd DECIMAL(15, 6),
  ADD COLUMN IF NOT EXISTS exchange_rate_eur DECIMAL(15, 6),
  ADD COLUMN IF NOT EXISTS exchange_rate_date DATE;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_exchange_rates_date ON public.exchange_rates(rate_date);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_currencies ON public.exchange_rates(base_currency, quote_currency);
CREATE INDEX IF NOT EXISTS idx_transactions_exchange_date ON public.transactions(exchange_rate_date);
CREATE INDEX IF NOT EXISTS idx_transactions_currency ON public.transactions(transaction_currency);

-- RLS Policies
ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;

-- Exchange Rates: Public read for authenticated users (kurlar herkese a??k)
CREATE POLICY "Authenticated users can view exchange rates" ON public.exchange_rates
  FOR SELECT USING (auth.role() = 'authenticated');

-- Function: Belirli bir tarih i?in kur getir (en yak?n tarihli kur)
CREATE OR REPLACE FUNCTION get_exchange_rate(
  p_base_currency TEXT,
  p_quote_currency TEXT,
  p_rate_date DATE
)
RETURNS DECIMAL(15, 6) AS $$
DECLARE
  v_rate DECIMAL(15, 6);
BEGIN
  SELECT rate INTO v_rate
  FROM public.exchange_rates
  WHERE base_currency = p_base_currency
    AND quote_currency = p_quote_currency
    AND rate_date <= p_rate_date
  ORDER BY rate_date DESC
  LIMIT 1;
  
  RETURN COALESCE(v_rate, 1.0); -- E?er kur bulunamazsa 1.0 d?nd?r
END;
$$ LANGUAGE plpgsql;

-- Function: G?ncel kur getir
CREATE OR REPLACE FUNCTION get_current_exchange_rate(
  p_base_currency TEXT,
  p_quote_currency TEXT
)
RETURNS DECIMAL(15, 6) AS $$
DECLARE
  v_rate DECIMAL(15, 6);
BEGIN
  SELECT rate INTO v_rate
  FROM public.exchange_rates
  WHERE base_currency = p_base_currency
    AND quote_currency = p_quote_currency
  ORDER BY rate_date DESC
  LIMIT 1;
  
  RETURN COALESCE(v_rate, 1.0);
END;
$$ LANGUAGE plpgsql;

-- Function: Transaction olu?turulurken otomatik kur ?ekme
CREATE OR REPLACE FUNCTION set_transaction_exchange_rates()
RETURNS TRIGGER AS $$
BEGIN
  -- E?er exchange_rate_date yoksa, transaction_date'i kullan
  IF NEW.exchange_rate_date IS NULL THEN
    NEW.exchange_rate_date := DATE(NEW.transaction_date);
  END IF;
  
  -- E?er kurlar girilmemi?se, otomatik ?ek
  IF NEW.exchange_rate_usd IS NULL THEN
    NEW.exchange_rate_usd := get_exchange_rate('TRY', 'USD', NEW.exchange_rate_date);
  END IF;
  
  IF NEW.exchange_rate_eur IS NULL THEN
    NEW.exchange_rate_eur := get_exchange_rate('TRY', 'EUR', NEW.exchange_rate_date);
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Transaction olu?turulurken otomatik kur atama
DROP TRIGGER IF EXISTS trigger_set_transaction_exchange_rates ON public.transactions;
CREATE TRIGGER trigger_set_transaction_exchange_rates
  BEFORE INSERT OR UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION set_transaction_exchange_rates();

-- Function: Portfolio item i?in ortalama kur hesaplama
CREATE OR REPLACE FUNCTION update_portfolio_item_exchange_rates()
RETURNS TRIGGER AS $$
DECLARE
  v_portfolio_id UUID;
  v_security_id UUID;
  v_avg_usd DECIMAL(15, 6);
  v_avg_eur DECIMAL(15, 6);
BEGIN
  -- Portfolio ID ve Security ID'yi al
  SELECT portfolio_id, security_id INTO v_portfolio_id, v_security_id
  FROM public.portfolio_items
  WHERE id IN (
    SELECT portfolio_item_id FROM public.transactions WHERE id = NEW.id
    UNION
    SELECT id FROM public.portfolio_items WHERE id = NEW.id
  )
  LIMIT 1;
  
  -- E?er portfolio_id ve security_id bulunamazsa, transaction'dan al
  IF v_portfolio_id IS NULL THEN
    v_portfolio_id := NEW.portfolio_id;
    v_security_id := NEW.security_id;
  END IF;
  
  -- Bu portfolio item i?in t?m transaction'lar?n ortalama kurunu hesapla
  SELECT 
    AVG(exchange_rate_usd),
    AVG(exchange_rate_eur)
  INTO v_avg_usd, v_avg_eur
  FROM public.transactions
  WHERE portfolio_id = v_portfolio_id
    AND security_id = v_security_id
    AND type = 'buy'
    AND exchange_rate_usd IS NOT NULL
    AND exchange_rate_eur IS NOT NULL;
  
  -- Ortalama kurlar? g?ncelle
  UPDATE public.portfolio_items
  SET 
    average_exchange_rate_usd = COALESCE(v_avg_usd, average_exchange_rate_usd),
    average_exchange_rate_eur = COALESCE(v_avg_eur, average_exchange_rate_eur)
  WHERE portfolio_id = v_portfolio_id
    AND security_id = v_security_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Transaction sonras? portfolio item kurlar?n? g?ncelle
DROP TRIGGER IF EXISTS trigger_update_portfolio_exchange_rates ON public.transactions;
CREATE TRIGGER trigger_update_portfolio_exchange_rates
  AFTER INSERT OR UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_portfolio_item_exchange_rates();

-- Function: Kar/Zarar hesaplama (TL cinsinden)
CREATE OR REPLACE FUNCTION calculate_profit_loss_tl(
  p_portfolio_item_id UUID,
  p_current_price DECIMAL(15, 4)
)
RETURNS TABLE (
  profit_loss_tl DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2)
) AS $$
DECLARE
  v_average_cost DECIMAL(15, 4);
  v_quantity DECIMAL(15, 4);
BEGIN
  SELECT average_cost, quantity
  INTO v_average_cost, v_quantity
  FROM public.portfolio_items
  WHERE id = p_portfolio_item_id;
  
  RETURN QUERY SELECT
    (p_current_price - v_average_cost) * v_quantity AS profit_loss_tl,
    CASE 
      WHEN v_average_cost > 0 THEN
        ((p_current_price - v_average_cost) / v_average_cost) * 100
      ELSE 0
    END AS profit_loss_percent;
END;
$$ LANGUAGE plpgsql;

-- Function: Kar/Zarar hesaplama (USD cinsinden)
CREATE OR REPLACE FUNCTION calculate_profit_loss_usd(
  p_portfolio_item_id UUID,
  p_current_price DECIMAL(15, 4),
  p_current_usd_rate DECIMAL(15, 6)
)
RETURNS TABLE (
  profit_loss_usd DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2)
) AS $$
DECLARE
  v_average_cost DECIMAL(15, 4);
  v_quantity DECIMAL(15, 4);
  v_avg_usd_rate DECIMAL(15, 6);
  v_cost_usd DECIMAL(15, 4);
  v_value_usd DECIMAL(15, 4);
BEGIN
  SELECT average_cost, quantity, average_exchange_rate_usd
  INTO v_average_cost, v_quantity, v_avg_usd_rate
  FROM public.portfolio_items
  WHERE id = p_portfolio_item_id;
  
  -- Ortalama maliyet USD cinsinden
  v_cost_usd := (v_average_cost * v_quantity) / COALESCE(v_avg_usd_rate, p_current_usd_rate);
  
  -- Mevcut de?er USD cinsinden
  v_value_usd := (p_current_price * v_quantity) / p_current_usd_rate;
  
  RETURN QUERY SELECT
    v_value_usd - v_cost_usd AS profit_loss_usd,
    CASE 
      WHEN v_cost_usd > 0 THEN
        ((v_value_usd - v_cost_usd) / v_cost_usd) * 100
      ELSE 0
    END AS profit_loss_percent;
END;
$$ LANGUAGE plpgsql;

-- Function: Kar/Zarar hesaplama (EUR cinsinden)
CREATE OR REPLACE FUNCTION calculate_profit_loss_eur(
  p_portfolio_item_id UUID,
  p_current_price DECIMAL(15, 4),
  p_current_eur_rate DECIMAL(15, 6)
)
RETURNS TABLE (
  profit_loss_eur DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2)
) AS $$
DECLARE
  v_average_cost DECIMAL(15, 4);
  v_quantity DECIMAL(15, 4);
  v_avg_eur_rate DECIMAL(15, 6);
  v_cost_eur DECIMAL(15, 4);
  v_value_eur DECIMAL(15, 4);
BEGIN
  SELECT average_cost, quantity, average_exchange_rate_eur
  INTO v_average_cost, v_quantity, v_avg_eur_rate
  FROM public.portfolio_items
  WHERE id = p_portfolio_item_id;
  
  -- Ortalama maliyet EUR cinsinden
  v_cost_eur := (v_average_cost * v_quantity) / COALESCE(v_avg_eur_rate, p_current_eur_rate);
  
  -- Mevcut de?er EUR cinsinden
  v_value_eur := (p_current_price * v_quantity) / p_current_eur_rate;
  
  RETURN QUERY SELECT
    v_value_eur - v_cost_eur AS profit_loss_eur,
    CASE 
      WHEN v_cost_eur > 0 THEN
        ((v_value_eur - v_cost_eur) / v_cost_eur) * 100
      ELSE 0
    END AS profit_loss_percent;
END;
$$ LANGUAGE plpgsql;

-- Trigger for exchange_rates updated_at
CREATE TRIGGER update_exchange_rates_updated_at BEFORE UPDATE ON public.exchange_rates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
