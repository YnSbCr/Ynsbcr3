# ?oklu Para Birimi ve D?viz Kuru Sistemi - Dok?mantasyon

## ?? ?zellikler

### 1. ?oklu Para Birimi Deste?i
- ? ??lemler TL, USD veya EUR ile yap?labilir
- ? Her i?lem i?in para birimi se?ilebilir
- ? Kar/zarar hesaplamalar? her ?? para biriminde de yap?labilir

### 2. Tarihsel D?viz Kuru Takibi
- ? `exchange_rates` tablosu ile tarihsel kur kay?tlar?
- ? Her g?n i?in USD/TRY ve EUR/TRY kurlar? saklan?r
- ? Eksik tarihler i?in en yak?n tarihli kur kullan?l?r

### 3. Otomatik Kur Atama
- ? Transaction olu?turulurken otomatik kur ?ekme
- ? ??lem tarihindeki kur otomatik olarak kaydedilir
- ? Kullan?c? manuel olarak da girebilir

### 4. Kar/Zarar Hesaplamalar?
- ? TL cinsinden kar/zarar
- ? USD cinsinden kar/zarar
- ? EUR cinsinden kar/zarar
- ? Her birinde y?zde hesaplama

## ?? Kullan?m Senaryolar?

### Senaryo 1: TL ile ??lem Yapma
```sql
-- 3 A?ustos'ta 10 TL'lik hisse al?nd?
INSERT INTO transactions (
  portfolio_id, security_id, type, quantity, price, 
  total_amount, transaction_date, transaction_currency
) VALUES (
  'portfolio-uuid', 'security-uuid', 'buy', 1, 10.00, 10.00,
  '2024-08-03', 'TRY'
);

-- Otomatik olarak o g?nk? USD ve EUR kurlar? atan?r
-- exchange_rate_usd: 35.00 (?rnek)
-- exchange_rate_eur: 38.00 (?rnek)
```

### Senaryo 2: USD ile ??lem Yapma
```sql
-- USD ile i?lem yap?ld???nda, TL kar??l??? hesaplan?r
INSERT INTO transactions (
  portfolio_id, security_id, type, quantity, price,
  total_amount, transaction_date, transaction_currency,
  exchange_rate_usd
) VALUES (
  'portfolio-uuid', 'security-uuid', 'buy', 1, 0.2857, 0.2857,
  '2024-08-03', 'USD', 35.00
);

-- total_amount otomatik olarak TL kar??l???na ?evrilir (0.2857 * 35.00 = 10 TL)
```

### Senaryo 3: Kar/Zarar Hesaplama
```sql
-- TL cinsinden kar/zarar
SELECT * FROM calculate_profit_loss_tl('portfolio-item-uuid', 12.00);

-- USD cinsinden kar/zarar (mevcut kur: 36.00)
SELECT * FROM calculate_profit_loss_usd('portfolio-item-uuid', 12.00, 36.00);

-- EUR cinsinden kar/zarar (mevcut kur: 39.00)
SELECT * FROM calculate_profit_loss_eur('portfolio-item-uuid', 12.00, 39.00);
```

## ?? Otomatik ??lemler

### 1. Transaction Olu?turulurken
- ??lem tarihindeki kur otomatik ?ekilir
- E?er o g?nk? kur yoksa, en yak?n tarihli kur kullan?l?r
- USD ve EUR kurlar? otomatik atan?r

### 2. Portfolio Item G?ncellemesi
- Yeni transaction eklendi?inde, portfolio item'?n ortalama kurlar? g?ncellenir
- Ortalama kur, t?m al?m i?lemlerinin ortalamas?d?r

### 3. G?nl?k Kur G?ncellemesi
- TCMB API'den g?nl?k kurlar ?ekilir
- `exchange_rates` tablosuna kaydedilir
- n8n veya Supabase Functions ile otomatik yap?l?r

## ?? Kar/Zarar Hesaplama Mant???

### ?rnek:
**Al??**: 3 A?ustos, 10 TL, USD/TRY: 35.00, EUR/TRY: 38.00
**Sat??**: 15 A?ustos, 12 TL, USD/TRY: 36.00, EUR/TRY: 39.00

### TL Cinsinden:
- Kar: 12 - 10 = +2 TL
- Y?zde: %20

### USD Cinsinden:
- Al?? (USD): 10 / 35.00 = 0.2857 USD
- Sat?? (USD): 12 / 36.00 = 0.3333 USD
- Kar: 0.3333 - 0.2857 = +0.0476 USD
- Y?zde: %16.67

### EUR Cinsinden:
- Al?? (EUR): 10 / 38.00 = 0.2632 EUR
- Sat?? (EUR): 12 / 39.00 = 0.3077 EUR
- Kar: 0.3077 - 0.2632 = +0.0445 EUR
- Y?zde: %16.92

## ??? Database Yap?s?

### Exchange Rates Tablosu
```sql
CREATE TABLE exchange_rates (
  id UUID PRIMARY KEY,
  base_currency TEXT DEFAULT 'TRY',
  quote_currency TEXT CHECK (quote_currency IN ('USD', 'EUR', 'GBP', 'JPY')),
  rate DECIMAL(15, 6),
  rate_date DATE,
  source TEXT DEFAULT 'TCMB',
  UNIQUE(base_currency, quote_currency, rate_date)
);
```

### Transactions G?ncellemeleri
- `transaction_currency`: ??lem yap?lan para birimi
- `exchange_rate_usd`: ??lem an?ndaki USD/TRY kuru
- `exchange_rate_eur`: ??lem an?ndaki EUR/TRY kuru
- `exchange_rate_date`: Kur tarihi

### Portfolio Items G?ncellemeleri
- `base_currency`: Portf?y ??esinin base currency'si
- `average_exchange_rate_usd`: Ortalama USD kuru
- `average_exchange_rate_eur`: Ortalama EUR kuru

## ?? Fonksiyonlar

### 1. `get_exchange_rate()`
Belirli bir tarih i?in kur getirir (en yak?n tarihli kur)

### 2. `get_current_exchange_rate()`
G?ncel kur getirir

### 3. `calculate_profit_loss_tl()`
TL cinsinden kar/zarar hesaplar

### 4. `calculate_profit_loss_usd()`
USD cinsinden kar/zarar hesaplar

### 5. `calculate_profit_loss_eur()`
EUR cinsinden kar/zarar hesaplar

## ?? Kur G?ncelleme Stratejisi

### G?nl?k G?ncelleme
- TCMB API'den g?nl?k kurlar ?ekilir
- `exchange_rates` tablosuna kaydedilir
- Cron job veya scheduled function ile yap?l?r

### API Entegrasyonu
- TCMB API: https://www.tcmb.gov.tr/kurlar
- Alternatif: ExchangeRate-API, Fixer.io

## ?? Sonraki Ad?mlar

1. ? Database ?emas? g?ncellemesi tamamland?
2. ? TCMB API entegrasyonu
3. ? G?nl?k kur g?ncelleme servisi
4. ? Frontend para birimi se?imi
5. ? Kar/zarar g?r?nt?leme ekranlar?
