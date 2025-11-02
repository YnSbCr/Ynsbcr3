# Memory Bank Proje Plan?

## ?? Proje Durumu

### Kurulum Tamamland? ?

- [x] Memory Bank dosyalar? kopyaland?
- [x] `.cursor/rules` klas?r? olu?turuldu
- [x] `custom_modes` klas?r? olu?turuldu
- [x] `memory_bank` klas?r? ve temel dosyalar olu?turuldu

### Yap?lmas? Gerekenler ?

- [ ] Custom modes'lar? Cursor'a manuel olarak ekleme
- [ ] ?lk VAN analizini ?al??t?rma
- [ ] Proje karma??kl?k seviyesini belirleme

---

## ?? Proje Analizi

### Teknoloji Stack

| Katman | Teknoloji |
|--------|-----------|
| Frontend | React 18.3.1 + TypeScript |
| Build Tool | Vite 5.4.19 |
| Backend | Express 4.21.2 + TypeScript |
| Database | PostgreSQL + Drizzle ORM 0.39.3 |
| UI Components | Radix UI |
| Styling | Tailwind CSS 3.4.17 |
| State Management | React Query 5.60.5 |
| Authentication | Passport.js |
| Session | Express Session + PostgreSQL Store |

### Mevcut Proje Yap?s?

```
/
??? .cursor/                    # Memory Bank kurallar?
?   ??? rules/
?       ??? isolation_rules/
??? custom_modes/               # Custom mode talimatlar?
??? memory_bank/                # Memory Bank veri dosyalar?
?   ??? tasks.md
?   ??? activeContext.md
?   ??? progress.md
?   ??? projectbrief.md
??? server/                     # Backend kodlar?
??? client/                     # Frontend kodlar? (muhtemelen)
??? shared/                     # Payla??lan kodlar
??? drizzle.config.ts
??? package.json
??? tsconfig.json
??? vite.config.ts
```

---

## ?? ?nerilen Geli?tirme Plan?

### Faz 1: Proje Analizi ve Kurulum (VAN Mode)

**Ama?**: Projenin mevcut durumunu anlamak ve Memory Bank sistemini entegre etmek

**G?revler**:
1. VAN modunu kullanarak proje analizi
2. Proje karma??kl?k seviyesini belirleme
3. Mevcut kod yap?s?n? dok?mante etme
4. Gerekli ba??ml?l?klar? kontrol etme

**Beklenen ??kt?**:
- `memory_bank/projectbrief.md` g?ncellenmi? hali
- Karma??kl?k seviyesi belirlenmi? (Level 1-4)
- Proje yap?s? analiz edilmi?

---

### Faz 2: Backend Altyap?s? (PLAN + IMPLEMENT Mode)

**Ama?**: Backend API yap?s?n? kurmak ve temel endpoint'leri olu?turmak

**G?revler**:
1. API route yap?s?n? planlama
2. Authentication middleware'leri kurma
3. Database connection yap?land?rmas?
4. Temel CRUD endpoint'leri olu?turma
5. Error handling sistemi kurma

**Beklenen ??kt?**:
- ?al??an REST API
- Authentication sistemi
- Database ba?lant?lar?

---

### Faz 3: Frontend Geli?tirme (CREATIVE + IMPLEMENT Mode)

**Ama?**: Modern ve kullan?c? dostu bir frontend aray?z? olu?turmak

**G?revler**:
1. UI/UX tasar?m kararlar? (CREATIVE mode)
2. Component library kurulumu
3. Routing yap?s? (Wouter kullan?l?yor)
4. State management entegrasyonu
5. API entegrasyonu
6. Form validation ve error handling

**Beklenen ??kt?**:
- ?al??an frontend uygulamas?
- Responsive tasar?m
- API entegrasyonu tamamlanm??

---

### Faz 4: Entegrasyon ve Test (IMPLEMENT + QA Mode)

**Ama?**: Frontend ve backend'i entegre etmek ve test etmek

**G?revler**:
1. API endpoint'lerini frontend'e ba?lama
2. Authentication flow'unu test etme
3. Error handling'i test etme
4. Performance optimizasyonu
5. QA kontrolleri

