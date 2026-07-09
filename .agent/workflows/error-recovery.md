---
description: Structured error recovery — no infinite loops. Adapted from HumanLayer's Factor 9 (Compact Errors) + Factor 8 (Own Control Flow).
---

# 🔧 Error Recovery Workflow

Memastikan error handling yang terstruktur tanpa spin-out atau infinite loop.
Diadaptasi dari HumanLayer's **"Compact Errors into Context Window" + "Own Your Control Flow"**.

**Output: Error log di `.agent/outputs/errors/[topik].md` (kalau error kompleks)**

---

## Prinsip Utama

1. **Error = Data** — Setiap error memberikan informasi untuk perbaikan
2. **Max 3 Attempts** — Jangan loop tanpa batas, eskalasi ke user setelah 3x
3. **Analyze, Don't Repeat** — Setiap attempt harus beda strategi
4. **Escalate Early** — Lebih baik tanya daripada buang waktu
5. **Log Complex Errors** — Error yang butuh >1 attempt, simpan ke file

---

## Error Recovery Protocol

### Attempt 1: Analyze & Fix
```
1. Baca error message dengan TELITI (jangan skim)
2. Identifikasi root cause:
   - Analyze error? → cek fvm flutter analyze output
   - Import error? → cek path, package name di pubspec.yaml
   - Type mismatch? → cek Entity vs Response model, parameter BLoC/UseCase
   - Null safety error? → cek nullable field, tambah null check
   - DI not registered? → cek lib/DI/ sudah daftarkan class baru
   - Build error? → cek flavor, Gradle, Pods
3. Terapkan fix yang targeted
4. Verify → fvm flutter analyze / fvm flutter test
```

### Attempt 2: Reassess Strategy
```
Kalau Attempt 1 gagal:
1. Jangan ulangi strategi yang sama!
2. Pertanyakan pendekatan:
   - Apakah pemahaman terhadap masalah sudah benar?
   - Ada file/context yang belum dibaca?
   - Ada pattern lain di codebase yang bisa diikuti?
3. Cari contoh serupa di codebase (grep_search)
4. Cek .agent/outputs/research/ dan .agent/outputs/plans/ untuk konteks relevan
5. Terapkan pendekatan yang BEDA
6. Verify lagi
```

### Attempt 3: Last Try with Fresh Eyes
```
Kalau Attempt 2 masih gagal:
1. Step back — lihat masalah dari sudut pandang berbeda
2. Pertimbangkan:
   - Version mismatch? Cek pubspec.yaml + pubspec.lock
   - Konflik dependency? Coba fvm flutter pub deps
   - FVM version mismatch? Cek .fvmrc (project pakai 3.35.5)
   - Generated code stale? Coba build_runner build --delete-conflicting-outputs
   - Gradle/Pods cache? Lihat /clean_build
3. Coba pendekatan yang completely different
4. Verify lagi
```

### Escalation: Contact Human
```
Kalau Attempt 3 masih gagal — STOP dan tanya user:

"Sudah coba 3 pendekatan berbeda untuk masalah ini:

1. [Attempt 1]: [apa yang dicoba] → [kenapa gagal]
2. [Attempt 2]: [apa yang dicoba] → [kenapa gagal]
3. [Attempt 3]: [apa yang dicoba] → [kenapa gagal]

Root cause yang dicurigai: [analisis]

Opsi yang bisa dicoba:
- A: [opsi A]
- B: [opsi B]

Mau lanjut yang mana, atau ada ide lain?"
```

---

## 💾 Log Error Kompleks (Opsional)

Untuk error yang butuh >1 attempt atau yang mungkin muncul lagi:

```
Buat file: .agent/outputs/errors/[topik].md

---
topic: [Fitur/layer yang bermasalah]
date: [Tanggal]
status: resolved | unresolved | escalated
resolution_attempts: [jumlah attempt]
---

## Error Description
[Error message lengkap dari flutter analyze / flutter test / Gradle]

## Root Cause
[Analisis root cause yang teridentifikasi]

## Attempts
### Attempt 1
- **Strategy:** [apa yang dicoba]
- **Result:** ❌ / ✅
- **Learning:** [apa yang dipelajari]

### Attempt 2
- **Strategy:** ...
- **Result:** ❌ / ✅
- **Learning:** ...

## Resolution
[Solusi yang berhasil / status eskalasi]

## Prevention
[Cara mencegah error ini di masa depan]
```

---

## Error Categories — Flutter Quick Reference

### Analyze / Compile Errors
| Error | First Check | Common Fix |
|---|---|---|
| `Target of URI doesn't exist` | Path import | Perbaiki path, cek nama file |
| `The method/getter X isn't defined` | Nama class/method | Cek typo, cek apakah file sudah import |
| `Type X can't be assigned to Y` | Entity vs Response mismatch | Tambah `toEntity()` / casting |
| `Null check operator on null` | Nullable field | Tambah null check / gunakan `?.` |
| `X isn't a subtype of Y` | BLoC State/Event | Periksa hierarchy class |
| `pub get` failed | pubspec.yaml conflict | Cek version constraint |

### Runtime / Logic Errors
| Error | First Check | Common Fix |
|---|---|---|
| `Bad state: No element` | List kosong diakses `.first` | Tambah guard `if (list.isNotEmpty)` |
| `Null pointer` pada state | BLoC emit urutan state salah | Cek initial state, urutan emit |
| Data tidak tampil di UI | BlocBuilder condition | Cek state type yang di-handle |
| `GetIt: Object not registered` | DI belum didaftarkan | Tambah register di `lib/DI/` |
| `DioException` di DataSource | Endpoint / payload | Cek `constat_endpoint.dart`, request body |
| Token expired / 401 | Interceptor / SecureStorage | Cek `dio_client.dart` interceptor |

### Build / Gradle / Pods Errors
| Error | First Check | Common Fix |
|---|---|---|
| Gradle build failed | Android SDK version | Jalankan `/clean_build` |
| `pod install` gagal | Podfile source | Pastikan CDN source di Podfile |
| FVM Flutter version mismatch | .fvmrc | Jalankan `fvm use` di root project |
| `build_runner` stale output | Generated mock | `dart run build_runner build --delete-conflicting-outputs` |

### BLoC / State Management Errors
| Error | First Check | Common Fix |
|---|---|---|
| State tidak berubah | Event tidak di-`add` | Cek apakah event di-dispatch dari View |
| BLoC emit setelah close | `tearDown` di test | Tambah `tearDown(() => bloc.close())` |
| `blocTest` expect salah | Urutan state | Cek apakah ada emit sebelum Loading (initial) |

---

## Anti-Patterns ❌

- **Error Spinning** — mencoba hal yang sama berulang kali
- **Panic Fix** — ubah banyak file sekaligus tanpa analisis
- **Ignore Analyze** — lanjut tanpa `fvm flutter analyze` dulu
- **Silent Ignore** — skip error dan lanjut ke task lain
- **No Documentation** — error kompleks tidak di-log, bisa muncul lagi
