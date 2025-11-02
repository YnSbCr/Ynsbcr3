# Portf?y Mod?l? - Database ?emas? G?ncellemeleri

## ?? Eklenen ?zellikler

### 1. Varl?k T?rleri Sistemi

#### Asset Types Enum
7 ana kategori + alt kategoriler:
- **BIST Hisseleri**: Borsa ?stanbul
- **ABD Hisseleri**: NYSE, NASDAQ
- **ETF'ler**: T?rk ve ABD ETF'leri
- **T?rk Yat?r?m Fonlar?**: A Tipi, B Tipi
- **Alt?n**: 24 Ayar, 22 Ayar, Eski ?eyrek, Yeni ?eyrek, Yar?m, Tam
- **G?m??**: Gram cinsinden
- **Emtialar**: Petrol, Bak?r, vb.
- **D?viz**: TRY/USD, TRY/EUR, vb.
- **BES Fonlar?**: Bireysel Emeklilik Sistemi

### 2. Securities Tablosu G?ncellemeleri

Yeni kolonlar:
- `asset_type`: Varl?k t?r? (enum)
- `metadata`: JSONB - T?r bazl? ?zel bilgiler
  - Alt?n i?in: `{"purity": "24k", "weight": "gram", "form": "quarter"}`
  - BES i?in: `{"bes_company": "ABC", "fund_code": "123"}`
- `price_source_id`: Fiyat kayna?? referans?
- `isin`: ISIN kodu (uluslararas?)
- `cusip`: CUSIP kodu (ABD)

### 3. Yeni Tablolar

#### Asset Price Sources
Fiyat kaynaklar? ve API konfig?rasyonlar?:
- API endpoint'leri
- API key'ler
- G?ncelleme s?kl???
- Aktif/pasif durumu

#### Price Updates Log
Fiyat g?ncelleme loglar?:
- Eski/yeni fiyat
- G?ncelleme durumu
- Hata mesajlar?

#### BES Transactions
BES ?zel i?lemler:
- ??lem t?rleri: purchase, credit_card_purchase, fund_change, bulk_payment
- Fon de?i?tirme: from_fund_id, to_fund_id
- Kredi kart?: settlement_date (1 ay sonra)
- Toplu ?deme: Bulk payment kay?tlar?

#### Credit Card Transactions
Kredi kart? i?lemleri (tasarruf mod?l? i?in):
- ??lem t?rleri: purchase, payment, refund
- ?lgili transaction ba?lant?s? (portfolio, income_expense, bes)
- Settlement date takibi
- Gelir/gider mod?l? ile entegrasyon

### 4. Transactions Tablosu G?ncellemeleri

Yeni kolon:
- `payment_method`: cash, credit_card, bank_transfer, bes_bulk_payment

### 5. Portfolio Items Metadata

Yeni kolon:
- `metadata`: JSONB - Varl?k bazl? ?zel bilgiler
  - Alt?n i?in: `{"purity": "24k", "weight": 1.5, "form": "quarter"}`

## ?? Otomatik ??lemler

### 1. BES Kredi Kart? Settlement
- Kredi kart? ile yap?lan BES al?mlar? 1 ay sonra otomatik olarak settle edilir
- `check_bes_credit_card_settlement()` fonksiyonu

### 2. Kredi Kart? Transaction Settlement
- Kredi kart? i?lemleri i?in settlement date kontrol?
- `check_credit_card_settlement()` fonksiyonu

## ?? ?rnek Kullan?m Senaryolar?

### Senaryo 1: BIST Hisse Ekleme
```sql
INSERT INTO securities (symbol, name, asset_type, exchange, currency, price_source_id)
VALUES ('THYAO', 'T?rk Hava Yollar?', 'bist_stock', 'BIST', 'TRY', 
  (SELECT id FROM asset_price_sources WHERE name = 'BIST API'));
```

### Senaryo 2: Alt?n Ekleme (24 Ayar ?eyrek)
```sql
INSERT INTO securities (symbol, name, asset_type, currency, metadata)
VALUES ('GOLD_24K_Q', '24 Ayar ?eyrek Alt?n', 'gold_quarter_new', 'TRY',
  '{"purity": "24k", "weight": 1.75, "form": "quarter"}'::jsonb);
```

### Senaryo 3: BES Kredi Kart? ile Fon Alma
```sql
INSERT INTO bes_transactions (
  user_id, portfolio_item_id, transaction_type, 
  to_fund_id, amount, transaction_date, settlement_date, credit_card_id
)
VALUES (
  'user-uuid', 'portfolio-item-uuid', 'credit_card_purchase',
  'security-uuid', 1000.00, NOW(), NOW() + INTERVAL '1 month', 'credit-card-uuid'
);
```

### Senaryo 4: Fon De?i?tirme
```sql
INSERT INTO bes_transactions (
  user_id, portfolio_item_id, transaction_type,
  from_fund_id, to_fund_id, amount, transaction_date
)
VALUES (
  'user-uuid', 'portfolio-item-uuid', 'fund_change',
  'old-fund-uuid', 'new-fund-uuid', 5000.00, NOW()
);
```

## ?? Tablolar Aras? ?li?kiler

```
securities (1) ??> (N) portfolio_items
securities (1) ??> (N) transactions
securities (1) ??> (N) bes_transactions (from_fund_id/to_fund_id)
asset_price_sources (1) ??> (N) securities
credit_card_transactions (N) ??> (1) credit_cards
credit_card_transactions (N) ??> (1) transactions/income_expenses/bes_transactions
bes_transactions (N) ??> (1) credit_cards
```

## ?? Notlar

1. **Metadata JSONB**: Her varl?k t?r? i?in ?zelle?tirilmi? bilgiler saklan?r
2. **Price Sources**: Farkl? API'ler i?in ayr? kaynaklar tan?mlanabilir
3. **BES Settlement**: Kredi kart? al?mlar? 1 ay sonra otomatik settle edilir
4. **Credit Card Integration**: T?m kredi kart? i?lemleri tasarruf mod?l?ne ba?lan?r

## ?? Sonraki Ad?mlar

1. ? Database ?emas? g?ncellemesi tamamland?
2. ? Fiyat g?ncelleme sistemi implementasyonu (n8n/Supabase Functions)
3. ? BES mod?l? frontend geli?tirmesi
4. ? Kredi kart? entegrasyonu frontend geli?tirmesi