**Beklenen ??kt?**:
- Tam entegre ?al??an sistem
- Test edilmi? ?zellikler
- Performans optimizasyonlar?

---

### Faz 5: Dok?mantasyon ve Finalizasyon (REFLECT + ARCHIVE Mode)

**Ama?**: Projeyi dok?mante etmek ve son kontrolleri yapmak

**G?revler**:
1. Kod incelemesi ve iyile?tirmeler
2. README g?ncellemeleri
3. API dok?mantasyonu
4. Kod i?i yorumlar
5. Deployment haz?rl?klar?

**Beklenen ??kt?**:
- Kapsaml? dok?mantasyon
- Production-ready kod
- Deployment rehberi

---

## ?? Memory Bank Kullan?m ?rnekleri

### ?rnek 1: Yeni ?zellik Eklemek

```bash
# 1. VAN moduna ge?in ve analiz yap?n
VAN

# 2. PLAN moduna ge?in ve plan olu?turun
PLAN

# 3. Karma??k ?zellikse CREATIVE modunu kullan?n
CREATIVE

# 4. IMPLEMENT modunda geli?tirin
IMPLEMENT

# 5. QA kontrol? yap?n
QA

# 6. REFLECT modunda inceleme yap?n
REFLECT

# 7. ARCHIVE modunda dok?mante edin
ARCHIVE
```

### ?rnek 2: Bug D?zeltme

```bash
# 1. VAN modunda h?zl? analiz
VAN

# 2. Do?rudan IMPLEMENT moduna ge?in (Level 1)
IMPLEMENT

# 3. REFLECT modunda k?sa inceleme
REFLECT
```

---

## ?? CREATIVE Mode Kullan?m Senaryolar?

CREATIVE mode ?u durumlarda kullan?lmal?d?r:

1. **Yeni Mimari Kararlar**: B?y?k sistem tasar?m? gerektiren durumlar
2. **UI/UX Tasar?m?**: Kullan?c? aray?z? tasar?m kararlar?
3. **Teknoloji Se?imi**: Yeni teknolojilerin entegrasyonu
4. **Performans Optimizasyonu**: Optimizasyon stratejileri

---

## ?? QA Mode Kullan?m?

QA mode herhangi bir moddan ?a?r?labilir:

```bash
QA
```

QA modu ?unlar? kontrol eder:
- Kod kalitesi
- Potansiyel bug'lar
- G?venlik sorunlar?
- Performans sorunlar?
- Best practice'lere uyum

---

## ?? ?lerleme Takibi

Memory Bank sistemi otomatik olarak ?u dosyalarda ilerlemeyi takip eder:

- **`memory_bank/tasks.md`**: T?m g?revler ve durumlar?
- **`memory_bank/progress.md`**: ?mplementasyon ilerlemesi
- **`memory_bank/activeContext.md`**: Mevcut ?al??ma ba?lam?

---

## ?? Sonraki Ad?mlar

1. ? Memory Bank dosyalar? kuruldu
2. ? Custom modes'lar? Cursor'a ekleyin
3. ? ?lk VAN analizini ?al??t?r?n:
   ```
   VAN
   ```
4. ? ??kan sonu?lara g?re plan yap?n:
   ```
   PLAN
   ```

---

## ?? ?pu?lar?

1. **Her zaman VAN ile ba?lay?n**: Proje analizi i?in VAN modunu kullan?n
2. **Karma??kl?k seviyesine g?re hareket edin**: Level 1 g?revler i?in CREATIVE mode atlanabilir
3. **QA'y? d?zenli kullan?n**: Kod kalitesi i?in QA modunu s?k?a ?al??t?r?n
4. **Dok?mantasyonu g?ncel tutun**: ARCHIVE modunu d?zenli kullan?n
5. **Memory Bank dosyalar?n? otomatik y?netin**: Dosyalar? manuel d?zenlemeyin

---

**Son G?ncelleme**: Memory Bank kurulumu tamamland?. Custom modes'lar? ekleyerek ba?layabilirsiniz!
