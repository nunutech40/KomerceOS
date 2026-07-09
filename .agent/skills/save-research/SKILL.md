---
name: save-research
description: Simpan hasil research ke file agar bisa dipakai di sesi berikutnya.
---

# Skill: Save Research

Jalankan skill ini **setelah selesai research/context gathering**.

## Instruksi

### Versioning Rule

```
PRINSIP: 1 file = 1 source of truth. Konten SELALU versi terbaru.

KALAU file untuk topik ini SUDAH ADA di .agent/outputs/research/:
  → UPDATE konten yang berubah (jangan duplicate)
  → Update field `version` dan `date` di frontmatter
  → Tambah entry di section "Changelog" di bawah

KALAU belum ada:
  → Buat file baru dengan version: 1

JANGAN:
  → Copy-paste seluruh konten lama sebagai "archived version"
  → Bikin file jadi bloated
```

### Format File

```
Buat/update file: .agent/outputs/research/[topik-singkat].md

---
topic: [Nama fitur/task]
date: [Tanggal terakhir update]
version: [nomor, mulai dari 1]
status: completed
related_files:
  - lib/features/<fitur>/...
  - lib/core/data/...
---

# Research: [Topik]

## Summary
[2-3 kalimat tentang apa yang ditemukan]

## File yang Relevan
- `path/to/file` — [peran]
[dst...]

## Architecture / Data Flow
[Alur data: View → BLoC → UseCase → Repo → DataSource → API]

## Existing Patterns yang Diikuti
- [Pattern 1]
- [Pattern 2]

## Risks & Edge Cases
- [Risk/edge case]

## Notes
[Catatan tambahan]

---

## 📋 Changelog
| Versi | Tanggal    | Perubahan            |
|-------|------------|----------------------|
| v1    | YYYY-MM-DD | Initial research     |
```
