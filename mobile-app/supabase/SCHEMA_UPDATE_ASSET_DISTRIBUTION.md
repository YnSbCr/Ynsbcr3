# Varl?k Da??l?m? ve Varl?k Detay? Kartlar? - Dok?mantasyon

## ?? ?zellikler

### 1. ?ki Sekme Yap?s? ?
- **Varl?k Da??l?m?**: Pie/Donut chart ile varl?k t?rlerine g?re da??l?m
- **Varl?k Detay?**: Se?ili t?re g?re varl?k listesi

### 2. Varl?k Da??l?m? ?
- Varl?k t?rlerine g?re renkli g?sterim
- T?klanabilir segmentler
- Her t?r i?in y?zde ve de?er
- Portf?y "T?m?"nde t?m portf?ylerin toplam?
- Se?ili portf?yde sadece o portf?y?n da??l?m?

### 3. Varl?k Detay? ?
- Filtrelenmi? varl?k listesi
- Her varl?k i?in detay bilgileri
- Kar/zarar g?sterimi
- Sembol, isim, miktar, fiyat bilgileri

### 4. Portf?y Se?imi ?
- Portf?y kart?na t?klay?nca filtreleme
- Varl?k eklerken portf?y se?imi zorunlu
- "T?m?" se?ene?i t?m portf?yleri g?sterir

### 5. Interaktif Filtreleme ?
- Varl?k t?r?ne t?klay?nca detayda filtrelenir
- Filtre g?stergesi ?stte g?sterilir
- Filtre temizleme ?zelli?i

## ?? Varl?k T?rleri ve Renkler

| Varl?k T?r? | Renk | Hex Kodu |
|-------------|------|----------|
| BIST Hisseleri | Mavi | #2196F3 |
| ABD Hisseleri | Sar? | #FFC107 |
| ETF'ler | Ye?il | #4CAF50 |
| Yat?r?m Fonlar? | Turuncu | #FF9800 |
| Kripto | Mor | #9C27B0 |
| Alt?n | Alt?n | #FFD700 |
| G?m?? | Gri | #9E9E9E |
| Emtialar | Kahverengi | #795548 |
| D?viz | K?rm?z? | #F44336 |
| BES Fonlar? | Pembe | #E91E63 |

## ??? Database Fonksiyonlar?

### 1. `get_portfolio_asset_distribution()`
Portf?ydeki varl?k t?rlerine g?re da??l?m:
- Varl?k t?r?
- Toplam de?er
- Toplam maliyet
- Kar/zarar
- Y?zde da??l?m?
- Varl?k say?s?

### 2. `get_portfolio_asset_details()`
Se?ili varl?k t?r?ne g?re detaylar:
- G?venlik bilgileri
- Miktar ve maliyet
- Mevcut fiyat ve de?er
- Kar/zarar bilgileri

### 3. `get_asset_type_colors()`
Varl?k t?rleri i?in renk e?le?tirmesi (frontend i?in)

### 4. `get_asset_type_labels()`
Varl?k t?rleri i?in etiketler (i18n deste?i)

## ?? UI Bile?enleri

### AssetDistributionDetail Component
```typescript
interface AssetDistributionDetailProps {
  portfolioId: string | null;
  selectedAssetType: asset_type | null;
  onAssetTypeSelect: (type: asset_type | null) => void;
  language: 'tr' | 'en';
}
```

### Tab Structure
- `distribution`: Varl?k da??l?m? sekmesi
- `details`: Varl?k detay? sekmesi

### Chart Component
- Pie chart veya Donut chart
- T?klanabilir segmentler
- Renkli g?sterim
- Y?zde etiketleri

### Asset List Component
- Filtrelenmi? liste
- Detayl? bilgiler
- Kar/zarar vurgulamas?

## ?? Kullan?m Senaryolar?

### Senaryo 1: Portf?y Se?imi
```
1. Kullan?c? "1. Portf?y" kart?na t?klar
2. Varl?k da??l?m?: Sadece 1. Portf?y'deki varl?klar
3. Varl?k detay?: Sadece 1. Portf?y'deki varl?klar
4. Filtre temizlenir
```

### Senaryo 2: Varl?k T?r? Se?imi
```
1. Kullan?c? "BIST" segmentine t?klar
2. Varl?k da??l?m?: BIST segmenti vurgulan?r
3. Varl?k detay?: Sadece BIST varl?klar? g?sterilir
4. ?stte filtre g?stergesi: "?? BIST"
```

### Senaryo 3: Varl?k Ekleme
```
1. Kullan?c? "Varl?k Ekle" butonuna t?klar
2. Portf?y se?imi zorunlu alan olarak g?sterilir
3. Portf?y se?meden varl?k eklenemez
```

## ?? Veri Ak???

### 1. Portf?y Se?imi
```
1. Kullan?c? portf?y kart?na t?klar
2. PortfolioStore g?ncellenir
3. Varl?k da??l?m? ve detay sorgular? ?al???r
4. UI g?ncellenir
```

### 2. Varl?k T?r? Se?imi
```
1. Kullan?c? chart segmentine t?klar
2. AssetTypeStore g?ncellenir
3. Varl?k detay sorgusu filtrelenir
4. Liste g?ncellenir
```

### 3. Sekme De?i?imi
```
1. Kullan?c? sekme de?i?tirir
2. ActiveTabStore g?ncellenir
3. ?lgili component render edilir
```

## ?? Implementasyon Ad?mlar?

1. ? UI/UX tasar?m? tamamland?
2. ? Database fonksiyonlar? tasarland?
3. ? Chart library entegrasyonu
4. ? Component implementasyonu
5. ? State management kurulumu
6. ? Interaktif filtreleme sistemi
7. ? Varl?k ekleme form validasyonu

## ?? Notlar

- Chart library olarak Victory Native ?nerilir
- Renkler database'den ?ekilebilir (get_asset_type_colors)
- Dil deste?i i?in get_asset_type_labels kullan?l?r
- Portf?y se?imi zorunlu validasyonu form katman?nda yap?l?r
