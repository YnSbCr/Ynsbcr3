# ?oklu Para Birimi ve D?viz Kuru Sistemi Tasar?m?

## Gereksinimler

### Ana Hedef
- Varl?k ekleme i?lemleri TL, Dolar ve Euro ?zerinden yap?labilmeli
- ??lem an?ndaki d?viz kurlar? kaydedilmeli
- Kar/zarar hesaplamalar? her ?? para biriminde de yap?labilmeli

### Senaryo ?rne?i
- 3 A?ustos'ta 10 TL'lik hisse eklendi
- O g?nk? USD/TRY ve EUR/TRY kurlar? kaydedilmeli
- Kar/zarar hesaplamalar?:
  - TL cinsinden: Basit fark
  - USD cinsinden: O g?nk? kur ile mevcut kur kar??la?t?rmas?
  - EUR cinsinden: O g?nk? kur ile mevcut kur kar??la?t?rmas?

## Tasar?m Kararlar?

### Se?enek 1: Her ??lemde Kur Kaydetme
**Avantajlar**:
- Basit ve anla??l?r
- Her i?lem i?in net kur bilgisi

**Dezavantajlar**:
- Her i?lemde kur bilgisi manuel girilmeli
- Kur de?i?iklikleri takip edilemez

### Se?enek 2: Merkezi Kur Tablosu + ??lemde Referans
**Avantajlar**:
- Tarihsel kur takibi
- Otomatik kur g?ncellemeleri
- Kur de?i?iklikleri analiz edilebilir

**Dezavantajlar**:
- Biraz daha karma??k

### Se?enek 3: Hibrit Yakla??m (?NER?LEN) ?
**Yap?**:
- `exchange_rates` tablosu: Tarihsel d?viz kurlar?
- Transactions tablosunda: ??lem an?ndaki kurlar (snapshot)
- Portfolio items tablosunda: Ortalama kur bilgisi
- Otomatik kur g?ncellemesi: n8n veya Supabase Functions ile

**Avantajlar**:
- Tarihsel kur takibi
- ??lem an?ndaki kur snapshot'?
- Kar/zarar hesaplamalar? i?in esneklik
- Otomatik kur g?ncellemeleri

## Database ?emas? De?i?iklikleri

### 1. Exchange Rates Tablosu
Tarihsel d?viz kurlar?n? saklar:
- Tarih
- Base currency (TRY)
- Quote currency (USD, EUR)
- Kur de?eri
- Kaynak (TCMB, API, vb.)

### 2. Transactions Tablosu G?ncellemeleri
- `transaction_currency`: ??lem yap?lan para birimi (TRY, USD, EUR)
- `exchange_rate_usd`: ??lem an?ndaki USD/TRY kuru
- `exchange_rate_eur`: ??lem an?ndaki EUR/TRY kuru
- `exchange_rate_date`: Kur tarihi

### 3. Portfolio Items G?ncellemeleri
- `base_currency`: Portf?y ??esinin base currency'si
- `average_exchange_rate_usd`: Ortalama USD kuru
- `average_exchange_rate_eur`: Ortalama EUR kuru

### 4. Kar/Zarar Hesaplama Fonksiyonlar?
- `calculate_profit_loss_tl()`: TL cinsinden kar/zarar
- `calculate_profit_loss_usd()`: USD cinsinden kar/zarar
- `calculate_profit_loss_eur()`: EUR cinsinden kar/zarar

## Kur G?ncelleme Stratejisi

### G?nl?k Kur G?ncellemesi
- TCMB API'den g?nl?k kurlar ?ekilir
- `exchange_rates` tablosuna kaydedilir
- Mevcut kurlar g?ncellenir

### ??lem S?ras?nda Kur ?ekme
- Transaction olu?turulurken o g?nk? kurlar otomatik ?ekilir
- E?er o g?nk? kur yoksa, en yak?n tarihli kur kullan?l?r
- Kullan?c? manuel olarak da girebilir

## Kar/Zarar Hesaplama Mant???

### ?rnek Senaryo:
1. **3 A?ustos**: 10 TL'lik hisse al?nd? (USD/TRY: 35.00, EUR/TRY: 38.00)
2. **15 A?ustos**: Fiyat 12 TL oldu (USD/TRY: 36.00, EUR/TRY: 39.00)

### Kar/Zarar Hesaplamalar?:
- **TL**: 12 - 10 = +2 TL (%20 kar)
- **USD**: 
  - Al??: 10 / 35.00 = 0.2857 USD
  - Sat??: 12 / 36.00 = 0.3333 USD
  - Kar: 0.3333 - 0.2857 = 0.0476 USD (%16.67 kar)
- **EUR**:
  - Al??: 10 / 38.00 = 0.2632 EUR
  - Sat??: 12 / 39.00 = 0.3077 EUR
  - Kar: 0.3077 - 0.2632 = 0.0445 EUR (%16.92 kar)

## Kur Kayna?? Entegrasyonu

### TCMB (T?rkiye Cumhuriyet Merkez Bankas?)
- Resmi kur kayna??
- G?nl?k kurlar
- API: https://www.tcmb.gov.tr/kurlar

### Alternatif Kaynaklar
- ExchangeRate-API
- Fixer.io
- CurrencyLayer

## ?nerilen Yap?

### Exchange Rates Tablosu
```sql
CREATE TABLE exchange_rates (
  id UUID PRIMARY KEY,
  base_currency TEXT NOT NULL, -- TRY
  quote_currency TEXT NOT NULL, -- USD, EUR
  rate DECIMAL(15, 6) NOT NULL,
  rate_date DATE NOT NULL,
  source TEXT NOT NULL, -- TCMB, API, manual
  created_at TIMESTAMP,
  UNIQUE(base_currency, quote_currency, rate_date)
);
```

### Transactions G?ncellemeleri
```sql
ALTER TABLE transactions ADD COLUMN:
- transaction_currency TEXT, -- TRY, USD, EUR
- exchange_rate_usd DECIMAL(15, 6),
- exchange_rate_eur DECIMAL(15, 6),
- exchange_rate_date DATE
```

### Portfolio Items G?ncellemeleri
```sql
ALTER TABLE portfolio_items ADD COLUMN:
- base_currency TEXT DEFAULT 'TRY',
- average_exchange_rate_usd DECIMAL(15, 6),
- average_exchange_rate_eur DECIMAL(15, 6)
```

## Sonraki Ad?mlar

1. ? ?oklu para birimi sistemi tasar?m? tamamland?
2. ? Database ?emas? g?ncellemesi
3. ? Kur g?ncelleme fonksiyonlar?
4. ? Kar/zarar hesaplama fonksiyonlar?
5. ? Frontend para birimi se?imi
