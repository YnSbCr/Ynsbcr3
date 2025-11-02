-- Portf?y Kartlar? ve Zaman Dilimi Sistemi - Migration
-- Bu dosyay? migration_crypto_assets.sql'den SONRA ?al??t?r?n

-- Portfolio Snapshots Tablosu (Tarihsel portf?y de?erleri)
CREATE TABLE IF NOT EXISTS public.portfolio_snapshots (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  portfolio_id UUID REFERENCES public.portfolios(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL, -- "T?m?" i?in NULL
  snapshot_date DATE NOT NULL,
  total_value DECIMAL(15, 4) NOT NULL,
  total_cost DECIMAL(15, 4) NOT NULL,
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(COALESCE(portfolio_id::TEXT, user_id::TEXT), snapshot_date)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_portfolio_snapshots_portfolio ON public.portfolio_snapshots(portfolio_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_snapshots_user ON public.portfolio_snapshots(user_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_snapshots_date ON public.portfolio_snapshots(snapshot_date);
CREATE INDEX IF NOT EXISTS idx_portfolio_snapshots_portfolio_date ON public.portfolio_snapshots(portfolio_id, snapshot_date);

-- RLS Policies
ALTER TABLE public.portfolio_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own portfolio snapshots" ON public.portfolio_snapshots
  FOR ALL USING (auth.uid() = user_id);

-- Function: Portfolio de?erini hesapla (anl?k)
CREATE OR REPLACE FUNCTION calculate_portfolio_value(
  p_portfolio_id UUID
)
RETURNS TABLE (
  total_value DECIMAL(15, 4),
  total_cost DECIMAL(15, 4),
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2)
) AS $$
DECLARE
  v_total_value DECIMAL(15, 4) := 0;
  v_total_cost DECIMAL(15, 4) := 0;
BEGIN
  SELECT 
    COALESCE(SUM(pi.quantity * s.current_price), 0),
    COALESCE(SUM(pi.quantity * pi.average_cost), 0)
  INTO v_total_value, v_total_cost
  FROM public.portfolio_items pi
  JOIN public.securities s ON s.id = pi.security_id
  WHERE pi.portfolio_id = p_portfolio_id;
  
  RETURN QUERY SELECT
    v_total_value,
    v_total_cost,
    v_total_value - v_total_cost,
    CASE 
      WHEN v_total_cost > 0 THEN
        ((v_total_value - v_total_cost) / v_total_cost) * 100
      ELSE 0
    END;
END;
$$ LANGUAGE plpgsql;

-- Function: T?m portf?ylerin toplam de?erini hesapla
CREATE OR REPLACE FUNCTION calculate_all_portfolios_value(
  p_user_id UUID
)
RETURNS TABLE (
  total_value DECIMAL(15, 4),
  total_cost DECIMAL(15, 4),
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2)
) AS $$
DECLARE
  v_total_value DECIMAL(15, 4) := 0;
  v_total_cost DECIMAL(15, 4) := 0;
BEGIN
  SELECT 
    COALESCE(SUM(pi.quantity * s.current_price), 0),
    COALESCE(SUM(pi.quantity * pi.average_cost), 0)
  INTO v_total_value, v_total_cost
  FROM public.portfolio_items pi
  JOIN public.securities s ON s.id = pi.security_id
  JOIN public.portfolios p ON p.id = pi.portfolio_id
  WHERE p.user_id = p_user_id;
  
  RETURN QUERY SELECT
    v_total_value,
    v_total_cost,
    v_total_value - v_total_cost,
    CASE 
      WHEN v_total_cost > 0 THEN
        ((v_total_value - v_total_cost) / v_total_cost) * 100
      ELSE 0
    END;
END;
$$ LANGUAGE plpgsql;

-- Function: 1 g?nl?k de?er de?i?imi
CREATE OR REPLACE FUNCTION get_portfolio_value_1d(
  p_portfolio_id UUID,
  p_user_id UUID
)
RETURNS TABLE (
  value_change DECIMAL(15, 4),
  value_change_percent DECIMAL(10, 2),
  current_value DECIMAL(15, 4),
  previous_value DECIMAL(15, 4)
) AS $$
DECLARE
  v_current_value DECIMAL(15, 4);
  v_previous_value DECIMAL(15, 4);
  v_snapshot_value DECIMAL(15, 4);
BEGIN
  -- Mevcut de?eri hesapla
  IF p_portfolio_id IS NULL THEN
    -- T?m? i?in
    SELECT total_value INTO v_current_value
    FROM calculate_all_portfolios_value(p_user_id);
  ELSE
    -- Belirli portf?y i?in
    SELECT total_value INTO v_current_value
    FROM calculate_portfolio_value(p_portfolio_id);
  END IF;
  
  -- 1 g?n ?nceki snapshot'? bul
  SELECT total_value INTO v_snapshot_value
  FROM public.portfolio_snapshots
  WHERE (portfolio_id = p_portfolio_id OR (portfolio_id IS NULL AND user_id = p_user_id))
    AND snapshot_date = CURRENT_DATE - INTERVAL '1 day'
  ORDER BY snapshot_date DESC
  LIMIT 1;
  
  -- E?er snapshot yoksa, manuel hesapla
  IF v_snapshot_value IS NULL THEN
    -- 1 g?n ?nceki fiyatlarla hesapla (basitle?tirilmi?)
    v_previous_value := v_current_value; -- Ge?ici olarak ayn? de?er
  ELSE
    v_previous_value := v_snapshot_value;
  END IF;
  
  RETURN QUERY SELECT
    v_current_value - v_previous_value,
    CASE 
      WHEN v_previous_value > 0 THEN
        ((v_current_value - v_previous_value) / v_previous_value) * 100
      ELSE 0
    END,
    v_current_value,
    v_previous_value;
END;
$$ LANGUAGE plpgsql;

-- Function: Belirli bir zaman dilimi i?in kar/zarar
CREATE OR REPLACE FUNCTION get_portfolio_profit_loss(
  p_portfolio_id UUID,
  p_user_id UUID,
  p_days INTEGER
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
BEGIN
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
  
  -- Belirli g?n ?nceki snapshot'? bul
  SELECT total_value, total_cost 
  INTO v_snapshot_value, v_snapshot_cost
  FROM public.portfolio_snapshots
  WHERE (portfolio_id = p_portfolio_id OR (portfolio_id IS NULL AND user_id = p_user_id))
    AND snapshot_date = CURRENT_DATE - (p_days || ' days')::INTERVAL
  ORDER BY snapshot_date DESC
  LIMIT 1;
  
  -- E?er snapshot yoksa, en yak?n snapshot'? bul
  IF v_snapshot_value IS NULL THEN
    SELECT total_value, total_cost 
    INTO v_snapshot_value, v_snapshot_cost
    FROM public.portfolio_snapshots
    WHERE (portfolio_id = p_portfolio_id OR (portfolio_id IS NULL AND user_id = p_user_id))
      AND snapshot_date <= CURRENT_DATE - (p_days || ' days')::INTERVAL
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

-- Function: 1 ayl?k kar/zarar (wrapper)
CREATE OR REPLACE FUNCTION get_portfolio_profit_loss_1m(
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
  FROM get_portfolio_profit_loss(p_portfolio_id, p_user_id, 30) pl;
END;
$$ LANGUAGE plpgsql;

-- Function: 3 ayl?k kar/zarar (wrapper)
CREATE OR REPLACE FUNCTION get_portfolio_profit_loss_3m(
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
  FROM get_portfolio_profit_loss(p_portfolio_id, p_user_id, 90) pl;
END;
$$ LANGUAGE plpgsql;

-- Function: 6 ayl?k kar/zarar (wrapper)
CREATE OR REPLACE FUNCTION get_portfolio_profit_loss_6m(
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
  FROM get_portfolio_profit_loss(p_portfolio_id, p_user_id, 180) pl;
END;
$$ LANGUAGE plpgsql;

-- Function: 1 y?ll?k kar/zarar (wrapper)
CREATE OR REPLACE FUNCTION get_portfolio_profit_loss_1y(
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
  FROM get_portfolio_profit_loss(p_portfolio_id, p_user_id, 365) pl;
END;
$$ LANGUAGE plpgsql;

-- Function: G?nl?k snapshot olu?tur (scheduled job i?in)
CREATE OR REPLACE FUNCTION create_daily_portfolio_snapshots()
RETURNS void AS $$
DECLARE
  v_portfolio RECORD;
  v_user RECORD;
  v_value DECIMAL(15, 4);
  v_cost DECIMAL(15, 4);
  v_profit_loss DECIMAL(15, 4);
  v_profit_loss_percent DECIMAL(10, 2);
BEGIN
  -- Her kullan?c? i?in
  FOR v_user IN SELECT DISTINCT user_id FROM public.portfolios LOOP
    -- T?m? i?in snapshot
    SELECT * INTO v_value, v_cost, v_profit_loss, v_profit_loss_percent
    FROM calculate_all_portfolios_value(v_user.user_id);
    
    INSERT INTO public.portfolio_snapshots (
      portfolio_id,
      user_id,
      snapshot_date,
      total_value,
      total_cost,
      profit_loss,
      profit_loss_percent
    ) VALUES (
      NULL,
      v_user.user_id,
      CURRENT_DATE,
      v_value,
      v_cost,
      v_profit_loss,
      v_profit_loss_percent
    ) ON CONFLICT (COALESCE(portfolio_id::TEXT, user_id::TEXT), snapshot_date) 
    DO UPDATE SET
      total_value = EXCLUDED.total_value,
      total_cost = EXCLUDED.total_cost,
      profit_loss = EXCLUDED.profit_loss,
      profit_loss_percent = EXCLUDED.profit_loss_percent;
    
    -- Her portf?y i?in snapshot
    FOR v_portfolio IN SELECT id FROM public.portfolios WHERE user_id = v_user.user_id LOOP
      SELECT * INTO v_value, v_cost, v_profit_loss, v_profit_loss_percent
      FROM calculate_portfolio_value(v_portfolio.id);
      
      INSERT INTO public.portfolio_snapshots (
        portfolio_id,
        user_id,
        snapshot_date,
        total_value,
        total_cost,
        profit_loss,
        profit_loss_percent
      ) VALUES (
        v_portfolio.id,
        v_user.user_id,
        CURRENT_DATE,
        v_value,
        v_cost,
        v_profit_loss,
        v_profit_loss_percent
      ) ON CONFLICT (COALESCE(portfolio_id::TEXT, user_id::TEXT), snapshot_date) 
      DO UPDATE SET
        total_value = EXCLUDED.total_value,
        total_cost = EXCLUDED.total_cost,
        profit_loss = EXCLUDED.profit_loss,
        profit_loss_percent = EXCLUDED.profit_loss_percent;
    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
