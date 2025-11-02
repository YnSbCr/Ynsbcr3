# Portf?y Mod?l? - Varl?k T?rleri ve Sistem Tasar?m?

## Varl?k T?rleri Analizi

### 1. Hisseler
- **BIST Hisseleri**: Borsa ?stanbul'da i?lem g?ren hisseler
- **ABD Hisseleri**: NYSE, NASDAQ'da i?lem g?ren hisseler
- **Fiyat Kayna??**: BIST i?in Borsa ?stanbul API, ABD i?in Yahoo Finance veya Alpha Vantage

### 2. ETF'ler
- **T?rk ETF'leri**: BIST'te i?lem g?ren ETF'ler
- **ABD ETF'leri**: NYSE, NASDAQ ETF'leri
- **Fiyat Kayna??**: Ayn? hisse API'leri

### 3. Yat?r?m Fonlar?
- **T?rk Yat?r?m Fonlar?**: A Tipi, B Tipi fonlar
- **Fiyat Kayna??**: MKK (Merkezi Kay?t Kurulu?u) API veya manuel g?ncelleme

### 4. De?erli Madenler
- **Alt?n**:
  - 24 Ayar (Gram, ?eyrek, Yar?m, Tam)
  - 22 Ayar (Gram, ?eyrek, Yar?m, Tam)
  - Eski ?eyrek, Yeni ?eyrek
  - Fiyat Kayna??: Alt?n fiyatlar? API (CBRT veya ?zel API)
- **G?m??**:
  - Gram cinsinden
  - Fiyat Kayna??: Emtia fiyat API'leri

### 5. Emtialar
- Petrol, Bak?r, vb.
- Fiyat Kayna??: Emtia fiyat API'leri

### 6. D?viz
- TRY/USD, TRY/EUR, vb.
- Fiyat Kayna??: TCMB API veya D?viz API'leri

### 7. BES (Bireysel Emeklilik Sistemi)
- **?zellikler**:
  - Fon de?i?tirme i?lemleri
  - Kredi kart? ile fon alma
  - Kredi kart? al?mlar? 1 ay sonra sisteme ge?iyor
  - Toplu ?deme ?zelli?i
  - Fiyat Kayna??: BES ?irketleri API'leri veya manuel

## Tasar?m Kararlar?

### Se?enek 1: Tek Securities Tablosu (Geni?letilmi?)
**Avantajlar**:
- Tek tablo, basit sorgular
- Ortak alanlar (symbol, name, price)

**Dezavantajlar**:
- Farkl? varl?k t?rleri i?in ?ok fazla NULL alan
- Esneklik az
- Alt?n t?rleri (24/22 ayar) i?in karma??k

### Se?enek 2: Asset Type Tablosu + ?zelle?tirilmi? Tablolar
**Avantajlar**:
- Her varl?k t?r? i?in ?zelle?tirilmi? alanlar
- Tip g?venli?i
- Esnek yap?

**Dezavantajlar**:
- ?ok fazla tablo
- JOIN i?lemleri karma??k

### Se?enek 3: Hibrit Yakla??m (?NER?LEN) ?
**Yap?**:
- `securities` tablosu: Temel bilgiler (symbol, name, type, current_price)
- `asset_types` tablosu: Varl?k t?rleri enum
- `asset_metadata` JSONB tablosu: T?r bazl? ?zelle?tirilmi? bilgiler
- `asset_price_sources` tablosu: Fiyat kaynaklar? ve API konfig?rasyonlar?

**Avantajlar**:
- Esnek ve geni?letilebilir
- Her varl?k t?r? i?in ?zelle?tirilmi? alanlar (JSONB i?inde)
- Fiyat kayna?? y?netimi kolay
- Performansl? sorgular

## BES ?zel Gereksinimleri

### BES ??lem Tipleri
1. **Fon Alma**: Normal yat?r?m
2. **Kredi Kart? ile Fon Alma**: 1 ay sonra sisteme ge?iyor
3. **Fon De?i?tirme**: Bir fondan di?erine ge?i?
4. **Toplu ?deme**: D?zenli ?deme plan?

