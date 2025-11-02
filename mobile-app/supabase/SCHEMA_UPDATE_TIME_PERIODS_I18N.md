# Zaman Dilimi G?ncellemesi ve ?oklu Dil Deste?i - Dok?mantasyon

## ?? G?ncellenen Zaman Dilimleri

### Yeni Zaman Dilimleri
1. **1G (1 G?n)**: 1 g?nl?k de?er de?i?imi ?
2. **1H (1 Hafta)**: 1 haftal?k kar/zarar ? YEN?
3. **1A (1 Ay)**: 1 ayl?k kar/zarar ?
4. **1Y (1 Y?l)**: 1 y?ll?k kar/zarar ?
5. **YBI (Y?l Ba??ndan ?tibaren)**: Y?l ba??ndan beri kar/zarar ? YEN?
6. **3Y (3 Y?l)**: 3 y?ll?k kar/zarar ? YEN?

### Kald?r?lan Zaman Dilimleri
- ~~3A (3 Ay)~~: Kald?r?ld?
- ~~6A (6 Ay)~~: Kald?r?ld?

## ?? ?oklu Dil Deste?i

### Desteklenen Diller
- **T?rk?e (tr)**: Varsay?lan dil
- **?ngilizce (en)**: ?kinci dil

### Zaman Dilimi Etiketleri

#### T?rk?e
| Kod | Etiket | A??klama |
|-----|--------|----------|
| 1G | 1 G?n | 1 g?nl?k de?er de?i?imi |
| 1H | 1 Hafta | 1 haftal?k kar/zarar |
| 1A | 1 Ay | 1 ayl?k kar/zarar |
| 1Y | 1 Y?l | 1 y?ll?k kar/zarar |
| YBI | Y?l Ba?? | Y?l ba??ndan itibaren |
| 3Y | 3 Y?l | 3 y?ll?k kar/zarar |

#### ?ngilizce
| Kod | Etiket | A??klama |
|-----|--------|----------|
| 1G | 1 Day | 1 day value change |
| 1H | 1 Week | 1 week profit/loss |
| 1A | 1 Month | 1 month profit/loss |
| 1Y | 1 Year | 1 year profit/loss |
| YBI | YTD | Year to Date |
| 3Y | 3 Years | 3 years profit/loss |

## ??? Database Fonksiyonlar?

### Yeni Fonksiyonlar
- `get_portfolio_profit_loss_1w()`: 1 haftal?k kar/zarar (7 g?n)
- `get_portfolio_profit_loss_ytd()`: Y?l ba??ndan itibaren kar/zarar
- `get_portfolio_profit_loss_3y()`: 3 y?ll?k kar/zarar (1095 g?n)

### Mevcut Fonksiyonlar
- `get_portfolio_value_1d()`: 1 g?nl?k de?er
- `get_portfolio_profit_loss_1m()`: 1 ayl?k kar/zarar
- `get_portfolio_profit_loss_1y()`: 1 y?ll?k kar/zarar

### Kald?r?lan Fonksiyonlar
- ~~`get_portfolio_profit_loss_3m()`~~: Kald?r?ld?
- ~~`get_portfolio_profit_loss_6m()`~~: Kald?r?ld?

## ?? Frontend Implementasyonu

### i18n Kurulumu
```bash
npm install react-i18next i18next
```

### ?eviri Dosyalar? Yap?s?
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

### timePeriods.json ?rne?i
```json
{
  "tr": {
    "1G": "1 G?n",
    "1H": "1 Hafta",
    "1A": "1 Ay",
    "1Y": "1 Y?l",
    "YBI": "Y?l Ba??",
    "3Y": "3 Y?l"
  },
  "en": {
    "1G": "1 Day",
    "1H": "1 Week",
    "1A": "1 Month",
    "1Y": "1 Year",
    "YBI": "YTD",
    "3Y": "3 Years"
  }
}
```

### Kullan?m ?rne?i
```typescript
import { useTranslation } from 'react-i18next';

const PortfolioCard = () => {
  const { t, i18n } = useTranslation('portfolio');
  const selectedPeriod = '1H';
  
  const periodLabel = t(`timePeriods.${selectedPeriod}`);
  // T?rk?e: "1 Hafta"
  // ?ngilizce: "1 Week"
  
  return (
    <TimePeriodSelector
      periods={['1G', '1H', '1A', '1Y', 'YBI', '3Y']}
      selectedPeriod={selectedPeriod}
      labels={periods.map(p => t(`timePeriods.${p}`))}
    />
  );
};
```

## ?? Dil De?i?tirme

### Kullan?c? Ayarlar?
- `user_settings` tablosunda `language` kolonu mevcut
- Varsay?lan: 'tr'
- De?i?tirilebilir: 'en'

### Dil De?i?tirme Ak???
```
1. Kullan?c? Settings'e gider
2. Dil se?imi yapar (T?rk?e/?ngilizce)
3. user_settings.language g?ncellenir
4. Uygulama genelinde dil de?i?ir
5. T?m etiketler ?evrilir
```

## ?? UI G?ncellemeleri

### Zaman Dilimi Selector
```
???????????????????????????????????????????
? [1G] [1H] [1A] [1Y] [YBI] [3Y]          ?
?  ?     ?    ?    ?    ?     ?            ?
? Se?ili zaman dilimi vurgulan?r           ?
???????????????????????????????????????????
```

### Responsive Tasar?m
- Mobilde: Scrollable horizontal tabs
- Tablette: Daha geni? g?r?n?m
- T?m ekran boyutlar?nda ?al???r

## ?? Hesaplama Mant???

### Y?l Ba?? (YBI) Hesaplama
```sql
-- Y?l ba?? tarihi
DATE_TRUNC('year', CURRENT_DATE)
-- ?rnek: 2024-01-01

-- Y?l ba?? snapshot'? bul
SELECT * FROM portfolio_snapshots
WHERE snapshot_date = DATE_TRUNC('year', CURRENT_DATE)
```

### 3 Y?l Hesaplama
```sql
-- 3 y?l = 1095 g?n
-- 3 y?l ?nceki snapshot'? bul
SELECT * FROM portfolio_snapshots
WHERE snapshot_date = CURRENT_DATE - INTERVAL '3 years'
```

## ?? Migration S?ras?

1. ? `schema.sql` - Temel ?ema
2. ? `migration_portfolio_assets.sql` - Varl?k t?rleri
3. ? `migration_currency_system.sql` - D?viz kuru
4. ? `migration_crypto_assets.sql` - Kripto ve arama
5. ? `migration_portfolio_cards.sql` - Portf?y kartlar?
6. ? `migration_time_periods_i18n.sql` - Zaman dilimleri ve i18n (YEN?)

## ?? Notlar

- Y?l ba?? (YBI) hesaplamas? i?in y?l ba?? snapshot'? gerekli
- Dil de?i?ikli?i an?nda uygulan?r
- Zaman dilimi etiketleri dinamik olarak ?evrilir
- Eski fonksiyonlar deprecated olarak kalabilir (geriye uyumluluk i?in)
