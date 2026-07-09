---
name: pre-fetch-context
description: Kumpulkan semua konteks yang dibutuhkan sebelum ngoding. Untuk fitur baru atau debugging.
---

# Skill: Pre-fetch Context

Jalankan skill ini **sebelum mulai coding** untuk memastakan AI punya konteks yang cukup.

## Instruksi

### Untuk Fitur Baru

Baca/scan file-file ini secara berurutan:

```
// turbo
1. Fitur serupa di lib/features/ sebagai referensi pattern
   → Pilih fitur yang paling mirip scope-nya
   → Baca bloc, view, dan data flow-nya

// turbo
2. Core yang akan di-extend:
   □ lib/core/data/apiservice/constat_endpoint.dart  → endpoint tersedia?
   □ lib/core/data/apiservice/dio_response_parser.dart → method yang bisa dipakai
   □ lib/common/failure.dart                          → tipe failure yang ada
   □ lib/common/constants.dart                        → key yang sudah dipakai

// turbo
3. DI & Router:
   □ lib/DI/                           → pola registrasi yang dipakai
   □ Router/config file                → pola route yang dipakai

// turbo
4. Existing Research & Plans:
   □ .agent/outputs/research/          → research sebelumnya
   □ .agent/outputs/plans/             → plan yang sudah ada

// turbo
5. Knowledge Items:
   □ Cek KI summaries yang relevan
   □ Baca artifact dari KI jika ada yang match
```

### Untuk Debugging

```
// turbo
1. File yang error (baca error message teliti)
2. File yang memanggil file tersebut (caller) — grep_search
3. File yang dipanggil oleh file tersebut (dependency)
4. Test file yang relevan
5. Shared file yang mungkin jadi root cause:
   - dio_client.dart (interceptor, token)
   - shared_pref.dart (cache, login state)
   - base_repository.dart (error handling)
```

### Output

Setelah pre-fetch, sampaikan ke user:
```
"Konteks yang sudah ditemukan:
- Layer yang terlibat: ...
- Pattern yang diikuti: ... (referensi: <file serupa>)
- File shared yang terpengaruh: ...
- Potential risks: ...
- Mulai dari mana?"
```