### Tasar?m Kararlar?

**Se?enek A**: BES Transactions Tablosu
- BES i?lemleri i?in ayr? tablo
- ??lem t?r?: enum (purchase, credit_card_purchase, fund_change, bulk_payment)
- Credit card purchase i?in `settlement_date` alan? (1 ay sonra)

**Se?enek B**: Genel Transactions + BES Metadata
- Mevcut transactions tablosunu kullan
- BES ?zel bilgileri JSONB metadata i?inde

**?NER?LEN**: Se?enek A ?
- BES i?lemleri ?zel durumlar i?eriyor
- Credit card settlement date takibi kritik
- Ayr? tablo ile daha net sorgular

## Kredi Kart? Entegrasyonu

### Gereksinimler
- Kredi kart? ile yap?lan al?mlar tasarruf mod?l?ne ba?lanmal?
- BES kredi kart? al?mlar? tasarruf mod?l?nde g?r?nmeli
- Di?er varl?k al?mlar? (alt?n, d?viz) kredi kart? ile yap?labilir

### Tasar?m Kararlar?

**Se?enek 1**: Credit Card Transactions Tablosu
- T?m kredi kart? i?lemleri tek yerde
- Income/Expense mod?l? ile ba?lant?

**Se?enek 2**: Transactions i?inde credit_card flag
- Basit ama yeterli

**?NER?LEN**: Se?enek 1 + Se?enek 2 Hibrit ?
- `transactions` tablosunda `payment_method` enum (cash, credit_card, bank_transfer)
- `credit_card_transactions` tablosu: Kredi kart? ?zel bilgileri
- Income/Expense mod?l? ile `credit_card_transactions` ?zerinden ba?lant?

## Fiyat G?ncelleme Sistemi

### Se?enek 1: Supabase Edge Functions
**Avantajlar**:
- Supabase ekosistemi i?inde
- Kolay deployment
- Otomatik cron job

**Dezavantajlar**:
- API rate limit y?netimi karma??k
- ?ok fazla API entegrasyonu i?in s?n?rl?

### Se?enek 2: n8n Workflow
**Avantajlar**:
- Visual workflow editor
- ?ok fazla API entegrasyonu
- Rate limiting ve error handling kolay
- Hibrit sistem kurulumu kolay

**Dezavantajlar**:
- Ek servis gereksinimi
- Deployment y?netimi

### Se?enek 3: Hibrit Sistem (?NER?LEN) ?
**Yap?**:
- **n8n**: API ?a?r?lar?, data processing, rate limiting
- **Supabase Functions**: n8n'den gelen verileri Supabase'e yazma
- **Supabase Database**: Fiyat verilerini saklama

**Avantajlar**:
- Her ara? kendi g??l? y?nlerinde kullan?l?yor
- ?l?eklenebilir
- Bak?m? kolay

## ?nerilen Database ?emas? De?i?iklikleri

### 1. Asset Types Enum
```sql
CREATE TYPE asset_type AS ENUM (
  'bist_stock',
  'us_stock',
  'etf',
  'mutual_fund',
  'gold_24k',
  'gold_22k',
  'silver',
  'commodity',
  'currency',
  'bes_fund'
);
```

### 2. Securities Tablosu G?ncellemesi
- `asset_type` kolonu ekle
- `currency` kolonu ekle
- `exchange` kolonu ekle
- `metadata` JSONB kolonu ekle (t?r bazl? ?zel bilgiler)

### 3. Yeni Tablolar
- `asset_price_sources`: API konfig?rasyonlar?
- `bes_transactions`: BES ?zel i?lemler
- `credit_card_transactions`: Kredi kart? i?lemleri
- `price_updates`: Fiyat g?ncelleme loglar?

## Sonraki Ad?mlar

1. ? Varl?k t?rleri analizi tamamland?
2. ? Database ?emas? g?ncellemesi
3. ? Fiyat g?ncelleme sistemi mimarisi
4. ? BES mod?l? detayl? tasar?m?
5. ? Kredi kart? entegrasyonu detayl? tasar?m?
