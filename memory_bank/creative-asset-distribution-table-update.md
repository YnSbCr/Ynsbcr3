# Varl?k Da??l?m? ve Detay Kartlar? - G?ncelleme (Toplam K/Z)

## G?ncelleme Notu

### Genel ?zet Tablosu G?ncellemesi

**1A: Toplam K/Z**:
- ? Zaman dilimine g?re DE??L
- ? Toplam kar/zarar (ba?lang??tan bug?ne kadar)
- ? Form?l: Mevcut De?er - Toplam Maliyet

**2A: Toplam K/Z Oran**:
- ? Zaman dilimine g?re DE??L
- ? Toplam kar/zarar y?zdesi (ba?lang??tan bug?ne kadar)
- ? Form?l: ((Mevcut De?er - Toplam Maliyet) / Toplam Maliyet) * 100

**1B ve 2B**: 
- ? G?nl?k K/Z (her zaman 1G i?in) - De?i?medi

**Not**: Zaman dilimine g?re de?i?en sadece **Varl?k Detay? Tablosu**ndaki K/Z oranlar?d?r.

## Database Fonksiyon G?ncellemesi

### get_portfolio_summary() Fonksiyonu
- `total_profit_loss`: Zaman dilimine g?re DE??L, toplam kar/zarar
- `total_profit_loss_percent`: Zaman dilimine g?re DE??L, toplam kar/zarar y?zdesi
- `daily_profit_loss`: Her zaman 1G i?in
- `daily_profit_loss_percent`: Her zaman 1G i?in

### Hesaplama Mant???
```sql
-- Toplam K/Z (1A)
total_profit_loss = current_value - total_cost

-- Toplam K/Z Oran (2A)
total_profit_loss_percent = ((current_value - total_cost) / total_cost) * 100

-- G?nl?k K/Z (1B)
daily_profit_loss = get_portfolio_value_1d() -- Zaman dilimine g?re DE??L

-- G?nl?k K/Z Oran (2B)
daily_profit_loss_percent = get_portfolio_value_1d() -- Zaman dilimine g?re DE??L
```

## UI G?ncellemesi

### Genel ?zet Tablosu
```
???????????????????????????????????????????
? 1A          ? 1B          ? 1C          ?
? Toplam K/Z  ? G?nl?k K/Z  ? Toplam      ?
? +?45,230    ? +?1,250     ? Maliyet     ?
? (Toplam)    ? (1G)        ? ?280,220    ?
???????????????????????????????????????????
? 2A          ? 2B          ? 2C          ?
? Toplam K/Z  ? G?nl?k K/Z  ? Karl?       ?
? Oran        ? Oran        ? Poziyon     ?
? +16.1%      ? +0.4%       ? 4/6         ?
? (Toplam)    ? (1G)        ?             ?
???????????????????????????????????????????
```

**Not**: 1A ve 2A zaman dilimi de?i?ti?inde de?i?mez, her zaman toplam kar/zarar g?sterir.

## Varl?k Detay? Tablosu

### Zaman Dilimi Entegrasyonu
- Varl?k detay? tablosundaki K/Z oranlar? zaman dilimine g?re de?i?ir
- Zaman dilimi se?ildi?inde:
  - Her varl?k i?in se?ili zaman dilimine g?re K/Z oran? hesaplan?r
  - Genel ?zet tablosu de?i?mez (1A ve 2A toplam kal?r)

## Database Fonksiyon Mant???

### Toplam K/Z Hesaplama
```sql
-- Mevcut de?er
SELECT total_value FROM calculate_portfolio_value(portfolio_id);

-- Toplam maliyet
SELECT total_cost FROM calculate_portfolio_value(portfolio_id);

-- Toplam K/Z
total_profit_loss = total_value - total_cost;

-- Toplam K/Z Oran
total_profit_loss_percent = ((total_value - total_cost) / total_cost) * 100;
```

### Zaman Dilimi Parametresi
- `get_portfolio_summary()` fonksiyonunda `p_time_period` parametresi:
  - 1A ve 2A i?in kullan?lmaz (her zaman toplam)
  - Sadece ileride kullan?labilir veya kald?r?labilir
  - Varl?k detay? i?in kullan?l?r

## Sonraki Ad?mlar

1. ? Mant?k g?ncellemesi tamamland?
2. ? Database fonksiyonu g?ncellemesi
3. ? UI g?ncellemesi
4. ? Test ve do?rulama
