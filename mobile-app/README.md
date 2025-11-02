# Finans Takip Uygulamas? - Proje Dok?mantasyonu

## ?? Proje ?zeti

Cross-platform finans takip uygulamas?. React Native + Expo ile geli?tirilmektedir.

## ?? Kurulum

### Gereksinimler

- Node.js 18+
- npm veya yarn
- Expo CLI
- Supabase hesab?

### Ad?mlar

1. **Environment Variables Ayarlama**

   `mobile-app/.env` dosyas? olu?turun:

   ```env
   EXPO_PUBLIC_SUPABASE_URL=your_supabase_url
   EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

2. **Supabase Database Kurulumu**

   `mobile-app/supabase/schema.sql` dosyas?n? Supabase SQL Editor'de ?al??t?r?n.

3. **Ba??ml?l?klar? Y?kleme**

   ```bash
   cd mobile-app
   npm install
   ```

4. **Uygulamay? ?al??t?rma**

   ```bash
   npm start
   ```

## ?? Proje Yap?s?

```
mobile-app/
??? src/
?   ??? components/          # Yeniden kullan?labilir componentler
?   ??? modules/              # Mod?ler yap?
?   ?   ??? auth/           # Authentication mod?l?
?   ?   ??? portfolio/      # Portf?y mod?l?
?   ?   ??? income-expense/ # Gelir/Gider mod?l?
?   ?   ??? dividend/       # Temett? mod?l?
?   ?   ??? debt/           # Bor? mod?l?
?   ?   ??? report/         # Raporlama mod?l?
?   ?   ??? watchlist/      # ?zleme listesi mod?l?
?   ?   ??? settings/       # Ayarlar mod?l?
?   ??? screens/            # Ekranlar
?   ??? navigation/         # Navigation yap?land?rmas?
?   ??? services/           # API servisleri
?   ??? store/              # State management
?   ??? types/              # TypeScript tipleri
?   ??? utils/              # Yard?mc? fonksiyonlar
?   ??? hooks/              # Custom hooks
?   ??? constants/          # Sabitler
??? supabase/
?   ??? schema.sql          # Database ?emas?
??? App.tsx                 # Ana uygulama dosyas?
```

## ??? Database ?emas?

### Temel Tablolar

- **users**: Kullan?c? profilleri
- **user_settings**: Kullan?c? ayarlar? ve mod?l durumlar?
- **portfolios**: Portf?yler
- **portfolio_items**: Portf?y ??eleri
- **transactions**: ??lemler
- **securities**: Menkul k?ymetler
- **income_expenses**: Gelir/gider kay?tlar?
- **categories**: Kategoriler
- **dividends**: Temett? kay?tlar?
- **credit_cards**: Kredi kartlar?
- **credits**: Krediler
- **debts**: Bor?lar
- **watchlist**: ?zleme listesi
- **price_alerts**: Fiyat alarmlar?
- **receipts**: Fatura/foto?raflar
- **reports**: ?nbelleklenmi? raporlar

Detayl? ?ema i?in `mobile-app/supabase/schema.sql` dosyas?na bak?n.

## ?? G?venlik

- Row Level Security (RLS) ile kullan?c? bazl? veri izolasyonu
- T?m tablolarda RLS politikalar? aktif
- Supabase Auth ile g?venli authentication

## ?? Mod?ller

### 1. Authentication Mod?l?
- Google Sign-In
- Apple Sign-In
- Email/Password

### 2. Portf?y Mod?l?
- Portf?y y?netimi
- Hisse ekleme/??karma
- Performans takibi
- Ger?ekle?mi?/ger?ekle?memi? karlar

### 3. Gelir/Gider Mod?l?
- Gelir kay?tlar?
- Gider kay?tlar?
- Kategori y?netimi
- AI ile foto?raftan harcama tan?ma

### 4. Temett? Mod?l?
- Temett? kay?tlar?
- Temett? takvimi
- Getiri analizi

### 5. Bor? Mod?l?
- Kredi kart? takibi
- Kredi takibi
- KMH hesaplama

### 6. Raporlama Mod?l?
- Zaman dilimi bazl? raporlar
- Grafikler
- Export ?zellikleri

### 7. ?zleme Listesi Mod?l?
- Favori hisseler
- Fiyat alarmlar?

### 8. Ayarlar Mod?l?
- Mod?l a?ma/kapama
- Kullan?c? ayarlar?

## ??? Teknolojiler

- **React Native**: UI framework
- **Expo**: Development tooling
- **Supabase**: Backend as a Service
- **React Query**: Server state management
- **Zustand**: Client state management
- **React Navigation**: Navigation
- **React Hook Form**: Form handling
- **Zod**: Schema validation

## ?? Geli?tirme Notlar?

- Mod?ler yap? sayesinde ?zellikler ba??ms?z geli?tirilebilir
- Supabase real-time ?zellikleri ile anl?k g?ncellemeler
- Offline support i?in AsyncStorage kullan?lacak
- AI entegrasyonu i?in Supabase Edge Functions kullan?lacak

## ?? Sonraki Ad?mlar

1. Authentication sistemi kurulumu
2. Temel navigation yap?s?
3. Portf?y mod?l? geli?tirme
4. Gelir/Gider mod?l? geli?tirme

## ?? Kaynaklar

- [Expo Dok?mantasyonu](https://docs.expo.dev/)
- [Supabase Dok?mantasyonu](https://supabase.com/docs)
- [React Navigation](https://reactnavigation.org/)
