# Zaman Dilimi G?ncellemesi ve ?oklu Dil Deste?i

## Gereksinimler

### Yeni Zaman Dilimleri
1. **1G (1 G?n)**: 1 g?nl?k de?er de?i?imi
2. **1H (1 Hafta)**: 1 haftal?k kar/zarar ? YEN?
3. **1A (1 Ay)**: 1 ayl?k kar/zarar
4. **1Y (1 Y?l)**: 1 y?ll?k kar/zarar
5. **YBI (Y?l Ba??ndan ?tibaren)**: Y?l ba??ndan beri kar/zarar ? YEN?
6. **3Y (3 Y?l)**: 3 y?ll?k kar/zarar ? YEN?

### ?oklu Dil Deste?i
- **T?rk?e**: Varsay?lan dil
- **?ngilizce**: ?kinci dil deste?i
- Uygulama genelinde dil de?i?tirme
- Zaman dilimi etiketleri ?evrilmeli

## Zaman Dilimi G?ncellemeleri

### Eski Zaman Dilimleri
- ~~1G~~ ? (Korunuyor)
- ~~1A~~ ? (Korunuyor)
- ~~3A~~ ? (Kald?r?l?yor)
- ~~6A~~ ? (Kald?r?l?yor)
- ~~1Y~~ ? (Korunuyor)

### Yeni Zaman Dilimleri
- **1H (1 Hafta)**: 7 g?nl?k kar/zarar
- **YBI (Y?l Ba??ndan ?tibaren)**: Y?l ba??ndan bug?ne kadar
- **3Y (3 Y?l)**: 3 y?ll?k kar/zarar

## ?oklu Dil Deste?i Tasar?m?

### Dil Se?enekleri
```typescript
type Language = 'tr' | 'en';

const languages = {
  tr: {
    code: 'tr',
    name: 'T?rk?e',
    nativeName: 'T?rk?e'
  },
  en: {
    code: 'en',
    name: 'English',
    nativeName: 'English'
  }
};
```

### Zaman Dilimi Etiketleri (?eviriler)

#### T?rk?e
- 1G: "1 G?n"
- 1H: "1 Hafta"
- 1A: "1 Ay"
- 1Y: "1 Y?l"
- YBI: "Y?l Ba??"
- 3Y: "3 Y?l"

#### ?ngilizce
- 1G: "1 Day"
- 1H: "1 Week"
- 1A: "1 Month"
- 1Y: "1 Year"
- YBI: "YTD" (Year to Date)
- 3Y: "3 Years"

### i18n (Internationalization) Yakla??m?

#### Se?enek 1: react-i18next (?NER?LEN) ?
**Avantajlar**:
- React Native i?in en pop?ler ??z?m
- JSON dosyalar? ile ?eviriler
- Kolay kullan?m
- TypeScript deste?i

#### Se?enek 2: expo-localization
**Avantajlar**:
- Expo ile entegre
- Sistem dilini otomatik alg?lar

#### Se?enek 3: Custom Solution
**Avantajlar**: Tam kontrol
**Dezavantajlar**: Daha fazla kod

## Database Fonksiyon G?ncellemeleri

### Yeni Fonksiyonlar
- `get_portfolio_profit_loss_1w()`: 1 haftal?k kar/zarar
- `get_portfolio_profit_loss_ytd()`: Y?l ba??ndan itibaren kar/zarar
- `get_portfolio_profit_loss_3y()`: 3 y?ll?k kar/zarar

### Kald?r?lacak Fonksiyonlar
- ~~`get_portfolio_profit_loss_3m()`~~: Kald?r?l?yor
- ~~`get_portfolio_profit_loss_6m()`~~: Kald?r?l?yor

## UI G?ncellemeleri

### Zaman Dilimi Selector
```typescript
type TimePeriod = '1G' | '1H' | '1A' | '1Y' | 'YBI' | '3Y';

const timePeriods = {
  tr: {
    '1G': '1 G?n',
    '1H': '1 Hafta',
    '1A': '1 Ay',
    '1Y': '1 Y?l',
    'YBI': 'Y?l Ba??',
    '3Y': '3 Y?l'
  },
  en: {
    '1G': '1 Day',
    '1H': '1 Week',
    '1A': '1 Month',
    '1Y': '1 Year',
    'YBI': 'YTD',
    '3Y': '3 Years'
  }
};
```

### Kart G?r?n?m?
```
???????????????????????????????????
?  T?m? / 1. Portf?y              ?
???????????????????????????????????
?  ? 125,450.00                  ?
?  Toplam De?er                   ?
???????????????????????????????????
?  [1G] [1H] [1A] [1Y] [YBI] [3Y]?
?  Zaman Dilimi Se?imi            ?
???????????????????????????????????
?  +2.5% ?                        ?
?  (Se?ilen zaman dilimine g?re)  ?
???????????????????????????????????
```

## Dil De?i?tirme

### Kullan?c? Ayarlar?
- `user_settings` tablosunda `language` kolonu zaten var
- Varsay?lan: 'tr' (T?rk?e)
- De?i?tirilebilir: 'en' (?ngilizce)

### Dil De?i?tirme Ekran?
- Settings mod?l?nde dil se?imi
- An?nda uygulama genelinde de?i?im
- Tercih kaydedilir

## Database G?ncellemeleri

### Yeni Fonksiyonlar
```sql
-- 1 haftal?k kar/zarar
CREATE FUNCTION get_portfolio_profit_loss_1w(...)

-- Y?l ba??ndan itibaren kar/zarar
CREATE FUNCTION get_portfolio_profit_loss_ytd(...)

-- 3 y?ll?k kar/zarar
CREATE FUNCTION get_portfolio_profit_loss_3y(...)
```

### Y?l Ba?? Hesaplama
```sql
-- Y?l ba?? tarihi hesaplama
DATE_TRUNC('year', CURRENT_DATE) -- 1 Ocak
```

## Frontend Implementasyonu

### i18n Kurulumu
```bash
npm install react-i18next i18next
```

### ?eviri Dosyalar?
```
locales/
  ??? tr/
  ?   ??? common.json
  ?   ??? portfolio.json
  ?   ??? timePeriods.json
  ??? en/
      ??? common.json
      ??? portfolio.json
      ??? timePeriods.json
```

### Kullan?m
```typescript
import { useTranslation } from 'react-i18next';

const { t } = useTranslation('portfolio');
const periodLabel = t(`timePeriods.${selectedPeriod}`);
```

## Sonraki Ad?mlar

1. ? Zaman dilimi g?ncellemesi tasar?m? tamamland?
2. ? Database fonksiyonlar? g?ncellemesi
3. ? i18n implementasyonu
4. ? ?eviri dosyalar? olu?turma
5. ? UI g?ncellemeleri
