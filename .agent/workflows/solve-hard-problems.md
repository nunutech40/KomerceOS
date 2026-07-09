---
description: Solve hard coding problems in complex codebases without "vibe coding". Adapted from HumanLayer's 12-Factor Agents & Context Engineering methodology.
---

# 🚫 No Vibes Allowed — Solving Hard Problems

Diadaptasi dari HumanLayer's **12-Factor Agents + Advanced Context Engineering**.
Gunakan untuk task yang kompleks, refactoring, debugging deep, atau modifikasi shared code.

**Prinsip utama: Jangan langsung ngoding. Bangun konteks dulu, baru eksekusi.**

**Output: File plan di `.agent/outputs/plans/[topik].md`**

---

## Phase 1: Context Engineering (WAJIB sebelum nulis kode)

### 1.1 Cek Existing Research & Plan
// turbo
```
Cek .agent/outputs/research/ dan .agent/outputs/plans/:
- Sudah ada plan → review & update, skip ke Phase 2
- Sudah ada research → skip ke 1.4
- Belum ada → lanjut
```

### 1.2 Pre-fetch All Context

**→ Jalankan skill `pre-fetch-context`**

### 1.3 Cek Knowledge Items
// turbo
- Cek KI summaries yang relevan
- Baca artifact dari KI yang match
- Cek conversation history kalau ada diskusi terkait

### 1.4 Independence Check

**→ Jalankan skill `independence-check`**

Semua level bisa lanjut di workflow ini (termasuk Level 3).
Tapi Level 3 butuh extra caution di Phase 2.

### 1.5 Simpan Research

**→ Jalankan skill `save-research`**

### 1.6 Buat Implementation Plan
```
Simpan ke: .agent/outputs/plans/[topik].md

---
topic: [Topik/fitur/bug]
date: [Tanggal]
status: in-progress
independence_level: 1 | 2 | 3
shared_files_touched: []
research: ../research/[topik].md
phases_total: [jumlah]
phases_completed: 0
---

### Phase N: [Nama Phase]
**Status:** ⬜
**Files:**
- [ ] `path/to/file` — [apa yang diubah]

**Steps:**
1. [Detail step]

**Success Criteria:**
Automated:
- [ ] `fvm flutter analyze` bersih
- [ ] `fvm flutter test test/...` pass

Manual:
- [ ] [Verifikasi spesifik]

## Testing Strategy
[Apa yang di-test, mock strategy]

## Risks & Mitigations
- **Risk:** ... → **Mitigation:** ...

## Decisions Log
- [Keputusan]: [Alasan]

## Progress Notes
- [tanggal] — [catatan]
```

### 1.7 Confirm Plan dengan User
```
Tanya: "Plan sudah sesuai? Mau mulai Phase berapa?"
```

---

## Phase 2: Small, Focused Execution

### 2.1 Urutan Implementasi (Bottom-Up)
```
1. Data Layer → 2. Domain Layer → 3. Presentation Layer
Pecah jadi unit kecil, setiap unit bisa diverifikasi independen.
```

### 2.2 ⚠️ Shared Code (Level 2 & 3)
```
SEBELUM edit file shared:
1. grep_search siapa yang pakai
2. List semua caller/consumer
3. Backward-compatible?
   → YA (additive) → langsung edit
   → TIDAK (breaking) → bikin variant baru ATAU update semua caller
4. Setelah edit → verify semua fitur yang depend
```

### 2.3 Referensi Pattern & Helpers

**→ Baca skill `codebase-patterns` sebelum bikin/ubah file.**

Skill berisi: pattern per layer (model vs response, DataSource, Repository, UseCase, BLoC), naming conventions, DI urutan, dan semua helpers yang tersedia (date/currency/string/widgets).

**Cek helper dulu, jangan bikin duplikat:**
- Format tanggal → `CustomDateFormat` / `timeConvert` (sudah ada)
- Format uang → `CurrencyFormat` (sudah ada)
- Widget umum → cek `lib/common/global/widgets/` dulu
- String label → cek `Strings.label_xxx` di `lib/common/string.dart`

### 2.4 Siklus per Edit
```
1. Check — shared? (skill independence-check, sudah jalan di Phase 1)
2. Baca skill codebase-patterns untuk pattern layer ini
3. Edit — ikuti pattern, pakai helper yang sudah ada
4. Verify — fvm flutter analyze
5. Error? → max 3 attempt (lihat /error-recovery)
6. 3x gagal → STOP, tanya user
```

### 2.4 Setelah Selesai Setiap Phase

**→ Jalankan skill `verify-phase`**

---

## Phase 3: Verification & Human Contact

### 3.1 Final Verification

**→ Jalankan skill `verify-phase`** untuk phase terakhir

### 3.2 Contact Human untuk:
- **Approval** — hapus file, ubah schema, modifikasi shared core
- **Clarification** — requirement ambigu
- **Review** — setelah selesai, jelaskan apa dan kenapa

### 3.3 Final Update Plan & Summary
```
Update .agent/outputs/plans/[topik].md:
- status: completed
- Semua phase ✅
- Final notes di Progress Notes

Summary ke user:
- File yang diubah
- Keputusan non-obvious
- Test yang ditulis dan pass
- Limitasi
- "Detail: .agent/outputs/plans/[topik].md"
```

---

## Anti-Patterns ❌
- **Vibe Coding** — langsung nulis tanpa baca codebase
- **Boil the Ocean** — ubah semua layer sekaligus
- **Error Spinning** — loop dengan strategi sama
- **Ignore Existing Patterns** — bikin pattern baru padahal `base_repository.dart` sudah ada
- **Skip DI** — buat class tapi lupa daftarkan
- **Throwaway Research** — research tanpa simpan

## Best Practices ✅
- **Context First** — minimal 30% effort di Phase 1
- **Bottom-Up** — data layer → domain → presentation
- **Skills Composable** — pakai skills di atas, jangan duplicate langkah
- **Small Steps** — 1 phase = 1 layer, verify dulu sebelum lanjut
- **Save Everything** — research + plan ke `.agent/outputs/`
