# Kripto Varl?klar ve Geli?mi? Arama Sistemi Tasar?m?

## Gereksinimler

### Ana Hedefler
1. Varl?k eklerken t?rlere g?re se?im yap?lacak
2. Tarih se?imi olacak
3. Varl?k sembol veya isim ile aranacak ve otomatik gelmeli
4. Kripto varl?klar? desteklenecek (BTC/USDT, BTC/TL gibi)
5. Kriptolar ?ift para birimi ile hesaplanacak
6. Platform bilgisi opsiyonel olarak kaydedilecek

## Kripto Varl?k Sistemi

### ?ift Para Birimi Yap?s?
Kripto varl?klar i?in base/quote currency sistemi:
- **BTC/USDT**: Bitcoin (base) / Tether (quote)
- **BTC/TRY**: Bitcoin (base) / T?rk Liras? (quote)
- **ETH/USDT**: Ethereum (base) / Tether (quote)
- **ETH/TRY**: Ethereum (base) / T?rk Liras? (quote)

### Platform Bilgisi
- Binance
- Coinbase
- Paribu
- BtcTurk
- Binance TR
- Di?er

### Hesaplama Mant???
- Kripto varl?klar i?in fiyat, quote currency cinsinden tutulur
- ?rnek: BTC/USDT = 45,000 USDT
- ?rnek: BTC/TRY = 1,575,000 TRY
- Kar/zarar hesaplamalar? quote currency cinsinden yap?l?r

## Database ?emas? De?i?iklikleri

### 1. Asset Types Enum G?ncellemesi
```sql
-- Kripto varl?k t?rleri ekle
'crypto_usdt',    -- Kripto/USDT ?iftleri
'crypto_try',    -- Kripto/TRY ?iftleri
'crypto_btc',    -- Altcoin/BTC ?iftleri
'crypto_eth'     -- Altcoin/ETH ?iftleri
```

### 2. Securities Tablosu G?ncellemeleri
- `base_currency`: Kripto i?in base currency (BTC, ETH, vb.)
- `quote_currency`: Kripto i?in quote currency (USDT, TRY, vb.)
- `platform`: Platform bilgisi (Binance, Coinbase, vb.)
- `search_vector`: Full-text search i?in

### 3. Arama Sistemi
- PostgreSQL Full-Text Search kullan?lacak
- Symbol ve name alanlar?nda arama
- Otomatik tamamlama i?in materialized view

## Otomatik Veri ?ekme

### API Entegrasyonlar?
1. **Kripto Fiyatlar?**:
   - CoinGecko API
   - Binance API
   - CryptoCompare API

2. **BIST Hisseleri**:
   - Borsa ?stanbul API
   - Yahoo Finance

3. **ABD Hisseleri**:
   - Yahoo Finance
   - Alpha Vantage

4. **Alt?n/D?viz**:
   - TCMB API
   - Alt?n fiyat API'leri

### Veri ?ekme Stratejisi
1. Kullan?c? sembol/isim ile arama yapar
2. API'den otomatik veri ?ekilir
3. Securities tablosuna kaydedilir veya g?ncellenir
4. Kullan?c?ya g?sterilir

## Frontend Tasar?m

### Varl?k Ekleme Ekran? Ak???

```
1. Varl?k T?r? Se?imi
   ??? BIST Hisseleri
   ??? ABD Hisseleri
   ??? ETF'ler
   ??? Yat?r?m Fonlar?
   ??? Alt?n
   ??? G?m??
   ??? Emtialar
   ??? D?viz
   ??? BES Fonlar?
   ??? Kripto Varl?klar ? YEN?

2. Kripto Se?ildi?inde:
   ??? Base Currency Se?imi (BTC, ETH, vb.)
   ??? Quote Currency Se?imi (USDT, TRY, BTC, ETH)
   ??? Platform Se?imi (Opsiyonel)

3. Arama Kutusu
   ??? Sembol veya ?sim ile Arama
   ??? Otomatik Tamamlama
   ??? API'den Otomatik Veri ?ekme

4. Tarih Se?imi
   ??? ??lem Tarihi

5. Miktar ve Fiyat Giri?i
```

## Tasar?m Kararlar?

### Se?enek 1: Ayr? Crypto Tablosu
**Avantajlar**: ?zelle?tirilmi? alanlar
**Dezavantajlar**: ?ok fazla tablo, JOIN karma??kl???

### Se?enek 2: Securities Tablosunda Geni?letme (?NER?LEN) ?
**Avantajlar**:
- Tek tablo, basit sorgular
- JSONB metadata ile esneklik
- Full-text search kolay

**Dezavantajlar**: Biraz daha karma??k metadata

### Se?enek 3: Hibrit Yakla??m
**Yap?**:
- Securities tablosu geni?letilmi?
- Crypto-specific metadata JSONB i?inde
- Platform bilgisi ayr? kolon

## ?nerilen Database Yap?s?

### Securities Tablosu G?ncellemeleri
```sql
ALTER TABLE securities ADD COLUMN:
- base_currency TEXT,        -- BTC, ETH, vb. (kripto i?in)
- quote_currency TEXT,       -- USDT, TRY, vb. (kripto i?in)
- platform TEXT,             -- Binance, Coinbase, vb.
- search_vector tsvector,    -- Full-text search i?in
- api_source TEXT,           -- Veri kayna?? API
- last_api_fetch TIMESTAMP   -- Son API ?a?r?s?
```

### Arama ?ndeksi
```sql
CREATE INDEX idx_securities_search ON securities USING GIN(search_vector);
```

### Otomatik Tamamlama Materialized View
```sql
CREATE MATERIALIZED VIEW securities_search AS
SELECT 
  id,
  symbol,
  name,
  asset_type,
  base_currency,
  quote_currency,
  platform,
  search_vector
FROM securities;
```

## Kripto Hesaplama ?rnekleri

### Senaryo: BTC/USDT Al?m?
```
- Al??: 1 BTC @ 45,000 USDT
- Sat??: 1 BTC @ 50,000 USDT
- Kar: 5,000 USDT
```

### Senaryo: BTC/TRY Al?m?
```
- Al??: 1 BTC @ 1,575,000 TRY
- Sat??: 1 BTC @ 1,750,000 TRY
- Kar: 175,000 TRY
```

### Senaryo: ETH/BTC Al?m? (Altcoin)
```
- Al??: 10 ETH @ 0.065 BTC
- Sat??: 10 ETH @ 0.070 BTC
- Kar: 0.05 BTC
```

## API Entegrasyon Stratejisi

### 1. Arama S?ras?nda
- Kullan?c? sembol/isim yazar
- API'den otomatik veri ?ekilir
- E?er veritaban?nda yoksa, otomatik eklenir
- E?er varsa, fiyat g?ncellenir

### 2. Varl?k Listesi
- T?r bazl? filtreleme
- Arama sonu?lar?
- Otomatik tamamlama

### 3. Fiyat G?ncellemeleri
- Periyodik fiyat g?ncellemeleri
- Real-time fiyat g?ncellemeleri (opsiyonel)

## Sonraki Ad?mlar

1. ? Kripto varl?k sistemi tasar?m? tamamland?
2. ? Database ?emas? g?ncellemesi
3. ? Full-text search implementasyonu
4. ? API entegrasyonu tasar?m?
5. ? Frontend ekran tasar?m?
