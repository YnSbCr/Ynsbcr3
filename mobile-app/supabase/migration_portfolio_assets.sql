-- Finans Takip Uygulamas? - Database Schema G?ncellemeleri
-- Portf?y Mod?l? - Varl?k T?rleri ve BES Entegrasyonu
-- Bu dosyay? mevcut schema.sql'den SONRA ?al??t?r?n

-- Asset Types Enum
CREATE TYPE asset_type AS ENUM (
  'bist_stock',      -- BIST hisseleri
  'us_stock',        -- ABD hisseleri
  'etf',             -- ETF'ler
  'mutual_fund',     -- T?rk Yat?r?m Fonlar?
  'gold_24k',        -- 24 Ayar Alt?n
  'gold_22k',        -- 22 Ayar Alt?n
  'gold_quarter_old', -- Eski ?eyrek
  'gold_quarter_new', -- Yeni ?eyrek
  'gold_half',       -- Yar?m Alt?n
  'gold_full',       -- Tam Alt?n
  'silver',          -- G?m??
  'commodity',       -- Emtialar
  'currency',        -- D?viz
  'bes_fund'         -- BES Fonlar?
);

-- Payment Method Enum
CREATE TYPE payment_method AS ENUM (
  'cash',           -- Nakit
  'credit_card',     -- Kredi Kart?
  'bank_transfer',  -- Banka Transferi
  'bes_bulk_payment' -- BES Toplu ?deme
);

-- BES Transaction Type Enum
CREATE TYPE bes_transaction_type AS ENUM (
  'purchase',              -- Normal fon alma
  'credit_card_purchase',  -- Kredi kart? ile fon alma
  'fund_change',          -- Fon de?i?tirme
  'bulk_payment'          -- Toplu ?deme
);

-- Securities tablosunu g?ncelle
ALTER TABLE public.securities 
  ADD COLUMN IF NOT EXISTS asset_type asset_type,
  ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS price_source_id UUID,
  ADD COLUMN IF NOT EXISTS isin TEXT,
  ADD COLUMN IF NOT EXISTS cusip TEXT;

-- Transactions tablosuna payment_method ekle
ALTER TABLE public.transactions
  ADD COLUMN IF NOT EXISTS payment_method payment_method DEFAULT 'cash';

-- Asset Price Sources (Fiyat kaynaklar? ve API konfig?rasyonlar?)
CREATE TABLE IF NOT EXISTS public.asset_price_sources (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  source_type TEXT NOT NULL CHECK (source_type IN ('api', 'manual', 'n8n_workflow')),
  api_endpoint TEXT,
  api_key TEXT,
  config JSONB DEFAULT '{}'::jsonb,
  update_frequency_minutes INTEGER DEFAULT 60,
  is_active BOOLEAN DEFAULT true,
  last_successful_update TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Price Updates Log (Fiyat g?ncelleme loglar?)
CREATE TABLE IF NOT EXISTS public.price_updates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  security_id UUID REFERENCES public.securities(id) ON DELETE CASCADE NOT NULL,
  price_source_id UUID REFERENCES public.asset_price_sources(id),
  old_price DECIMAL(15, 4),
  new_price DECIMAL(15, 4),
  update_status TEXT NOT NULL CHECK (update_status IN ('success', 'failed', 'skipped')),
  error_message TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- BES Transactions (BES ?zel i?lemler)
CREATE TABLE IF NOT EXISTS public.bes_transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  portfolio_item_id UUID REFERENCES public.portfolio_items(id) ON DELETE CASCADE NOT NULL,
  transaction_type bes_transaction_type NOT NULL,
  from_fund_id UUID REFERENCES public.securities(id),
  to_fund_id UUID REFERENCES public.securities(id),
  amount DECIMAL(15, 4) NOT NULL,
  quantity DECIMAL(15, 4),
  price DECIMAL(15, 4),
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  settlement_date TIMESTAMP WITH TIME ZONE, -- Kredi kart? i?in 1 ay sonraki tarih
  credit_card_id UUID REFERENCES public.credit_cards(id),
  is_settled BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Credit Card Transactions (Kredi kart? i?lemleri - tasarruf mod?l? i?in)
CREATE TABLE IF NOT EXISTS public.credit_card_transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  credit_card_id UUID REFERENCES public.credit_cards(id) ON DELETE CASCADE NOT NULL,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'payment', 'refund')),
  related_transaction_id UUID, -- Portfolio transaction veya income_expense ile ba?lant?
  related_transaction_type TEXT CHECK (related_transaction_type IN ('portfolio', 'income_expense', 'bes')),
  amount DECIMAL(15, 4) NOT NULL,
  currency TEXT DEFAULT 'TRY',
  description TEXT,
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  settlement_date TIMESTAMP WITH TIME ZONE, -- ?deme tarihi
  is_settled BOOLEAN DEFAULT false,
  category_id UUID REFERENCES public.categories(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Income/Expense tablosuna credit_card_transaction_id ekle
ALTER TABLE public.income_expenses
  ADD COLUMN IF NOT EXISTS credit_card_transaction_id UUID REFERENCES public.credit_card_transactions(id);

-- Portfolio Items i?in metadata ekle (alt?n t?rleri i?in ?zel bilgiler)
ALTER TABLE public.portfolio_items
  ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_securities_asset_type ON public.securities(asset_type);
CREATE INDEX IF NOT EXISTS idx_securities_price_source ON public.securities(price_source_id);
CREATE INDEX IF NOT EXISTS idx_transactions_payment_method ON public.transactions(payment_method);
CREATE INDEX IF NOT EXISTS idx_price_updates_security ON public.price_updates(security_id);
CREATE INDEX IF NOT EXISTS idx_price_updates_status ON public.price_updates(update_status);
CREATE INDEX IF NOT EXISTS idx_bes_transactions_user ON public.bes_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_bes_transactions_settlement ON public.bes_transactions(settlement_date) WHERE is_settled = false;
CREATE INDEX IF NOT EXISTS idx_credit_card_transactions_user ON public.credit_card_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_credit_card_transactions_card ON public.credit_card_transactions(credit_card_id);
CREATE INDEX IF NOT EXISTS idx_credit_card_transactions_settled ON public.credit_card_transactions(is_settled) WHERE is_settled = false;

-- RLS Policies
ALTER TABLE public.asset_price_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.price_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bes_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_card_transactions ENABLE ROW LEVEL SECURITY;

-- Asset Price Sources: Public read for authenticated users
CREATE POLICY "Authenticated users can view price sources" ON public.asset_price_sources
  FOR SELECT USING (auth.role() = 'authenticated');

-- Price Updates: Users can view their own securities' price updates
CREATE POLICY "Users can view price updates for own securities" ON public.price_updates
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.securities
      WHERE securities.id = price_updates.security_id
    )
  );

