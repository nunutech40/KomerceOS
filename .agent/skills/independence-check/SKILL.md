---
name: independence-check
description: Cek apakah perubahan yang akan dilakukan isolated atau menyenggol shared code. Wajib dijalankan sebelum implementasi apapun.
---

# Skill: Independence Check

Jalankan skill ini **sebelum mulai edit file apapun**.

## Instruksi

### Step 1: List file yang akan dibuat/dimodifikasi

Buat 2 daftar:
- **File BARU** — yang akan dibuat dari scratch
- **File EXISTING** — yang kontennya perlu diubah

### Step 2: Klasifikasi setiap file existing

Untuk setiap file existing, jawab: **"Apa yang diubah?"**

```
ADDITIVE (hanya menambah, tidak mengubah yang ada):
  → Tambah endpoint baru di constat_endpoint.dart     ← OK
  → Tambah key baru di constants.dart                 ← OK
  → Tambah GoRoute baru di router                     ← OK
  → Tambah DI registration baru di lib/DI/             ← OK

MODIFIKASI (mengubah behavior/signature yang sudah ada):
  → Ubah method signature di shared_pref.dart          ← BAHAYA
  → Ubah interceptor di dio_client.dart                ← BAHAYA
  → Ubah error handling di base_repository.dart        ← BAHAYA
  → Ubah field di Response model yang sudah dipakai    ← BAHAYA
```

### Step 3: Tentukan level

```
✅ LEVEL 1 — Fully Isolated
   Semua file baru. Shared hanya di-inject.
   → Langsung lanjut implementasi.

⚠️ LEVEL 2 — Shared Additive
   Ada file shared yang disentuh, tapi HANYA menambah.
   → grep_search dulu siapa yang pakai file tersebut.
   → Pastikan perubahan tidak mengubah yang sudah ada.
   → Catat: "File shared yang dimodifikasi: ..."

🔴 LEVEL 3 — Shared Destructive
   Ada file shared yang BEHAVIOR-nya harus diubah.
   → STOP. Pertimbangkan:
     a. Bisa bikin helper/util BARU yang independent?
     b. Bisa bikin subclass/wrapper?
     c. Kalau harus ubah shared → switch ke /solve-hard-problems
```

### Step 4: Laporkan ke user

```
"Fitur ini LEVEL [1/2/3]:
- File baru: [list]
- File shared yang disentuh: [list atau "tidak ada"]
- Potensi side effect: [atau "tidak ada"]
Lanjut?"
```
