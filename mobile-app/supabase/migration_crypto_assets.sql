-- Kripto Varl?klar ve Geli?mi? Arama Sistemi - Migration
-- Bu dosyay? migration_currency_system.sql'den SONRA ?al??t?r?n

-- Asset Types Enum'a kripto t?rleri ekle
-- Not: Enum'a direkt ekleme yap?lamaz, ?nce yeni enum olu?turup sonra de?i?tirmek gerekir
-- Bu y?zden ALTER TYPE kullanaca??z

-- E?er enum zaten varsa, yeni de?erler ekle (PostgreSQL 9.1+)
DO $$ 
BEGIN
  -- Kripto t?rlerini ekle
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'asset_type' 
    AND EXISTS (
      SELECT 1 FROM pg_enum WHERE enumlabel = 'crypto_usdt' AND enumtypid = (
        SELECT oid FROM pg_type WHERE typname = 'asset_type'
      )
    )
  ) THEN
    ALTER TYPE asset_type ADD VALUE IF NOT EXISTS 'crypto_usdt';
    ALTER TYPE asset_type ADD VALUE IF NOT EXISTS 'crypto_try';
    ALTER TYPE asset_type ADD VALUE IF NOT EXISTS 'crypto_btc';
    ALTER TYPE asset_type ADD VALUE IF NOT EXISTS 'crypto_eth';
  END IF;
END $$;

-- Securities tablosuna kripto deste?i ekle
ALTER TABLE public.securities
  ADD COLUMN IF NOT EXISTS base_currency TEXT,        -- BTC, ETH, vb. (kripto i?in)
  ADD COLUMN IF NOT EXISTS quote_currency TEXT,       -- USDT, TRY, BTC, ETH (kripto i?in)
  ADD COLUMN IF NOT EXISTS platform TEXT,             -- Binance, Coinbase, Paribu, BtcTurk, vb.
  ADD COLUMN IF NOT EXISTS api_source TEXT,           -- Veri kayna?? API
  ADD COLUMN IF NOT EXISTS last_api_fetch TIMESTAMP WITH TIME ZONE, -- Son API ?a?r?s?
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Full-text search i?in search_vector kolonu ekle
ALTER TABLE public.securities
  ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Search vector'? otomatik g?ncellemek i?in fonksiyon
