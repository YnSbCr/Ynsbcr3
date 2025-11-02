# Memory Bank Sistemi - T?rk?e Kurulum ve Kullan?m Rehberi

## ?? ??indekiler
1. [Memory Bank Nedir?](#memory-bank-nedir)
2. [Kurulum](#kurulum)
3. [Custom Modes Kurulumu](#custom-modes-kurulumu)
4. [Kullan?m Senaryolar?](#kullan?m-senaryolar?)
5. [Proje Plan?](#proje-plan?)
6. [S?k Sorulan Sorular](#s?k-sorulan-sorular)

---

## Memory Bank Nedir?

Memory Bank, Cursor IDE i?in geli?tirilmi? token-optimize edilmi?, hiyerar?ik bir g?rev y?netim sistemidir. Bu sistem, geli?tirme s?recini farkl? fazlara ay?rarak daha verimli ?al??man?z? sa?lar:

- **VAN Mode**: Proje ba?latma ve karma??kl?k belirleme
- **PLAN Mode**: Detayl? uygulama plan? olu?turma
- **CREATIVE Mode**: Tasar?m kararlar? ve se?enekleri ke?fetme
- **IMPLEMENT Mode**: Kodlama ve geli?tirme
- **REFLECT Mode**: Kod inceleme ve dersler ??karma
- **ARCHIVE Mode**: Dok?mantasyon olu?turma

### Temel ?zellikler

? **Hiyerar?ik Kural Y?kleme**: Sadece gerekli kurallar y?klenir  
? **Progresif Dok?mantasyon**: Karma??kl??a g?re ?l?eklenen ?ablonlar  
? **Token Optimizasyonu**: Gereksiz token kullan?m?n? azalt?r  
? **Seviye Bazl? ?? Ak??lar?**: G?rev karma??kl???na g?re uyarlan?r

---

## Kurulum

### Ad?m 1: Dosyalar?n Kontrol?

Memory Bank dosyalar? projenize kopyaland?. ?u klas?rler mevcut:

```
.cursor/rules/isolation_rules/     # Memory Bank kurallar?
custom_modes/                      # Custom mode talimatlar?
memory_bank/                       # Memory Bank veri dosyalar?
```

### Ad?m 2: Cursor Ayarlar?

Cursor IDE'de Custom Modes ?zelli?inin aktif oldu?undan emin olun:
- Settings ? Features ? Chat ? Custom modes ? (aktif olmal?)

### Ad?m 3: Custom Modes Kurulumu

Cursor'da 6 custom mode olu?turman?z gerekiyor. Her mod i?in:

1. Cursor'da mod se?iciye t?klay?n
2. "Add custom mode" se?in
3. A?a??daki yap?land?rmalar? uygulay?n

---

## Custom Modes Kurulumu

### 1. ?? VAN MODE (Ba?latma)

**Yap?land?rma:**
- **Ad**: ?? VAN
- **Ara?lar**: Codebase Search, Read File, Terminal, List Directory, Fetch Rules
- **Advanced Options**: `custom_modes/van_instructions.md` dosyas?n?n i?eri?ini yap??t?r?n

**Kullan?m:**
```
VAN
```
Projeyi analiz eder ve karma??kl?k seviyesini belirler.

---

### 2. ?? PLAN MODE (Planlama)

**Yap?land?rma:**
- **Ad**: ?? PLAN
- **Ara?lar**: Codebase Search, Read File, Terminal, List Directory
- **Advanced Options**: `custom_modes/plan_instructions.md` dosyas?n?n i?eri?ini yap??t?r?n

**Kullan?m:**
```
PLAN
```
Detayl? uygulama plan? olu?turur.

---

### 3. ?? CREATIVE MODE (Tasar?m)

**Yap?land?rma:**
- **Ad**: ?? CREATIVE
- **Ara?lar**: Codebase Search, Read File, Terminal, List Directory, Edit File, Fetch Rules
- **Advanced Options**: `custom_modes/creative_instructions.md` dosyas?n?n i?eri?ini yap??t?r?n

**Kullan?m:**
```
CREATIVE
```
Tasar?m se?eneklerini ke?feder ve kararlar al?r.

---

### 4. ?? IMPLEMENT MODE (Geli?tirme)

**Yap?land?rma:**
- **Ad**: ?? IMPLEMENT
- **Ara?lar**: T?m ara?lar aktif
- **Advanced Options**: `custom_modes/implement_instructions.md` dosyas?n?n i?eri?ini yap??t?r?n

**Kullan?m:**
```
IMPLEMENT
```
Planlanan bile?enleri sistematik olarak geli?tirir.

---

### 5. ?? REFLECT MODE (?nceleme)

**Yap?land?rma:**
- **Ad**: ?? REFLECT veya ARCHIVE
- **Ara?lar**: Codebase Search, Read File, Terminal, List Directory
- **Advanced Options**: `custom_modes/reflect_archive_instructions.md` dosyas?n?n i?eri?ini yap??t?r?n

**Kullan?m:**
```
REFLECT
```
Kod incelemesi yapar ve dersler ??kar?r.

```
ARCHIVE
```
Kapsaml? dok?mantasyon olu?turur.

---

### 6. QA Fonksiyonu

QA ayr? bir mod de?il, herhangi bir moddan ?a?r?labilen bir fonksiyondur:

**Kullan?m:**
```
QA
```
Teknik validasyon yapar.

---

## Kullan?m Senaryolar?

### Senaryo 1: H?zl? Bug D?zeltme (Level 1)

```
VAN ? IMPLEMENT ? REFLECT
```

Basit bug'lar i?in h?zl? ??z?m.

---

### Senaryo 2: Basit ?zellik (Level 2)

```
VAN ? PLAN ? IMPLEMENT ? REFLECT
```

Basit ?zellikler i?in basitle?tirilmi? i? ak???.

---

### Senaryo 3: Karma??k ?zellik (Level 3-4)

```
VAN ? PLAN ? CREATIVE ? IMPLEMENT ? REFLECT ? ARCHIVE
```

Karma??k ?zellikler i?in tam i? ak???.

---

## Proje Plan?

### Mevcut Proje Durumu

Projeniz ?u teknolojileri kullan?yor:
- **Frontend**: React + TypeScript + Vite
- **Backend**: Express + TypeScript  
- **Database**: PostgreSQL (Drizzle ORM)
- **UI Framework**: Radix UI + Tailwind CSS

### ?nerilen Geli?tirme Ad?mlar?

#### 1. Proje Analizi ve Ba?lang??
- [ ] VAN modu ile proje analizi yap?n
- [ ] Proje karma??kl?k seviyesini belirleyin
- [ ] Mevcut yap?y? dok?mante edin

#### 2. Veritaban? ?emas?
- [ ] Drizzle ?emas?n? g?zden ge?irin
- [ ] Veritaban? migrasyonlar?n? kontrol edin
- [ ] Gerekli tablolar? olu?turun

#### 3. Backend API
- [ ] REST API endpoint'lerini planlay?n
- [ ] Authentication sistemi kurun
- [ ] Middleware'leri yap?land?r?n

#### 4. Frontend Geli?tirme
- [ ] Routing yap?s?n? kurun
- [ ] Component library'yi organize edin
- [ ] State management'? yap?land?r?n

#### 5. Entegrasyon
- [ ] Frontend-Backend entegrasyonu
- [ ] API ?a?r?lar?n? test edin
- [ ] Error handling ekleyin

#### 6. Dok?mantasyon
- [ ] README g?ncellemeleri
- [ ] API dok?mantasyonu
- [ ] Kod i?i yorumlar

---

## ?nerilen ?lk Ad?mlar

### 1. Memory Bank'i Test Edin

```bash
# Cursor'da VAN moduna ge?in ve ?unu yaz?n:
VAN
```

Bu komut projenizi analiz edecek ve karma??kl?k seviyesini belirleyecektir.

### 2. Proje ?zetini Olu?turun

Memory Bank otomatik olarak `memory_bank/projectbrief.md` dosyas?n? olu?turacak ve g?ncelleyecektir.

### 3. ?lk G?revi Planlay?n

PLAN moduna ge?in ve ilk g?revinizi planlay?n:

```
PLAN
```

### 4. Geli?tirmeye Ba?lay?n

IMPLEMENT moduna ge?in ve planlanan ?zellikleri geli?tirin:

```
IMPLEMENT
```

---

## Memory Bank Dosyalar?

Memory Bank sistemi ?u dosyalar? kullan?r:

- **`memory_bank/tasks.md`**: Merkezi g?rev takip dosyas?
- **`memory_bank/activeContext.md`**: Mevcut geli?tirme faz?n?n odak noktas?
- **`memory_bank/progress.md`**: ?mplementasyon durumu
- **`memory_bank/projectbrief.md`**: Proje ?zeti ve temel bilgiler
- **`memory_bank/creative-*.md`**: CREATIVE modunda olu?turulan tasar?m kararlar?
- **`memory_bank/reflect-*.md`**: REFLECT modunda olu?turulan inceleme dok?manlar?

---

## S?k Sorulan Sorular

### Memory Bank dosyalar?n? manuel olarak d?zenleyebilir miyim?

Hay?r, Memory Bank dosyalar? sistem taraf?ndan otomatik olarak y?netilir. Manuel d?zenleme yapmay?n.

### Bir mod ?al??m?yorsa ne yapmal?y?m?

1. Custom instructions'?n tamamen kopyaland???ndan emin olun
2. Do?ru ara?lar?n aktif oldu?unu kontrol edin
3. Do?ru modda oldu?unuzdan emin olun
4. Cursor'? yeniden ba?latmay? deneyin

### Birden fazla projede Memory Bank kullanabilir miyim?

Evet, her projede ayr? Memory Bank kurulumu yapabilirsiniz. Custom modes Cursor genelinde kullan?labilir, ancak Memory Bank dosyalar? proje bazl?d?r.

### Token optimizasyonu ne kadar etkili?

Memory Bank sistemi, gereksiz kurallar?n y?klenmesini ?nleyerek %30-50 aras? token tasarrufu sa?layabilir.

---

## Sonraki Ad?mlar

1. ? Memory Bank dosyalar? kuruldu
2. ? Custom modes'lar? Cursor'a ekleyin
3. ? ?lk VAN analizini ?al??t?r?n
4. ? Proje plan?n?z? olu?turun

---

## Destek

Memory Bank, a??k kaynak bir projedir. Sorun ya?arsan?z:
- Cursor AI'ya sorunuzu sorabilirsiniz
- Memory Bank sistemini kendi ihtiya?lar?n?za g?re ?zelle?tirebilirsiniz
- GitHub repository'sini inceleyebilirsiniz: https://github.com/vanzan01/cursor-memory-bank

---

**Not**: Bu dok?mantasyon T?rk?e olarak haz?rlanm??t?r. Memory Bank sistemi ?ngilizce ?al???r, ancak kullan?c?lar T?rk?e ileti?im kurabilir.
