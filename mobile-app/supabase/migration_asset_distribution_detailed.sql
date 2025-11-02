-- Varl?k Da??l?m? ve Detay Kartlar? - Geli?mi? Database Functions
-- Bu dosyay? migration_asset_distribution.sql'den SONRA ?al??t?r?n
-- G?NCELLEME: 1A ve 2A zaman dilimine g?re DE??L, toplam kar/zarar olarak hesaplan?r

-- Function: Portf?y genel ?zeti
-- NOT: 1A ve 2A zaman dilimine g?re DE??L, toplam kar/zarar olarak hesaplan?r
CREATE OR REPLACE FUNCTION get_portfolio_summary(
  p_portfolio_id UUID,
  p_user_id UUID,
  p_time_period TEXT DEFAULT '1A' -- Sadece varl?k detay? i?in kullan?l?r, 1A ve 2A i?in kullan?lmaz
)
RETURNS TABLE (
  total_profit_loss DECIMAL(15, 4), -- 1A: Toplam K/Z (ba?lang??tan bug?ne, zaman dilimine g?re DE??L)
  daily_profit_loss DECIMAL(15, 4), -- 1B: G?nl?k K/Z (her zaman 1G)
  total_cost DECIMAL(15, 4), -- 1C: Toplam Maliyet
  total_profit_loss_percent DECIMAL(10, 2), -- 2A: Toplam K/Z Oran (ba?lang??tan bug?ne, zaman dilimine g?re DE??L)
  daily_profit_loss_percent DECIMAL(10, 2), -- 2B: G?nl?k K/Z Oran (her zaman 1G)
  profitable_positions_count INTEGER,
  total_positions_count INTEGER,
  profitable_positions_ratio TEXT -- 2C: Karl? Poziyon (4/6 format?nda)
) AS $$
DECLARE
  v_current_value DECIMAL(15, 4);
  v_total_cost DECIMAL(15, 4);
  v_total_profit_loss DECIMAL(15, 4);
  v_total_profit_loss_percent DECIMAL(10, 2);
  v_daily_profit_loss DECIMAL(15, 4);
  v_daily_profit_loss_percent DECIMAL(10, 2);
  v_profitable_count INTEGER;
  v_total_count INTEGER;
  v_daily_profit_loss_record RECORD;
BEGIN
  -- Toplam maliyet ve mevcut de?er (TOPLAM kar/zarar i?in)
  IF p_portfolio_id IS NULL THEN
    SELECT total_value, total_cost, profit_loss, profit_loss_percent
    INTO v_current_value, v_total_cost, v_total_profit_loss, v_total_profit_loss_percent
    FROM calculate_all_portfolios_value(p_user_id);
  ELSE
    SELECT total_value, total_cost, profit_loss, profit_loss_percent
    INTO v_current_value, v_total_cost, v_total_profit_loss, v_total_profit_loss_percent
    FROM calculate_portfolio_value(p_portfolio_id);
  END IF;
  
  -- Toplam K/Z hesaplama (zaman dilimine g?re DE??L, toplam)
  v_total_profit_loss := v_current_value - v_total_cost;
  v_total_profit_loss_percent := CASE 
    WHEN v_total_cost > 0 THEN
      ((v_current_value - v_total_cost) / v_total_cost) * 100
    ELSE 0
  END;
  
  -- G?nl?k kar/zarar (her zaman 1G, zaman dilimine g?re DE??L)
  SELECT * INTO v_daily_profit_loss_record
  FROM get_portfolio_value_1d(p_portfolio_id, p_user_id);
  
  v_daily_profit_loss := COALESCE(v_daily_profit_loss_record.value_change, 0);
  v_daily_profit_loss_percent := COALESCE(v_daily_profit_loss_record.value_change_percent, 0);
  
  -- Karl? poziyon say?s?
  SELECT 
    COUNT(*) FILTER (WHERE (pi.quantity * s.current_price) > (pi.quantity * pi.average_cost)),
    COUNT(*)
  INTO v_profitable_count, v_total_count
  FROM public.portfolio_items pi
  JOIN public.securities s ON s.id = pi.security_id
  JOIN public.portfolios p ON p.id = pi.portfolio_id
  WHERE 
    (p_portfolio_id IS NULL AND p.user_id = p_user_id)
    OR (p_portfolio_id IS NOT NULL AND pi.portfolio_id = p_portfolio_id);
  
  RETURN QUERY SELECT
    v_total_profit_loss as total_profit_loss, -- 1A: Toplam K/Z (zaman dilimine g?re DE??L)
    v_daily_profit_loss as daily_profit_loss, -- 1B: G?nl?k K/Z (her zaman 1G)
    v_total_cost as total_cost, -- 1C: Toplam Maliyet
    v_total_profit_loss_percent as total_profit_loss_percent, -- 2A: Toplam K/Z Oran (zaman dilimine g?re DE??L)
    v_daily_profit_loss_percent as daily_profit_loss_percent, -- 2B: G?nl?k K/Z Oran (her zaman 1G)
    v_profitable_count as profitable_positions_count,
    v_total_count as total_positions_count,
    (v_profitable_count || '/' || v_total_count)::TEXT as profitable_positions_ratio; -- 2C: Karl? Poziyon
