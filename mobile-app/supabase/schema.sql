-- Finans Takip Uygulamas? - Database Schema
-- Bu SQL dosyas?n? Supabase SQL Editor'de ?al??t?r?n

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase Auth users)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Settings (mod?l durumlar? ve genel ayarlar)
CREATE TABLE public.user_settings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  module_enabled JSONB DEFAULT '{
    "portfolio": true,
    "income_expense": true,
    "dividend": true,
    "debt": true,
    "report": true,
    "watchlist": true
  }'::jsonb,
  currency TEXT DEFAULT 'TRY',
  language TEXT DEFAULT 'tr',
  notifications_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Categories (Gelir/Gider kategorileri)
CREATE TABLE public.categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  icon TEXT,
  color TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Securities (Menkul k?ymetler - hisseler)
CREATE TABLE public.securities (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  symbol TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  exchange TEXT,
  currency TEXT DEFAULT 'TRY',
  current_price DECIMAL(15, 4),
  last_updated TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Portfolios (Kullan?c? portf?yleri)
CREATE TABLE public.portfolios (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Portfolio Items (Portf?y ??eleri - hisse pozisyonlar?)
CREATE TABLE public.portfolio_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  portfolio_id UUID REFERENCES public.portfolios(id) ON DELETE CASCADE NOT NULL,
  security_id UUID REFERENCES public.securities(id) NOT NULL,
  quantity DECIMAL(15, 4) NOT NULL DEFAULT 0,
  average_cost DECIMAL(15, 4) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(portfolio_id, security_id)
);

-- Transactions (Al?m/Sat?m i?lemleri)
CREATE TABLE public.transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  portfolio_id UUID REFERENCES public.portfolios(id) ON DELETE CASCADE NOT NULL,
  security_id UUID REFERENCES public.securities(id) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('buy', 'sell')),
  quantity DECIMAL(15, 4) NOT NULL,
  price DECIMAL(15, 4) NOT NULL,
  total_amount DECIMAL(15, 4) NOT NULL,
  fee DECIMAL(15, 4) DEFAULT 0,
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Income/Expense (Gelir/Gider kay?tlar?)
CREATE TABLE public.income_expenses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  category_id UUID REFERENCES public.categories(id),
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  amount DECIMAL(15, 4) NOT NULL,
  currency TEXT DEFAULT 'TRY',
  description TEXT,
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  receipt_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Dividends (Temett? kay?tlar?)
CREATE TABLE public.dividends (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  portfolio_item_id UUID REFERENCES public.portfolio_items(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(15, 4) NOT NULL,
  currency TEXT DEFAULT 'TRY',
  payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  ex_dividend_date TIMESTAMP WITH TIME ZONE,
  tax_rate DECIMAL(5, 2) DEFAULT 0,
  net_amount DECIMAL(15, 4),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Credit Cards (Kredi kartlar?)
CREATE TABLE public.credit_cards (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  bank_name TEXT,
  card_number_last4 TEXT,
  credit_limit DECIMAL(15, 4),
  current_balance DECIMAL(15, 4) DEFAULT 0,
  statement_date INTEGER CHECK (statement_date >= 1 AND statement_date <= 31),
  payment_date INTEGER CHECK (payment_date >= 1 AND payment_date <= 31),
  interest_rate DECIMAL(5, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Credits (Krediler)
CREATE TABLE public.credits (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  institution TEXT,
  total_amount DECIMAL(15, 4) NOT NULL,
  remaining_amount DECIMAL(15, 4) NOT NULL,
  interest_rate DECIMAL(5, 2),
  monthly_payment DECIMAL(15, 4),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Debts (Genel bor?lar)
CREATE TABLE public.debts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('credit_card', 'credit', 'loan', 'other')),
  total_amount DECIMAL(15, 4) NOT NULL,
  remaining_amount DECIMAL(15, 4) NOT NULL,
  interest_rate DECIMAL(5, 2),
  minimum_payment DECIMAL(15, 4),
  due_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Watchlist (?zleme listesi)
CREATE TABLE public.watchlist (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  security_id UUID REFERENCES public.securities(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, security_id)
);

-- Price Alerts (Fiyat alarmlar?)
CREATE TABLE public.price_alerts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  security_id UUID REFERENCES public.securities(id) ON DELETE CASCADE NOT NULL,
  alert_type TEXT NOT NULL CHECK (alert_type IN ('above', 'below', 'percent_change')),
  target_price DECIMAL(15, 4),
  percent_change DECIMAL(5, 2),
  is_active BOOLEAN DEFAULT true,
  triggered_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Receipts (Fatura/foto?raflar - AI i?leme i?in)
CREATE TABLE public.receipts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  income_expense_id UUID REFERENCES public.income_expenses(id) ON DELETE SET NULL,
  image_url TEXT NOT NULL,
  processed_data JSONB,
  ocr_text TEXT,
  ai_category TEXT,
  ai_amount DECIMAL(15, 4),
  is_processed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reports Cache (?nbelleklenmi? raporlar)
CREATE TABLE public.reports (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  report_type TEXT NOT NULL,
  date_range_start TIMESTAMP WITH TIME ZONE NOT NULL,
  date_range_end TIMESTAMP WITH TIME ZONE NOT NULL,
  data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for performance
CREATE INDEX idx_portfolio_items_portfolio ON public.portfolio_items(portfolio_id);
CREATE INDEX idx_portfolio_items_security ON public.portfolio_items(security_id);
CREATE INDEX idx_transactions_portfolio ON public.transactions(portfolio_id);
CREATE INDEX idx_transactions_security ON public.transactions(security_id);
CREATE INDEX idx_transactions_date ON public.transactions(transaction_date);
CREATE INDEX idx_income_expenses_user ON public.income_expenses(user_id);
CREATE INDEX idx_income_expenses_date ON public.income_expenses(transaction_date);
CREATE INDEX idx_income_expenses_category ON public.income_expenses(category_id);
CREATE INDEX idx_dividends_user ON public.dividends(user_id);
CREATE INDEX idx_watchlist_user ON public.watchlist(user_id);
CREATE INDEX idx_price_alerts_user ON public.price_alerts(user_id);
CREATE INDEX idx_price_alerts_active ON public.price_alerts(is_active) WHERE is_active = true;
CREATE INDEX idx_receipts_user ON public.receipts(user_id);
CREATE INDEX idx_reports_user ON public.reports(user_id);

-- Row Level Security (RLS) Policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.income_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dividends ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.price_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Users can only see their own data
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- RLS Policies: User Settings
CREATE POLICY "Users can manage own settings" ON public.user_settings
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Categories
CREATE POLICY "Users can manage own categories" ON public.categories
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Portfolios
CREATE POLICY "Users can manage own portfolios" ON public.portfolios
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Portfolio Items
CREATE POLICY "Users can manage own portfolio items" ON public.portfolio_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.portfolios
      WHERE portfolios.id = portfolio_items.portfolio_id
      AND portfolios.user_id = auth.uid()
    )
  );

-- RLS Policies: Transactions
CREATE POLICY "Users can manage own transactions" ON public.transactions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.portfolios
      WHERE portfolios.id = transactions.portfolio_id
      AND portfolios.user_id = auth.uid()
    )
  );

-- RLS Policies: Income/Expenses
CREATE POLICY "Users can manage own income expenses" ON public.income_expenses
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Dividends
CREATE POLICY "Users can manage own dividends" ON public.dividends
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Credit Cards
CREATE POLICY "Users can manage own credit cards" ON public.credit_cards
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Credits
CREATE POLICY "Users can manage own credits" ON public.credits
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Debts
CREATE POLICY "Users can manage own debts" ON public.debts
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Watchlist
CREATE POLICY "Users can manage own watchlist" ON public.watchlist
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Price Alerts
CREATE POLICY "Users can manage own price alerts" ON public.price_alerts
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Receipts
CREATE POLICY "Users can manage own receipts" ON public.receipts
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies: Reports
CREATE POLICY "Users can manage own reports" ON public.reports
  FOR ALL USING (auth.uid() = user_id);

-- Securities table is public (read-only for all authenticated users)
ALTER TABLE public.securities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view securities" ON public.securities
  FOR SELECT USING (auth.role() = 'authenticated');

-- Functions for auto-updating updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON public.user_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_securities_updated_at BEFORE UPDATE ON public.securities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_portfolios_updated_at BEFORE UPDATE ON public.portfolios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_portfolio_items_updated_at BEFORE UPDATE ON public.portfolio_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_income_expenses_updated_at BEFORE UPDATE ON public.income_expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dividends_updated_at BEFORE UPDATE ON public.dividends
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_credit_cards_updated_at BEFORE UPDATE ON public.credit_cards
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_credits_updated_at BEFORE UPDATE ON public.credits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_debts_updated_at BEFORE UPDATE ON public.debts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_price_alerts_updated_at BEFORE UPDATE ON public.price_alerts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_receipts_updated_at BEFORE UPDATE ON public.receipts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
