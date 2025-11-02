# Finans Takip Uygulamas? - Proje ?zeti

## Proje Vizyonu

Kapsaml?, cross-platform finans takip uygulamas?. ?ncelik mobil uygulama (React Native + Expo), gelecekte web ve desktop deste?i.

## Temel ?zellikler

### 1. Portf?y Takibi
- Menkul k?ymet portf?y? takibi
- Ger?ekle?mi?/ger?ekle?memi? karlar
- Zaman dilimlerine g?re performans analizi
- Anl?k fiyat g?ncellemeleri

### 2. Gelir/Gider Takibi
- Gelir kay?tlar?
- Gider kay?tlar?
- Tasarruf hesaplama (Gelir - Gider)
- Kategori bazl? takip

### 3. Temett? Takibi
- Temett? gelirleri
- Temett? tarihleri
- Temett? getirisi analizi

### 4. Bor?/Kredi Takibi
- Kredi kart? bor?lar?
- Kredi takibi
- KMH (Kredi Maliyet Hesaplama) bor?lar?
- ?deme planlar?

### 5. Raporlama
- Zaman dilimlerine g?re karlar
- Gelir/gider raporlar?
- Portf?y performans raporlar?
- ?zelle?tirilebilir raporlar

### 6. Mod?ler Yap?
- ?zleme listesi mod?l?
- Portf?y takip mod?l?
- Tasarruf mod?l?
- Raporlama mod?l?
- Mod?ller a??l?p kapat?labilir

### 7. AI ?zellikleri
- Foto?raftan harcama tan?ma
- OCR ile fatura okuma
- Otomatik kategori tan?ma

### 8. Authentication
- Google ile giri?
- Apple ile giri?
- Email/Password giri?

## Teknoloji Stack

### Frontend (Mobil)
- **Framework**: React Native
- **Tooling**: Expo
- **State Management**: React Query / Zustand
- **UI Library**: React Native Paper / NativeBase
- **Navigation**: React Navigation

### Backend
- **BaaS**: Supabase
  - PostgreSQL Database
  - Authentication
  - Real-time subscriptions
  - Storage (foto?raflar i?in)
  - Edge Functions (AI i?lemleri i?in)

### Ek ?zellikler
- **API Entegrasyonlar?**: Finansal veri API'leri (fiyat g?ncellemeleri)
- **AI/ML**: Supabase Edge Functions + OpenAI Vision API veya benzeri
- **Push Notifications**: Expo Notifications

## Platform Deste?i

### Faz 1 (?lk ?ncelik)
- ? iOS
- ? Android
- ? Tablet (iOS/Android)

### Faz 2 (Gelecek)
- ? Web (React Native Web)
- ? macOS
- ? Windows
- ? Linux

## Mod?l Yap?s?

1. **Portf?y Mod?l?**
   - Portf?y g?r?nt?leme
   - Hisse ekleme/??karma
   - Performans takibi
   - Ger?ekle?mi?/ger?ekle?memi? karlar

2. **Gelir/Gider Mod?l?**
   - Gelir kay?tlar?
   - Gider kay?tlar?
   - Kategori y?netimi
   - Tasarruf hesaplama

3. **Temett? Mod?l?**
   - Temett? kay?tlar?
   - Temett? takvimi
   - Getiri analizi

4. **Bor?/Kredi Mod?l?**
   - Kredi kart? takibi
   - Kredi takibi
   - ?deme planlar?
   - KMH hesaplama

5. **Raporlama Mod?l?**
   - Zaman dilimi bazl? raporlar
   - Grafikler ve g?rselle?tirmeler
   - Export ?zellikleri

6. **?zleme Listesi Mod?l?**
   - Favori hisseler
   - Fiyat alarmlar?
   - Anl?k fiyat takibi

7. **Ayarlar Mod?l?**
   - Mod?l a?ma/kapama
   - Kullan?c? ayarlar?
   - Bildirim ayarlar?

## Database ?emas? (?n Tasar?m)

### Core Tables
- `users` - Kullan?c?lar (Supabase Auth ile entegre)
- `user_settings` - Kullan?c? ayarlar? ve mod?l durumlar?
- `portfolios` - Portf?yler
- `portfolio_items` - Portf?y ??eleri (hisseler)
- `transactions` - ??lemler (al?m/sat?m)
- `income_expenses` - Gelir/gider kay?tlar?
- `categories` - Kategoriler
- `dividends` - Temett? kay?tlar?
- `debts` - Bor?lar
- `credit_cards` - Kredi kartlar?
- `credits` - Krediler
- `reports` - Raporlar (cache)
- `watchlist` - ?zleme listesi
- `price_alerts` - Fiyat alarmlar?
- `receipts` - Fatura/foto?raflar (AI i?leme i?in)

## G?venlik ve Gizlilik

- Supabase Row Level Security (RLS)
- Kullan?c? bazl? veri izolasyonu
- ?ifreli veri saklama (gerekirse)
- GDPR uyumlu veri y?netimi

## Performans Hedefleri

- ?lk y?kleme: < 2 saniye
- Veri senkronizasyonu: Ger?ek zamanl?
- Offline destek: Temel ?zellikler offline ?al??abilir
- Push notifications: Anl?k bildirimler

## Geli?tirme Fazlar?

### Faz 1: Temel Altyap?
- Expo proje kurulumu
- Supabase entegrasyonu
- Authentication sistemi
- Temel navigation

### Faz 2: Core Mod?ller
- Portf?y mod?l?
- Gelir/gider mod?l?
- Temel UI/UX

### Faz 3: Geli?mi? ?zellikler
- Raporlama
- AI entegrasyonu
- Push notifications
- Anl?k fiyat g?ncellemeleri

### Faz 4: Optimizasyon
- Performance iyile?tirmeleri
- Offline support
- Cross-platform optimizasyon

## Notlar

- Mod?ler yap? sayesinde ?zellikler ba??ms?z geli?tirilebilir
- Supabase real-time ?zellikleri ile anl?k g?ncellemeler
- Expo ile kolay deployment
- Future-proof mimari ile web/desktop deste?i kolay eklenebilir