CREATE OR REPLACE FUNCTION update_security_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('turkish', COALESCE(NEW.symbol, '')), 'A') ||
    setweight(to_tsvector('turkish', COALESCE(NEW.name, '')), 'B') ||
    setweight(to_tsvector('turkish', COALESCE(NEW.base_currency, '')), 'C') ||
    setweight(to_tsvector('turkish', COALESCE(NEW.quote_currency, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Search vector'? otomatik g?ncelle
DROP TRIGGER IF EXISTS trigger_update_security_search_vector ON public.securities;
CREATE TRIGGER trigger_update_security_search_vector
  BEFORE INSERT OR UPDATE ON public.securities
  FOR EACH ROW
  EXECUTE FUNCTION update_security_search_vector();

-- Mevcut kay?tlar i?in search vector'? g?ncelle
UPDATE public.securities
SET search_vector = 
  setweight(to_tsvector('turkish', COALESCE(symbol, '')), 'A') ||
  setweight(to_tsvector('turkish', COALESCE(name, '')), 'B') ||
  setweight(to_tsvector('turkish', COALESCE(base_currency, '')), 'C') ||
  setweight(to_tsvector('turkish', COALESCE(quote_currency, '')), 'C');

-- Full-text search index
CREATE INDEX IF NOT EXISTS idx_securities_search_vector ON public.securities USING GIN(search_vector);

-- Sembol ve isim i?in b-tree indexler (h?zl? e?le?me i?in)
CREATE INDEX IF NOT EXISTS idx_securities_symbol ON public.securities(symbol);
CREATE INDEX IF NOT EXISTS idx_securities_name ON public.securities(name);
CREATE INDEX IF NOT EXISTS idx_securities_asset_type ON public.securities(asset_type);

-- Kripto i?in ?zel indexler
CREATE INDEX IF NOT EXISTS idx_securities_base_currency ON public.securities(base_currency) WHERE base_currency IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_securities_quote_currency ON public.securities(quote_currency) WHERE quote_currency IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_securities_platform ON public.securities(platform) WHERE platform IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_securities_base_quote ON public.securities(base_currency, quote_currency) WHERE base_currency IS NOT NULL AND quote_currency IS NOT NULL;

-- Otomatik tamamlama i?in materialized view
CREATE MATERIALIZED VIEW IF NOT EXISTS public.securities_search_cache AS
SELECT 
  id,
  symbol,
  name,
  asset_type,
  base_currency,
  quote_currency,
  platform,
  exchange,
  currency,
  current_price,
  search_vector,
  -- Arama i?in kolay eri?im i?in birle?tirilmi? text
  symbol || ' ' || name || ' ' || COALESCE(base_currency || '/' || quote_currency, '') AS search_text
FROM public.securities
WHERE is_active IS NULL OR is_active = true;

-- Materialized view i?in index
CREATE INDEX IF NOT EXISTS idx_securities_search_cache_text ON public.securities_search_cache USING GIN(to_tsvector('turkish', search_text));
CREATE INDEX IF NOT EXISTS idx_securities_search_cache_type ON public.securities_search_cache(asset_type);

-- Materialized view'i yenilemek i?in fonksiyon
CREATE OR REPLACE FUNCTION refresh_securities_search_cache()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.securities_search_cache;
END;
$$ LANGUAGE plpgsql;

-- Function: Arama fonksiyonu (sembol/isim ile)
CREATE OR REPLACE FUNCTION search_securities(
  p_search_text TEXT,
  p_asset_type asset_type DEFAULT NULL,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  symbol TEXT,
  name TEXT,
  asset_type asset_type,
  base_currency TEXT,
  quote_currency TEXT,
  platform TEXT,
  exchange TEXT,
  currency TEXT,
  current_price DECIMAL(15, 4),
  relevance REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.symbol,
    s.name,
    s.asset_type,
    s.base_currency,
    s.quote_currency,
    s.platform,
    s.exchange,
    s.currency,
    s.current_price,
    ts_rank(s.search_vector, plainto_tsquery('turkish', p_search_text)) AS relevance
  FROM public.securities s
  WHERE 
    (p_search_text IS NULL OR s.search_vector @@ plainto_tsquery('turkish', p_search_text))
    AND (p_asset_type IS NULL OR s.asset_type = p_asset_type)
    AND (s.is_active IS NULL OR s.is_active = true)
  ORDER BY 
    CASE 
      WHEN s.symbol ILIKE p_search_text || '%' THEN 1  -- Sembol e?le?mesi ?ncelikli
      WHEN s.name ILIKE p_search_text || '%' THEN 2    -- ?sim e?le?mesi
      ELSE 3                                             -- Full-text search
    END,
    relevance DESC,
    s.name ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function: Kripto ?iftleri i?in arama
CREATE OR REPLACE FUNCTION search_crypto_pairs(
  p_base_currency TEXT,
  p_quote_currency TEXT DEFAULT NULL,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  symbol TEXT,
  name TEXT,
  base_currency TEXT,
  quote_currency TEXT,
  platform TEXT,
  current_price DECIMAL(15, 4)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.symbol,
    s.name,
    s.base_currency,
    s.quote_currency,
    s.platform,
    s.current_price
  FROM public.securities s
  WHERE 
    s.asset_type IN ('crypto_usdt', 'crypto_try', 'crypto_btc', 'crypto_eth')
    AND s.base_currency = UPPER(p_base_currency)
    AND (p_quote_currency IS NULL OR s.quote_currency = UPPER(p_quote_currency))
    AND (s.is_active IS NULL OR s.is_active = true)
  ORDER BY 
    CASE WHEN s.quote_currency = 'USDT' THEN 1 ELSE 2 END, -- USDT ?ncelikli
    s.current_price DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function: Otomatik veri ?ekme (API'den)
-- Bu fonksiyon Supabase Edge Function veya n8n taraf?ndan ?a?r?lacak
CREATE OR REPLACE FUNCTION fetch_security_data(
  p_symbol TEXT,
  p_asset_type asset_type,
  p_base_currency TEXT DEFAULT NULL,
  p_quote_currency TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_security_id UUID;
BEGIN
  -- Mevcut security'yi kontrol et
  SELECT id INTO v_security_id
  FROM public.securities
  WHERE symbol = UPPER(p_symbol)
    AND asset_type = p_asset_type
    AND (p_base_currency IS NULL OR base_currency = UPPER(p_base_currency))
    AND (p_quote_currency IS NULL OR quote_currency = UPPER(p_quote_currency))
  LIMIT 1;
  
  -- E?er yoksa olu?tur
  IF v_security_id IS NULL THEN
    INSERT INTO public.securities (
      symbol,
      name,
      asset_type,
      base_currency,
      quote_currency,
      is_active
    ) VALUES (
      UPPER(p_symbol),
      UPPER(p_symbol), -- Ge?ici isim, API'den g?ncellenecek
      p_asset_type,
      UPPER(p_base_currency),
      UPPER(p_quote_currency),
      true
    )
    RETURNING id INTO v_security_id;
  END IF;
  
  -- Son API ?a?r?s? zaman?n? g?ncelle
  UPDATE public.securities
  SET last_api_fetch = NOW()
  WHERE id = v_security_id;
  
  RETURN v_security_id;
END;
$$ LANGUAGE plpgsql;

-- ?rnek kripto varl?klar? ekle (test i?in)
INSERT INTO public.securities (symbol, name, asset_type, base_currency, quote_currency, platform, currency, is_active)
VALUES 
  ('BTC/USDT', 'Bitcoin / Tether', 'crypto_usdt', 'BTC', 'USDT', 'Binance', 'USDT', true),
  ('BTC/TRY', 'Bitcoin / T?rk Liras?', 'crypto_try', 'BTC', 'TRY', 'Binance TR', 'TRY', true),
  ('ETH/USDT', 'Ethereum / Tether', 'crypto_usdt', 'ETH', 'USDT', 'Binance', 'USDT', true),
  ('ETH/TRY', 'Ethereum / T?rk Liras?', 'crypto_try', 'ETH', 'TRY', 'Binance TR', 'TRY', true),
  ('ETH/BTC', 'Ethereum / Bitcoin', 'crypto_btc', 'ETH', 'BTC', 'Binance', 'BTC', true)
ON CONFLICT (symbol) DO NOTHING;

-- ?lk materialized view refresh
REFRESH MATERIALIZED VIEW public.securities_search_cache;
