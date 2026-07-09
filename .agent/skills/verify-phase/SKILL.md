---
name: verify-phase
description: Jalankan verifikasi automated + manual setelah menyelesaikan setiap phase implementasi.
---

# Skill: Verify Phase

Jalankan skill ini **setelah selesai setiap phase** implementasi.

## Instruksi

### Step 1: Automated Verification

// turbo
```bash
# 1. Static analysis — HARUS bersih, no errors
fvm flutter analyze

# 2. Unit test (kalau ada test untuk phase ini)
fvm flutter test test/core/data/...       # data layer
fvm flutter test test/core/domain/...     # domain layer
fvm flutter test test/features/<fitur>/   # presentation layer

# 3. Build check (opsional, kalau mau validasi end-to-end)
fvm flutter run --flavor dev --dart-define=FLAVOR=dev
```

**Semua harus pass sebelum lanjut.**
Kalau ada yang gagal → perbaiki (max 3 attempt, lihat skill `error-recovery`).

### Step 2: Update Plan

```
Buka .agent/outputs/plans/[topik].md:
1. Update status phase: ⬜ → ✅
2. Update phases_completed di frontmatter
3. Catat keputusan baru di Decisions Log (jika ada)
4. Catat progress di Progress Notes
```

### Step 3: Manual Verification (minta user)

```
"Phase [X] automated checks pass ✅
Tolong cek manual:
- [ ] [item spesifik yang perlu di-test manual]
- [ ] [edge case yang tidak bisa di-test automated]
Sudah oke? Lanjut ke Phase berikutnya?"
```

**JANGAN lanjut ke phase berikutnya tanpa konfirmasi user.**
