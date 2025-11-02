# Finans Takip Uygulamas? - Kurulum ?zeti

## ? Tamamlanan ??ler

### 1. Proje Kurulumu
- ? Expo projesi olu?turuldu (TypeScript template)
- ? Temel klas?r yap?s? olu?turuldu
- ? Gerekli paketler kuruldu

### 2. Konfig?rasyon Dosyalar?
- ? Supabase konfig?rasyon dosyas? (`src/services/supabase.ts`)
- ? Environment variables ?rne?i (`.env.example`)
- ? Proje dok?mantasyonu (`README.md`)

### 3. Database ?emas?
- ? Detayl? SQL ?emas? tasarland?
- ? Row Level Security (RLS) politikalar? haz?rland?
- ? Indexler ve trigger'lar eklendi

### 4. Proje Yap?s?
```
mobile-app/
??? src/
?   ??? components/          ?
?   ??? modules/              ?
?   ?   ??? auth/           ?
?   ?   ??? portfolio/      ?
?   ?   ??? income-expense/ ?
?   ?   ??? dividend/       ?
?   ?   ??? debt/           ?
?   ?   ??? report/         ?
?   ?   ??? watchlist/      ?
?   ?   ??? settings/       ?
?   ??? screens/            ?
?   ??? navigation/         ?
?   ??? services/           ?
?   ??? store/              ?
?   ??? types/              ?
?   ??? utils/              ?
?   ??? hooks/              ?
?   ??? constants/          ?
??? supabase/               ?
```

## ?? Yap?lmas? Gerekenler

### Hemen Yap?lacaklar

1. **Supabase Projesi Olu?turma**
   - Supabase hesab? olu?turun
   - Yeni proje olu?turun
   - `.env` dosyas?n? olu?turup credentials'lar? ekleyin

2. **Database Kurulumu**
   - `mobile-app/supabase/schema.sql` dosyas?n? Supabase SQL Editor'de ?al??t?r?n
   - Tablolar?n olu?turuldu?unu kontrol edin
   - RLS politikalar?n?n aktif oldu?unu kontrol edin

3. **Authentication Kurulumu**
   - Google Sign-In i?in OAuth ayarlar?
   - Apple Sign-In i?in OAuth ayarlar?
   - Supabase Auth konfig?rasyonu

### Sonraki Ad?mlar

4. **Temel Navigation Yap?s?**
   - React Navigation kurulumu
   - Stack Navigator
   - Tab Navigator
   - Auth flow

5. **Authentication Mod?l?**
   - Login screen
   - Sign up screen
   - Google/Apple Sign-In entegrasyonu

6. **Settings Mod?l?**
   - Mod?l a?ma/kapama ?zelli?i
   - Kullan?c? ayarlar? ekran?

## ?? Ba?lang?? Komutlar?

```bash
# Projeye git
cd mobile-app

# Ba??ml?l?klar? y?kle (zaten y?kl?)
npm install

# Uygulamay? ba?lat
npm start

# Android i?in
npm run android

# iOS i?in (macOS gerekli)
npm run ios

# Web i?in
npm run web
```

## ?? Notlar

- Database ?emas? `mobile-app/supabase/schema.sql` dosyas?nda
- Supabase konfig?rasyonu `src/services/supabase.ts` dosyas?nda
- Environment variables `.env.example` dosyas?ndan kopyalanabilir
- Mod?ler yap? sayesinde her mod?l ba??ms?z geli?tirilebilir

## ?? ?nemli Ba?lant?lar

- [Expo Dok?mantasyonu](https://docs.expo.dev/)
- [Supabase Dok?mantasyonu](https://supabase.com/docs)
- [React Navigation](https://reactnavigation.org/)
- [React Native Paper](https://callstack.github.io/react-native-paper/)

## ?? ?pu?lar?

1. **Development**: Expo Go uygulamas?n? telefonunuza y?kleyin ve QR kodu taray?n
2. **Database**: Supabase Dashboard'dan tablolar? ve verileri g?r?nt?leyebilirsiniz
3. **Testing**: Expo Go ile ger?ek zamanl? test yapabilirsiniz
4. **Hot Reload**: Kod de?i?iklikleri otomatik olarak yans?r
