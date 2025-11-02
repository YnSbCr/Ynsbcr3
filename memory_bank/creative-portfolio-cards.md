# Portf?y Kartlar? UI/UX Tasar?m?

## Gereksinimler

### Ana ?zellikler
1. **Yatay Kayd?rma**: Horizontal scroll/swipe ile kartlar aras?nda gezinme
2. **Kart S?ralamas?**:
   - ?lk kart: "T?m?" (t?m portf?ylerin toplam?)
   - Sonraki kartlar: Her portf?y i?in ayr? kart (1. Portf?y, 2. Portf?y, vb.)
   - En son kart: "Yeni Portf?y Ekle"
3. **Kart ??eri?i**:
   - Portf?y ismi
   - Toplam de?er
   - Zaman dilimi se?imi (1G, 1A, vb.)
   - Se?ilen zaman dilimine g?re de?er veya kar/zarar

### Zaman Dilimi ?zellikleri
- **1G (1 G?n)**: T?kland???nda 1 g?nl?k de?eri g?sterir
- **1A (1 Ay)**: T?kland???nda 1 ayl?k kar/zarar oran?n? g?sterir
- **3A (3 Ay)**: T?kland???nda 3 ayl?k kar/zarar oran?n? g?sterir
- **6A (6 Ay)**: T?kland???nda 6 ayl?k kar/zarar oran?n? g?sterir
- **1Y (1 Y?l)**: T?kland???nda 1 y?ll?k kar/zarar oran?n? g?sterir
- **T?m?**: T?m zaman dilimlerini g?sterir

## Tasar?m Kararlar?

### Se?enek 1: Tab-Based Navigation
**Avantajlar**: Basit implementasyon
**Dezavantajlar**: Her kart i?in ayr? tab gerekir

### Se?enek 2: Horizontal Scroll Cards (?NER?LEN) ?
**Avantajlar**:
- Modern ve kullan?c? dostu
- Swipe gesture deste?i
- Her kart ba??ms?z g?r?nt?lenir
- Kolay navigasyon

**Dezavantajlar**: Biraz daha karma??k implementasyon

### Se?enek 3: Pagination
**Avantajlar**: B?y?k listeler i?in uygun
**Dezavantajlar**: Her kart i?in ayr? sayfa gerekir

## UI Bile?enleri

### Portf?y Kart? Yap?s?
```
???????????????????????????????????
?  Portf?y ?smi                  ?
?  (T?m? / 1. Portf?y / vb.)    ?
???????????????????????????????????
?                                 ?
?  ? 125,450.00                  ?
?  Toplam De?er                   ?
?                                 ?
???????????????????????????????????
?  [1G] [1A] [3A] [6A] [1Y]      ?
?  Zaman Dilimi Se?imi            ?
???????????????????????????????????
?                                 ?
?  +2.5% ?                        ?
?  (Se?ilen zaman dilimine g?re)  ?
?                                 ?
???????????????????????????????????
```

### Yeni Portf?y Ekle Kart?
```
???????????????????????????????????
?                                 ?
?        ?                        ?
?                                 ?
?    Yeni Portf?y Ekle            ?
?                                 ?
?                                 ?
???????????????????????????????????
```

## Zaman Dilimi G?sterimi

### 1G (1 G?n)
- **G?sterim**: De?er de?i?imi (?)
- **?rnek**: "+?1,250" veya "-?500"
- **Renk**: Ye?il (art??) / K?rm?z? (azal??)

### 1A, 3A, 6A, 1Y (Kar/Zarar Oranlar?)
- **G?sterim**: Y?zde de?i?im (%)
- **?rnek**: "+2.5%" veya "-1.2%"
- **Renk**: Ye?il (kar) / K?rm?z? (zarar)

### T?m? Zaman Dilimi
- **G?sterim**: Genel bak??
- **?rnek**: T?m zaman dilimlerinin ?zeti

## Database Gereksinimleri

### Portfolio Snapshot Tablosu
Tarihsel portf?y de?erlerini saklamak i?in:
```sql
CREATE TABLE portfolio_snapshots (
  id UUID PRIMARY KEY,
  portfolio_id UUID REFERENCES portfolios(id),
  snapshot_date DATE NOT NULL,
  total_value DECIMAL(15, 4) NOT NULL,
  total_cost DECIMAL(15, 4) NOT NULL,
  profit_loss DECIMAL(15, 4),
  profit_loss_percent DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(portfolio_id, snapshot_date)
);
```

### Zaman Dilimi Hesaplama Fonksiyonlar?
- `get_portfolio_value_1d()`: 1 g?nl?k de?er
- `get_portfolio_profit_loss_1m()`: 1 ayl?k kar/zarar
- `get_portfolio_profit_loss_3m()`: 3 ayl?k kar/zarar
- `get_portfolio_profit_loss_6m()`: 6 ayl?k kar/zarar
- `get_portfolio_profit_loss_1y()`: 1 y?ll?k kar/zarar

## Frontend Component Yap?s?

### PortfolioCard Component
```typescript
interface PortfolioCardProps {
  portfolio: Portfolio | 'all' | 'new';
  onSelect: (portfolioId: string) => void;
  onEdit?: (portfolioId: string) => void;
}
```

### PortfolioCardList Component
```typescript
interface PortfolioCardListProps {
  portfolios: Portfolio[];
  selectedPortfolioId: string | null;
  onPortfolioSelect: (id: string) => void;
  onNewPortfolio: () => void;
}
```

### TimePeriodSelector Component
```typescript
interface TimePeriodSelectorProps {
  selectedPeriod: TimePeriod;
  onPeriodChange: (period: TimePeriod) => void;
}

type TimePeriod = '1G' | '1A' | '3A' | '6A' | '1Y' | 'ALL';
```

## State Management

### Zustand Store
```typescript
interface PortfolioStore {
  selectedPortfolioId: string | null;
  selectedTimePeriod: TimePeriod;
  portfolios: Portfolio[];
  setSelectedPortfolio: (id: string | null) => void;
  setSelectedTimePeriod: (period: TimePeriod) => void;
}
```

### React Query
```typescript
// Portfolio listesi
useQuery(['portfolios'], fetchPortfolios);

// Portfolio de?erleri
useQuery(['portfolio', id, timePeriod], 
  () => fetchPortfolioValue(id, timePeriod)
);
```

## Animasyonlar ve Gesture

### Horizontal Scroll
- React Native `ScrollView` veya `FlatList` (horizontal)
- `react-native-gesture-handler` ile swipe deste?i
- Snap to card ?zelli?i

### Kart Animasyonlar?
- Fade in/out animasyonlar?
- Scale animasyonlar? (se?ili kart)
- Loading skeleton animation

## Responsive Tasar?m

### Kart Boyutlar?
- Width: Ekran geni?li?inin %85-90'?
- Height: Dinamik (i?erik boyutuna g?re)
- Gap: Kartlar aras? 10-15px

### Tablet Deste?i
- Daha geni? kartlar
- Daha fazla kart ayn? anda g?r?n?r
- Grid layout (opsiyonel)

## Performans Optimizasyonlar?

### Virtualization
- `FlatList` virtualization kullan?m?
- Sadece g?r?n?r kartlar render edilir

### Caching
- Portfolio de?erleri cache'lenir
- Zaman dilimi bazl? cache
- React Query cache stratejisi

## Sonraki Ad?mlar

1. ? UI/UX tasar?m? tamamland?
2. ? Database ?emas? g?ncellemesi (portfolio_snapshots)
3. ? Zaman dilimi hesaplama fonksiyonlar?
4. ? Frontend component implementasyonu
5. ? Animasyonlar ve gesture handling
