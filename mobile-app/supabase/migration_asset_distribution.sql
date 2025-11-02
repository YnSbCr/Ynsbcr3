-- Varl?k Da??l?m? ve Detay Sorgular? - Database Functions
-- Bu dosyay? migration_time_periods_i18n.sql'den SONRA ?al??t?r?n

-- Function: Portf?ydeki varl?k t?rlerine g?re da??l?m
CREATE OR REPLACE FUNCTION get_portfolio_asset_distribution(
  p_portfolio_id UUID,
  p_user_id UUID
)
RETURNS TABLE (
  asset_type asset_type,
  total_value DECIMAL(15, 4),
  total_cost DECIMAL(15, 4),
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2),
  asset_count BIGINT,
  percentage DECIMAL(10, 2)
) AS $$
DECLARE
  v_total_portfolio_value DECIMAL(15, 4);
BEGIN
  -- Toplam portf?y de?erini hesapla
  IF p_portfolio_id IS NULL THEN
    -- T?m? i?in
    SELECT total_value INTO v_total_portfolio_value
    FROM calculate_all_portfolios_value(p_user_id);
  ELSE
    -- Belirli portf?y i?in
    SELECT total_value INTO v_total_portfolio_value
    FROM calculate_portfolio_value(p_portfolio_id);
  END IF;
  
  -- Varl?k t?rlerine g?re da??l?m
  RETURN QUERY
  SELECT 
    s.asset_type,
    COALESCE(SUM(pi.quantity * s.current_price), 0) as total_value,
    COALESCE(SUM(pi.quantity * pi.average_cost), 0) as total_cost,
    COALESCE(SUM(pi.quantity * s.current_price), 0) - COALESCE(SUM(pi.quantity * pi.average_cost), 0) as profit_loss,
    CASE 
      WHEN COALESCE(SUM(pi.quantity * pi.average_cost), 0) > 0 THEN
        ((COALESCE(SUM(pi.quantity * s.current_price), 0) - COALESCE(SUM(pi.quantity * pi.average_cost), 0)) / COALESCE(SUM(pi.quantity * pi.average_cost), 0)) * 100
      ELSE 0
    END as profit_loss_percent,
    COUNT(*) as asset_count,
    CASE 
      WHEN v_total_portfolio_value > 0 THEN
        (COALESCE(SUM(pi.quantity * s.current_price), 0) / v_total_portfolio_value) * 100
      ELSE 0
    END as percentage
  FROM public.portfolio_items pi
  JOIN public.securities s ON s.id = pi.security_id
  JOIN public.portfolios p ON p.id = pi.portfolio_id
  WHERE 
    (p_portfolio_id IS NULL AND p.user_id = p_user_id)
    OR (p_portfolio_id IS NOT NULL AND pi.portfolio_id = p_portfolio_id)
    AND s.asset_type IS NOT NULL
  GROUP BY s.asset_type
  ORDER BY total_value DESC;
END;
$$ LANGUAGE plpgsql;

-- Function: Se?ili varl?k t?r?ne g?re detaylar
CREATE OR REPLACE FUNCTION get_portfolio_asset_details(
  p_portfolio_id UUID,
  p_user_id UUID,
  p_asset_type asset_type DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  security_id UUID,
  symbol TEXT,
  name TEXT,
  asset_type asset_type,
  quantity DECIMAL(15, 4),
  average_cost DECIMAL(15, 4),
  current_price DECIMAL(15, 4),
  total_cost DECIMAL(15, 4),
  current_value DECIMAL(15, 4),
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2),
  base_currency TEXT,
  quote_currency TEXT,
  platform TEXT,
  exchange TEXT,
  currency TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pi.id,
    s.id as security_id,
    s.symbol,
    s.name,
    s.asset_type,
    pi.quantity,
    pi.average_cost,
    s.current_price,
    pi.quantity * pi.average_cost as total_cost,
    pi.quantity * s.current_price as current_value,
    (pi.quantity * s.current_price) - (pi.quantity * pi.average_cost) as profit_loss,
    CASE 
      WHEN pi.average_cost > 0 THEN
        ((s.current_price - pi.average_cost) / pi.average_cost) * 100
      ELSE 0
    END as profit_loss_percent,
    s.base_currency,
    s.quote_currency,
    s.platform,
    s.exchange,
    s.currency
  FROM public.portfolio_items pi
  JOIN public.securities s ON s.id = pi.security_id
  JOIN public.portfolios p ON p.id = pi.portfolio_id
  WHERE 
    (p_portfolio_id IS NULL AND p.user_id = p_user_id)
    OR (p_portfolio_id IS NOT NULL AND pi.portfolio_id = p_portfolio_id)
    AND (p_asset_type IS NULL OR s.asset_type = p_asset_type)
  ORDER BY 
    CASE WHEN p_asset_type IS NOT NULL THEN s.symbol ELSE s.asset_type END,
    s.symbol;
