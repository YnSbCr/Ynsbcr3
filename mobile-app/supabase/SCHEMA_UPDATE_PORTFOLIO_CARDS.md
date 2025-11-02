# Portf?y Kartlar? ve Zaman Dilimi Sistemi - Dok?mantasyon

## ?? ?zellikler

### 1. Yatay Kayd?rma Kartlar? ?
- Horizontal scroll/swipe ile kartlar aras?nda gezinme
- Kart s?ralamas?:
  1. "T?m?" kart? (t?m portf?ylerin toplam?)
  2. Her portf?y i?in ayr? kart (1. Portf?y, 2. Portf?y, vb.)
  3. "Yeni Portf?y Ekle" kart?

### 2. Zaman Dilimi Sistemi ?
- **1G (1 G?n)**: De?er de?i?imi (?)
- **1A (1 Ay)**: Kar/zarar oran? (%)
- **3A (3 Ay)**: Kar/zarar oran? (%)
- **6A (6 Ay)**: Kar/zarar oran? (%)
- **1Y (1 Y?l)**: Kar/zarar oran? (%)

### 3. Kart ??eri?i ?
- Portf?y ismi
- Toplam de?er
- Zaman dilimi se?imi
- Se?ilen zaman dilimine g?re g?sterim

## ??? Database Yap?s?

### Portfolio Snapshots Tablosu
Tarihsel portf?y de?erlerini saklar:
- `portfolio_id`: Portf?y ID (NULL = T?m?)
- `user_id`: Kullan?c? ID
- `snapshot_date`: Snapshot tarihi
- `total_value`: Toplam de?er
- `total_cost`: Toplam maliyet
- `profit_loss`: Kar/zarar
- `profit_loss_percent`: Kar/zarar y?zdesi

### Hesaplama Fonksiyonlar?
- `calculate_portfolio_value()`: Anl?k portf?y de?eri
- `calculate_all_portfolios_value()`: T?m portf?ylerin toplam de?eri
- `get_portfolio_value_1d()`: 1 g?nl?k de?er de?i?imi
- `get_portfolio_profit_loss_1m()`: 1 ayl?k kar/zarar
- `get_portfolio_profit_loss_3m()`: 3 ayl?k kar/zarar
- `get_portfolio_profit_loss_6m()`: 6 ayl?k kar/zarar
- `get_portfolio_profit_loss_1y()`: 1 y?ll?k kar/zarar
- `create_daily_portfolio_snapshots()`: G?nl?k snapshot olu?turma

## ?? Frontend Component Yap?s?

### PortfolioCard Component
```typescript
interface PortfolioCardProps {
  portfolio: Portfolio | 'all' | 'new';
  selectedTimePeriod: TimePeriod;
  onSelect: (portfolioId: string) => void;
  onTimePeriodChange: (period: TimePeriod) => void;
}
```

### PortfolioCardList Component
```typescript
interface PortfolioCardListProps {
  portfolios: Portfolio[];
  selectedPortfolioId: string | null;
  selectedTimePeriod: TimePeriod;
  onPortfolioSelect: (id: string) => void;
  onTimePeriodChange: (period: TimePeriod) => void;
  onNewPortfolio: () => void;
}
```

### TimePeriodSelector Component
```typescript
interface TimePeriodSelectorProps {
  selectedPeriod: TimePeriod;
  onPeriodChange: (period: TimePeriod) => void;
}

type TimePeriod = '1G' | '1A' | '3A' | '6A' | '1Y';
```

## ?? UI Tasar?m?

### Kart Yap?s?
```
???????????????????????????????????
?  T?m? / 1. Portf?y              ?
???????????????????????????????????
?  ? 125,450.00                  ?
?  Toplam De?er                   ?
???????????????????????????????????
?  [1G] [1A] [3A] [6A] [1Y]      ?
?  Zaman Dilimi Se?imi            ?
???????????????????????????????????
?  +2.5% ?                        ?
?  (Se?ilen zaman dilimine g?re)  ?
???????????????????????????????????
```

### Yeni Portf?y Ekle Kart?
```
???????????????????????????????????
?        ?                        ?
?    Yeni Portf?y Ekle            ?
???????????????????????????????????
```

## ?? Kullan?m Senaryolar?

### Senaryo 1: 1G (1 G?n) Se?ildi?inde
```typescript
// 1G t?kland???nda
const { data } = useQuery(
  ['portfolio', portfolioId, '1d'],
  () => getPortfolioValue1d(portfolioId, userId)
);

// G?sterim: +?1,250 veya -?500
```

### Senaryo 2: 1A (1 Ay) Se?ildi?inde
```typescript
// 1A t?kland???nda
const { data } = useQuery(
  ['portfolio', portfolioId, '1m'],
  () => getPortfolioProfitLoss1m(portfolioId, userId)
);

// G?sterim: +2.5% veya -1.2%
```

### Senaryo 3: Kart Kayd?rma
```typescript
// Horizontal scroll ile kartlar aras?nda gezinme
<ScrollView horizontal>
  <PortfolioCard type="all" />
  {portfolios.map(p => <PortfolioCard portfolio={p} />)}
  <PortfolioCard type="new" />
</ScrollView>
```

## ?? Veri Ak???

### 1. Kart Y?kleme
```
1. Portf?y listesi ?ekilir
2. Her portf?y i?in anl?k de?er hesaplan?r
3. Se?ilen zaman dilimine g?re veri ?ekilir
4. Kartlar render edilir
```

### 2. Zaman Dilimi De?i?imi
```
1. Kullan?c? zaman dilimi se?er (1G, 1A, vb.)
2. Yeni veri ?ekilir
3. Kart i?eri?i g?ncellenir
4. Animasyon g?sterilir
```

### 3. G?nl?k Snapshot
```
1. Scheduled job ?al???r (g?nde bir kez)
2. Her portf?y i?in snapshot olu?turulur
3. "T?m?" i?in snapshot olu?turulur
4. Veritaban?na kaydedilir
```

## ?? Implementasyon Ad?mlar?

1. ? Database ?emas? tasar?m? tamamland?
2. ? Hesaplama fonksiyonlar? tasarland?
3. ? Frontend component implementasyonu
4. ? Horizontal scroll implementasyonu
5. ? Zaman dilimi selector implementasyonu
6. ? Animasyonlar ve gesture handling
7. ? G?nl?k snapshot scheduled job

## ?? Notlar

- G?nl?k snapshot'lar performans i?in ?nemli
- Zaman dilimi de?i?imlerinde cache kullan?lmal?
- Kart animasyonlar? kullan?c? deneyimini iyile?tirir
- Responsive tasar?m tablet deste?i i?in gerekli
