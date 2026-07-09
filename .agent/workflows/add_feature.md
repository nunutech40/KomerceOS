---
description: Menambahkan fitur baru sesuai clean architecture + BLoC pattern yang dipakai project
---

# Add Feature — komtim_partner

Diadaptasi dari filosofi HumanLayer: **Context First, Then Execute.**

**Output: File plan di `.agent/outputs/plans/[nama-fitur].md`**

---

## Phase 1: Context & Impact Analysis (WAJIB)

### 1.1 Cek Existing Research & Plan
// turbo
```
Cek apakah sudah ada research/plan sebelumnya:
- .agent/outputs/research/[nama-fitur].md
- .agent/outputs/plans/[nama-fitur].md
Kalau sudah ada → review & update, skip ke Phase 2
Kalau belum ada → lanjut
```

### 1.2 Pre-fetch Konteks

**→ Jalankan skill `pre-fetch-context`**

### 1.3 Independence Check

**→ Jalankan skill `independence-check`**

Hasil:
- Level 1 atau 2 → lanjut ke Plan
- Level 3 → STOP, switch ke `/solve-hard-problems`

### 1.4 Simpan Research

**→ Jalankan skill `save-research`**

### 1.5 Buat Implementation Plan
```
Simpan ke: .agent/outputs/plans/[nama-fitur].md

---
topic: [Nama Fitur]
date: [Tanggal]
status: in-progress
independence_level: 1 | 2
shared_files_touched: []
phases_total: 4
phases_completed: 0
---

### Phase 1: Data Layer (Response + DataSource + Repository Impl)
**Status:** ⬜
**Files baru:**
- [ ] `lib/core/data/models/<fitur>_response.dart`
- [ ] `lib/core/data/datasources/remote/<fitur>_remote_datasource.dart`
- [ ] `lib/core/data/repositories/<fitur>_repository_impl.dart`

### Phase 2: Domain Layer (Entity + Repository Interface + UseCase)
**Status:** ⬜
**Files baru:**
- [ ] `lib/core/domain/entities/<fitur>_model.dart`
- [ ] `lib/core/domain/repositories/<fitur>_repository.dart`
- [ ] `lib/core/domain/usecases/get_<fitur>_use_case.dart`

### Phase 3: Presentation Layer (BLoC + View)
**Status:** ⬜
**Files baru:**
- [ ] `lib/features/<fitur>/bloc/<fitur>_event.dart`
- [ ] `lib/features/<fitur>/bloc/<fitur>_state.dart`
- [ ] `lib/features/<fitur>/bloc/<fitur>_bloc.dart`
- [ ] `lib/features/<fitur>/view/<fitur>_page.dart`

### Phase 4: Wiring (DI + Route)
**Status:** ⬜
**Files dimodifikasi (additive):**
- [ ] `lib/DI/...` — tambah registrasi
- [ ] Router — tambah GoRoute
```

### 1.6 Confirm Plan dengan User
```
Tanya: "Plan sudah sesuai? Mulai dari Phase berapa?"
```

---

## Phase 2: Implementation (Bottom-Up)

Urutan wajib — jangan loncat layer:

```
1. Response Model   → lib/core/data/models/
2. Remote DataSource → lib/core/data/datasources/remote/
3. Entity           → lib/core/domain/entities/
4. Repo Interface   → lib/core/domain/repositories/
5. Repo Impl        → lib/core/data/repositories/
6. Use Case         → lib/core/domain/usecases/
7. BLoC             → lib/features/<fitur>/bloc/
8. View/Page        → lib/features/<fitur>/view/
9. DI               → lib/DI/
10. Route           → router/config
```

### Referensi Pattern

**→ Baca skill `codebase-patterns` sebelum bikin file baru.**

Skill ini berisi pattern lengkap: model vs response naming, DataSource, Repository (BaseRepository + executeEither), UseCase, BLoC (part of), DI urutan, dan semua helpers (date/currency/string/widgets).

### Siklus per File
```
1. Baca skill codebase-patterns untuk pattern layer ini
2. Buat file baru mengikuti pattern
3. Butuh format tanggal? → pakai CustomDateFormat / timeConvert (jangan bikin baru)
4. Butuh format uang? → pakai CurrencyFormat (jangan bikin baru)
5. Butuh widget umum? → cek lib/common/global/widgets/ dulu
6. fvm flutter analyze → harus bersih
7. Kalau error → max 3 attempt (lihat /error-recovery)
8. Kalau 3x gagal → STOP, tanya user
```

### Setelah Selesai Setiap Phase

**→ Jalankan skill `verify-phase`**

### Unit Test per Phase (opsional, tapi direkomendasikan)

Tulis test **bersamaan** dengan implementasi, bukan nanti:

```
Setelah Phase 1 (Data Layer):
  → skill `unit-test-response`
  → skill `unit-test-datasource-remote`
  → skill `unit-test-repository`

Setelah Phase 2 (Domain Layer):
  → skill `unit-test-usecase`

Setelah Phase 3 (Presentation Layer):
  → skill `unit-test-bloc`

Generate mock + run:
  fvm dart run build_runner build --delete-conflicting-outputs
  fvm flutter test
```

Atau jalankan `/add_unit_test` setelah semua phase selesai.

---

## Checklist Master

### Phase 1 — Data Layer
- [ ] `<fitur>_response.dart` — `fromJson`, `toJson`, `toEntity()` → konversi ke `<fitur>_model.dart`
- [ ] `<fitur>_remote_datasource.dart` — abstract + impl, inject DioClient + DioResponseParser
- [ ] `<fitur>_repository_impl.dart` — extends BaseRepository, gunakan `executeEither()`
- [ ] *(Test)* `test/core/data/models/<fitur>_response_test.dart`
- [ ] *(Test)* `test/core/data/datasources/remote/<fitur>_remote_datasource_test.dart`
- [ ] *(Test)* `test/core/data/repositories/<fitur>_repository_impl_test.dart`

### Phase 2 — Domain Layer
- [ ] `<fitur>_model.dart` — extends Equatable (entity di project ini dinamai *_model.dart)
- [ ] `<fitur>_repository.dart` — abstract interface
- [ ] `get_<fitur>_use_case.dart`
- [ ] *(Test)* `test/core/domain/usecases/get_<fitur>_use_case_test.dart`

### Phase 3 — Presentation Layer
- [ ] `<fitur>_event.dart`, `<fitur>_state.dart`, `<fitur>_bloc.dart`
- [ ] `<fitur>_page.dart` — BlocProvider + BlocBuilder/BlocListener
- [ ] *(Test)* `test/features/<fitur>/bloc/<fitur>_bloc_test.dart`

### Phase 4 — Wiring
- [ ] DI: DataSource → Repository → UseCase (urutan ini)
- [ ] Route: GoRoute ditambahkan
- [ ] `fvm flutter analyze` bersih
- [ ] `fvm flutter test` pass

### Independence
- [ ] Level ditentukan (skill `independence-check`)
- [ ] Jika Level 2: shared files dicatat di plan
- [ ] Jika Level 3: STOP → `/solve-hard-problems`