END;
$$ LANGUAGE plpgsql;

-- Function: Varl?k t?r? renk e?le?tirmesi (frontend i?in referans)
CREATE OR REPLACE FUNCTION get_asset_type_colors()
RETURNS JSONB AS $$
BEGIN
  RETURN '{
    "bist_stock": "#2196F3",
    "us_stock": "#FFC107",
    "etf": "#4CAF50",
    "mutual_fund": "#FF9800",
    "gold_24k": "#FFD700",
    "gold_22k": "#FFD700",
    "gold_quarter_old": "#FFD700",
    "gold_quarter_new": "#FFD700",
    "gold_half": "#FFD700",
    "gold_full": "#FFD700",
    "silver": "#9E9E9E",
    "commodity": "#795548",
    "currency": "#F44336",
    "bes_fund": "#E91E63",
    "crypto_usdt": "#9C27B0",
    "crypto_try": "#9C27B0",
    "crypto_btc": "#9C27B0",
    "crypto_eth": "#9C27B0"
  }'::jsonb;
END;
$$ LANGUAGE plpgsql;

-- Function: Varl?k t?r? etiketleri (i18n i?in)
CREATE OR REPLACE FUNCTION get_asset_type_labels(p_language TEXT DEFAULT 'tr')
RETURNS JSONB AS $$
BEGIN
  IF p_language = 'en' THEN
    RETURN '{
      "bist_stock": "BIST Stocks",
      "us_stock": "US Stocks",
      "etf": "ETFs",
      "mutual_fund": "Mutual Funds",
      "gold_24k": "Gold (24k)",
      "gold_22k": "Gold (22k)",
      "gold_quarter_old": "Gold Quarter (Old)",
      "gold_quarter_new": "Gold Quarter (New)",
      "gold_half": "Gold Half",
      "gold_full": "Gold Full",
      "silver": "Silver",
      "commodity": "Commodities",
      "currency": "Currency",
      "bes_fund": "Pension Funds",
      "crypto_usdt": "Crypto (USDT)",
      "crypto_try": "Crypto (TRY)",
      "crypto_btc": "Crypto (BTC)",
      "crypto_eth": "Crypto (ETH)"
    }'::jsonb;
  ELSE
    RETURN '{
      "bist_stock": "BIST Hisseleri",
      "us_stock": "ABD Hisseleri",
      "etf": "ETF\'ler",
      "mutual_fund": "Yat?r?m Fonlar?",
      "gold_24k": "Alt?n (24 Ayar)",
      "gold_22k": "Alt?n (22 Ayar)",
      "gold_quarter_old": "Alt?n ?eyrek (Eski)",
      "gold_quarter_new": "Alt?n ?eyrek (Yeni)",
      "gold_half": "Alt?n Yar?m",
      "gold_full": "Alt?n Tam",
      "silver": "G?m??",
      "commodity": "Emtialar",
      "currency": "D?viz",
      "bes_fund": "BES Fonlar?",
      "crypto_usdt": "Kripto (USDT)",
      "crypto_try": "Kripto (TRY)",
      "crypto_btc": "Kripto (BTC)",
      "crypto_eth": "Kripto (ETH)"
    }'::jsonb;
  END IF;
END;
$$ LANGUAGE plpgsql;
