-- Zaman Dilimi G?ncellemesi ve ?oklu Dil Deste?i - Migration
-- Bu dosyay? migration_portfolio_cards.sql'den SONRA ?al??t?r?n

-- Function: 1 haftal?k kar/zarar (yeni)
CREATE OR REPLACE FUNCTION get_portfolio_profit_loss_1w(
  p_portfolio_id UUID,
  p_user_id UUID
)
RETURNS TABLE (
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2),
  current_value DECIMAL(15, 4),
  previous_value DECIMAL(15, 4)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pl.profit_loss,
    pl.profit_loss_percent,
    pl.current_value,
    pl.previous_value
  FROM get_portfolio_profit_loss(p_portfolio_id, p_user_id, 7) pl;
END;
$$ LANGUAGE plpgsql;

-- Function: Y?l ba??ndan itibaren kar/zarar (yeni)
CREATE OR REPLACE FUNCTION get_portfolio_profit_loss_ytd(
  p_portfolio_id UUID,
  p_user_id UUID
)
RETURNS TABLE (
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2),
  current_value DECIMAL(15, 4),
  previous_value DECIMAL(15, 4),
  current_cost DECIMAL(15, 4),
  previous_cost DECIMAL(15, 4)
) AS $$
DECLARE
  v_current_value DECIMAL(15, 4);
  v_current_cost DECIMAL(15, 4);
  v_previous_value DECIMAL(15, 4);
  v_previous_cost DECIMAL(15, 4);
  v_snapshot_value DECIMAL(15, 4);
  v_snapshot_cost DECIMAL(15, 4);
  v_year_start DATE;
BEGIN
  -- Y?l ba?? tarihini hesapla
  v_year_start := DATE_TRUNC('year', CURRENT_DATE)::DATE;
  
  -- Mevcut de?eri hesapla
  IF p_portfolio_id IS NULL THEN
    -- T?m? i?in
    SELECT total_value, total_cost 
    INTO v_current_value, v_current_cost
    FROM calculate_all_portfolios_value(p_user_id);
  ELSE
    -- Belirli portf?y i?in
    SELECT total_value, total_cost 
    INTO v_current_value, v_current_cost
    FROM calculate_portfolio_value(p_portfolio_id);
  END IF;
  
  -- Y?l ba?? snapshot'? bul
  SELECT total_value, total_cost 
  INTO v_snapshot_value, v_snapshot_cost
  FROM public.portfolio_snapshots
  WHERE (portfolio_id = p_portfolio_id OR (portfolio_id IS NULL AND user_id = p_user_id))
    AND snapshot_date = v_year_start
  ORDER BY snapshot_date DESC
  LIMIT 1;
  
  -- E?er y?l ba?? snapshot yoksa, en yak?n snapshot'? bul
  IF v_snapshot_value IS NULL THEN
    SELECT total_value, total_cost 
    INTO v_snapshot_value, v_snapshot_cost
    FROM public.portfolio_snapshots
    WHERE (portfolio_id = p_portfolio_id OR (portfolio_id IS NULL AND user_id = p_user_id))
      AND snapshot_date <= v_year_start
    ORDER BY snapshot_date DESC
    LIMIT 1;
  END IF;
  
  -- E?er hala snapshot yoksa, mevcut de?erleri kullan
  IF v_snapshot_value IS NULL THEN
    v_previous_value := v_current_value;
    v_previous_cost := v_current_cost;
  ELSE
    v_previous_value := v_snapshot_value;
    v_previous_cost := v_snapshot_cost;
  END IF;
  
  -- Kar/zarar hesapla
  RETURN QUERY SELECT
    (v_current_value - v_current_cost) - (v_previous_value - v_previous_cost),
    CASE 
      WHEN v_previous_cost > 0 THEN
        (((v_current_value - v_current_cost) - (v_previous_value - v_previous_cost)) / v_previous_cost) * 100
      ELSE 0
    END,
    v_current_value,
    v_previous_value,
    v_current_cost,
    v_previous_cost;
END;
$$ LANGUAGE plpgsql;

-- Function: 3 y?ll?k kar/zarar (yeni)
CREATE OR REPLACE FUNCTION get_portfolio_profit_loss_3y(
  p_portfolio_id UUID,
  p_user_id UUID
)
RETURNS TABLE (
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2),
  current_value DECIMAL(15, 4),
  previous_value DECIMAL(15, 4)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pl.profit_loss,
    pl.profit_loss_percent,
    pl.current_value,
    pl.previous_value
  FROM get_portfolio_profit_loss(p_portfolio_id, p_user_id, 1095) pl; -- 3 y?l = 1095 g?n
END;
$$ LANGUAGE plpgsql;

-- Not: Eski fonksiyonlar (3m, 6m) kald?r?lmad? - geriye uyumluluk i?in
-- Frontend'de kullan?lmad???ndan emin olunduktan sonra kald?r?labilir