-- BES Transactions: Users can manage own BES transactions
CREATE POLICY "Users can manage own BES transactions" ON public.bes_transactions
  FOR ALL USING (auth.uid() = user_id);

-- Credit Card Transactions: Users can manage own credit card transactions
CREATE POLICY "Users can manage own credit card transactions" ON public.credit_card_transactions
  FOR ALL USING (auth.uid() = user_id);

-- Triggers for updated_at
CREATE TRIGGER update_asset_price_sources_updated_at BEFORE UPDATE ON public.asset_price_sources
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bes_transactions_updated_at BEFORE UPDATE ON public.bes_transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_credit_card_transactions_updated_at BEFORE UPDATE ON public.credit_card_transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Otomatik BES kredi kart? settlement kontrol? (1 ay sonra)
CREATE OR REPLACE FUNCTION check_bes_credit_card_settlement()
RETURNS void AS $$
BEGIN
  UPDATE public.bes_transactions
  SET is_settled = true
  WHERE transaction_type = 'credit_card_purchase'
    AND is_settled = false
    AND settlement_date <= NOW();
END;
$$ LANGUAGE plpgsql;

-- Function: Otomatik kredi kart? transaction settlement kontrol?
CREATE OR REPLACE FUNCTION check_credit_card_settlement()
RETURNS void AS $$
BEGIN
  UPDATE public.credit_card_transactions
  SET is_settled = true
  WHERE is_settled = false
    AND settlement_date <= NOW();
END;
$$ LANGUAGE plpgsql;

-- Initial data: Asset Price Sources (?rnek kaynaklar)
INSERT INTO public.asset_price_sources (name, source_type, api_endpoint, is_active) VALUES
  ('BIST API', 'api', 'https://api.borsaistanbul.com', true),
  ('Yahoo Finance', 'api', 'https://query1.finance.yahoo.com', true),
  ('Alpha Vantage', 'api', 'https://www.alphavantage.co/query', true),
  ('TCMB D?viz', 'api', 'https://www.tcmb.gov.tr/kurlar', true),
  ('Alt?n Fiyatlar?', 'api', 'https://api.altinapi.com', true),
  ('n8n Workflow', 'n8n_workflow', NULL, true),
  ('Manuel', 'manual', NULL, true)
ON CONFLICT DO NOTHING;