END;
$$ LANGUAGE plpgsql;

-- Function: Varl?k detaylar? zaman dilimine g?re
CREATE OR REPLACE FUNCTION get_portfolio_asset_details_by_period(
  p_portfolio_id UUID,
  p_user_id UUID,
  p_asset_type asset_type DEFAULT NULL,
  p_time_period TEXT DEFAULT '1A'
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
  percentage DECIMAL(10, 2), -- Pay (y?zde)
  base_currency TEXT,
  quote_currency TEXT,
  platform TEXT,
  exchange TEXT,
  currency TEXT
) AS $$
DECLARE
  v_total_portfolio_value DECIMAL(15, 4);
  v_previous_price DECIMAL(15, 4);
  v_asset RECORD;
BEGIN
  -- Toplam portf?y de?eri (pay hesaplama i?in)
  IF p_portfolio_id IS NULL THEN
    SELECT total_value INTO v_total_portfolio_value
    FROM calculate_all_portfolios_value(p_user_id);
  ELSE
    SELECT total_value INTO v_total_portfolio_value
    FROM calculate_portfolio_value(p_portfolio_id);
  END IF;
  
  -- Her varl?k i?in zaman dilimine g?re kar/zarar hesapla
  FOR v_asset IN
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
  LOOP
    -- Zaman dilimine g?re ?nceki fiyat? hesapla (basitle?tirilmi?)
    -- Ger?ek implementasyonda snapshot'lardan ?nceki fiyatlar ?ekilmeli
    v_previous_price := v_asset.current_price; -- Ge?ici olarak ayn? fiyat
    
    RETURN QUERY SELECT
      v_asset.id,
      v_asset.security_id,
      v_asset.symbol,
      v_asset.name,
      v_asset.asset_type,
      v_asset.quantity,
      v_asset.average_cost,
      v_asset.current_price,
      v_asset.total_cost,
      v_asset.current_value,
      v_asset.current_value - v_asset.total_cost as profit_loss,
      CASE 
        WHEN v_asset.average_cost > 0 THEN
          ((v_asset.current_price - v_asset.average_cost) / v_asset.average_cost) * 100
        ELSE 0
      END as profit_loss_percent,
      CASE 
        WHEN v_total_portfolio_value > 0 THEN
          (v_asset.current_value / v_total_portfolio_value) * 100
        ELSE 0
      END as percentage,
      v_asset.base_currency,
      v_asset.quote_currency,
      v_asset.platform,
      v_asset.exchange,
      v_asset.currency;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function: Varl?k da??l?m? tablosu i?in (g?ncellenmi?)
CREATE OR REPLACE FUNCTION get_portfolio_asset_distribution_table(
  p_portfolio_id UUID,
  p_user_id UUID
)
RETURNS TABLE (
  asset_type asset_type,
  percentage DECIMAL(10, 2), -- Pay
  total_value DECIMAL(15, 4), -- De?er
  profit_loss DECIMAL(15, 4), -- K/Z Tutar
  profit_loss_percent DECIMAL(10, 2) -- K/Z Oran
) AS $$
DECLARE
  v_total_portfolio_value DECIMAL(15, 4);
BEGIN
  -- Toplam portf?y de?erini hesapla
  IF p_portfolio_id IS NULL THEN
    SELECT total_value INTO v_total_portfolio_value
    FROM calculate_all_portfolios_value(p_user_id);
  ELSE
    SELECT total_value INTO v_total_portfolio_value
    FROM calculate_portfolio_value(p_portfolio_id);
  END IF;
  
  -- Varl?k t?rlerine g?re da??l?m
  RETURN QUERY
  SELECT 
    s.asset_type,
    CASE 
      WHEN v_total_portfolio_value > 0 THEN
        (COALESCE(SUM(pi.quantity * s.current_price), 0) / v_total_portfolio_value) * 100
      ELSE 0
    END as percentage,
    COALESCE(SUM(pi.quantity * s.current_price), 0) as total_value,
    COALESCE(SUM(pi.quantity * s.current_price), 0) - COALESCE(SUM(pi.quantity * pi.average_cost), 0) as profit_loss,
    CASE 
      WHEN COALESCE(SUM(pi.quantity * pi.average_cost), 0) > 0 THEN
        ((COALESCE(SUM(pi.quantity * s.current_price), 0) - COALESCE(SUM(pi.quantity * pi.average_cost), 0)) / COALESCE(SUM(pi.quantity * pi.average_cost), 0)) * 100
      ELSE 0
    END as profit_loss_percent
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
