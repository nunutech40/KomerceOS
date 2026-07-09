# 🤖 Sistem Auto-Pilot Agent (`.agent/`)

Folder `.agent/` ini **bukan** folder bawaan Flutter, melainkan pusat kendali (brain) untuk AI Agent seperti saya (Antigravity/Gemini) dalam mengelola project `komtim_partner`. 

Fungsi utama dari sistem ini adalah **mengurangi halusinasi ("vibe coding")**, menyamakan standar *coding* antar developer, dan menyediakan sistem *troubleshooting* terukur ketika terjadi error.

Di dalamnya terdiri dari 3 pilar utama:

## 1. `rules.md` (Aturan Dasar)
Ini adalah "kitab suci" yang tidak pernah dilupakan AI di setiap percakapan. 
Setiap kali kamu membuka *chat* baru, AI **secara otomatis** akan membaca file ini. Tidak perlu disuruh. Isinya memuat:
- Pola arsitektur (Clean Architecture).
- Naming convention wajib (misalnya file model dinamai `*_model.dart`).
- Pattern yang tidak boleh dilanggar (misalnya *BaseRepository.executeEither*).
- Daftar file sakral (core files) yang tidak boleh diubah sembarangan tanpa check independensi.

*(Sistem AI akan selalu patuh pada rules ini setiap kali diinstruksikan menulis koding).*

## 2. `workflows/` (Perintah / Entry Points)
Workflow adalah serangkaian instruksi "how-to". Anggap ini sebagai perintah Makro / `/slash-commands` yang kamu perintahkan kepada AI. AI akan mengikuti langkah-demi-langkah (step-by-step) untuk menyelesaikan suatu tugas besar.

**Daftar Workflow yang tersedia lewat Chat:**
- `@[/add_feature]`: Cara standard untuk membuat fitur baru (Data → Domain → Presentation).
- `@[/solve-hard-problems]`: Prosedur pemecahan masalah rumit / refactoring tanpa menebak-nebak kode.
- `@[/context-engineering]`: Fase pemanasan. AI disuruh mencari tahu struktur kode sebelumnya agar tidak menabrak hal yang sudah ada.
- `@[/add_unit_test]`: Membimbing AI untuk menambahkan Unit Test dengan standard yang benar.
- `@[/error-recovery]`: Strategi memperbaiki error kompilasi/run agar tidak *infinite-loop* dalam menebak solusi.
- `@[/run_dev]` & `@[/clean_build]`: Utilities shortcut untuk testing manual.

*(Kamu bisa memanggilnya di prompt dengan mengetikkan nama filenya, misalnya: "@[/add_feature] tolong buatin fitur Shopping Cart")*.

## 3. `skills/` (Fungsi Modular & Referensi Detail)
Skill adalah sub-kemampuan kecil yang "dipanggil" oleh *Workflows* di atas. Kamu tidak perlu menspesifikasi skill sendiri, biasanya file Workflow yang secara otomatis akan 'memerintahkan' AI untuk membuka skill tertentu.

Skill berisi detail spesifik tentang suatu hal:
- Algoritma spesifik pembuatan mock (cth: `unit-test-bloc`).
- Pattern koding detail (cth: `codebase-patterns`).
- Langkah deteksi resiko sistematic (cth: `independence-check` dan `pre-fetch-context`).
- Kemampuan menulis otomatis ke disk (cth: `save-research` untuk membuat file riwayat di `.agent/outputs/`).

---

## 🎯 Contoh Cara Kerjanya (Simulasi)

1. Kamu mengetik: `"@[/add_feature] Tolong buatin fitur Invoice History"`
2. AI **menerima workflow `add_feature.md`** yang isinya menyuruh AI:
    - *Step 1: Jalankan skill pre-fetch-context* (AI diam-diam scanning folder).
    - *Step 2: Jalankan skill independence-check* (AI mikir apakah fitur ini merusak sistem yang lain).
    - *Step 3: Baca skill codebase-patterns* (AI mempelajari bahwa modelnya bernama `invoice_model.dart`).
    - *Step 4: Execute & Unit Test* (AI ngoding dan otomatis menggunakan skill unit testing di setiap fasa).

### Keuntungan Buat Kamu:
- Kamu tidak usah "ngomel" berulang kali ke AI tentang cara menulis BLoC atau penamaan folder. 
- Standar kualitas AI menjadi **konsisten** karena diawasi oleh standar operasional (.agent/) yang sama!
