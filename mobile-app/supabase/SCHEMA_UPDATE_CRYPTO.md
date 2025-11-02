# Kripto Varl?klar ve Geli?mi? Arama Sistemi - Dok?mantasyon

## ?? ?zellikler

### 1. Kripto Varl?k Deste?i ?
- **?ift Para Birimi**: BTC/USDT, BTC/TRY, ETH/USDT, vb.
- **Platform Bilgisi**: Binance, Coinbase, Paribu, BtcTurk, vb.
- **Base/Quote Currency**: Kripto ?iftleri i?in ?zel yap?

### 2. Geli?mi? Arama Sistemi ?
- **Sembol/?sim ile Arama**: Full-text search
- **Otomatik Tamamlama**: Materialized view ile h?zl? arama
- **T?r Bazl? Filtreleme**: Asset type'a g?re filtreleme
- **T?rk?e Deste?i**: PostgreSQL Turkish full-text search

### 3. Otomatik Veri ?ekme ?
- **API Entegrasyonu**: CoinGecko, Binance, vb.
- **Otomatik Ekleme**: Arama s?ras?nda otomatik veri ?ekme
- **Fiyat G?ncelleme**: Periyodik fiyat g?ncellemeleri

## ??? Database Yap?s?

### Securities Tablosu G?ncellemeleri

#### Yeni Kolonlar
- `base_currency`: BTC, ETH, vb. (kripto i?in)
- `quote_currency`: USDT, TRY, BTC, ETH (kripto i?in)
- `platform`: Binance, Coinbase, Paribu, BtcTurk, vb.
- `api_source`: Veri kayna?? API
- `last_api_fetch`: Son API ?a?r?s? zaman?
- `search_vector`: Full-text search i?in tsvector
- `is_active`: Aktif/pasif durumu

### Arama Sistemi

#### Full-Text Search
- PostgreSQL `tsvector` kullan?l?yor
- T?rk?e dil deste?i
- Sembol, isim, base/quote currency'de arama

#### Materialized View
- `securities_search_cache`: H?zl? arama i?in cache
- Otomatik yenileme fonksiyonu
- Index'lenmi? arama

## ?? Arama Fonksiyonlar?

### 1. `search_securities()`
Genel arama fonksiyonu:
```sql
SELECT * FROM search_securities('bitcoin', 'crypto_usdt', 20);
```

### 2. `search_crypto_pairs()`
Kripto ?iftleri i?in ?zel arama:
```sql
SELECT * FROM search_crypto_pairs('BTC', 'USDT', 10);
```

### 3. `fetch_security_data()`
API'den otomatik veri ?ekme:
```sql
SELECT fetch_security_data('BTC/USDT', 'crypto_usdt', 'BTC', 'USDT');
```

## ?? Kripto Varl?k T?rleri

### Asset Types
- `crypto_usdt`: Kripto/USDT ?iftleri (BTC/USDT, ETH/USDT)
- `crypto_try`: Kripto/TRY ?iftleri (BTC/TRY, ETH/TRY)
- `crypto_btc`: Altcoin/BTC ?iftleri (ETH/BTC, ADA/BTC)
- `crypto_eth`: Altcoin/ETH ?iftleri (MATIC/ETH)

### Desteklenen Platformlar
- Binance
- Binance TR
- Coinbase
- Paribu
- BtcTurk
- Di?er

## ?? Kullan?m Senaryolar?

### Senaryo 1: BTC/USDT Ekleme
```sql
-- Kullan?c? "BTC" arar
SELECT * FROM search_securities('BTC', 'crypto_usdt');

-- Sonu?: BTC/USDT, BTC/TRY, ETH/BTC ?iftleri g?sterilir

-- Kullan?c? BTC/USDT se?er
-- Platform: Binance se?ilir
-- Transaction olu?turulur
```

### Senaryo 2: Otomatik Veri ?ekme
```sql
-- Kullan?c? "DOGE" arar ama veritaban?nda yok
-- Otomatik olarak API'den ?ekilir
SELECT fetch_security_data('DOGE/USDT', 'crypto_usdt', 'DOGE', 'USDT');

-- Yeni security olu?turulur ve fiyat g?ncellenir
```

### Senaryo 3: Platform Bazl? Filtreleme
```sql
-- Sadece Binance'deki BTC ?iftlerini getir
SELECT * FROM securities
WHERE base_currency = 'BTC'
  AND platform = 'Binance'
  AND asset_type IN ('crypto_usdt', 'crypto_try');
```

## ?? Frontend Ak???

### Varl?k Ekleme Ekran?

```
1. Varl?k T?r? Se?imi
   ??? Dropdown veya Tab Men?
       ??? BIST Hisseleri
       ??? ABD Hisseleri
       ??? ...
       ??? Kripto Varl?klar ?

2. Kripto Se?ildi?inde:
   ??? Base Currency Se?imi (BTC, ETH, DOGE, vb.)
   ??? Quote Currency Se?imi (USDT, TRY, BTC, ETH)
   ??? Platform Se?imi (Opsiyonel)

3. Arama Kutusu
   ??? Sembol veya ?sim ile Arama
   ??? Otomatik Tamamlama (Dropdown)
   ??? API'den Otomatik Veri ?ekme

4. Sonu?lar
   ??? E?le?en varl?klar listelenir
   ??? Platform bilgisi g?sterilir
   ??? Fiyat bilgisi g?sterilir

5. Tarih Se?imi
   ??? ??lem Tarihi

6. Miktar ve Fiyat Giri?i
```

## ?? API Entegrasyonu

### CoinGecko API
- Endpoint: `https://api.coingecko.com/api/v3`
- Kripto fiyatlar? ve bilgileri
- ?cretsiz tier mevcut

### Binance API
- Endpoint: `https://api.binance.com/api/v3`
- Spot fiyatlar?
- Real-time data

### Paribu API
- T?rk kripto borsas?
- TRY ?iftleri i?in

### BtcTurk API
- T?rk kripto borsas?
- TRY ?iftleri i?in

## ?? Migration S?ras?

1. ? `schema.sql` - Temel ?ema
2. ? `migration_portfolio_assets.sql` - Varl?k t?rleri
3. ? `migration_currency_system.sql` - D?viz kuru sistemi
4. ? `migration_crypto_assets.sql` - Kripto ve arama sistemi

## ?? Performans Optimizasyonlar?

### Indexes
- Full-text search index (GIN)
- Sembol ve isim indexleri
- Base/quote currency indexleri
- Platform indexi

### Materialized View
- Search cache i?in materialized view
- Periyodik yenileme (scheduled job)
- Concurrent refresh deste?i

## ?? Sonraki Ad?mlar

1. ? Database ?emas? g?ncellemesi tamamland?
2. ? Frontend varl?k ekleme ekran?
3. ? API entegrasyonu implementasyonu
4. ? Otomatik tamamlama implementasyonu
5. ? Platform se?imi UI
