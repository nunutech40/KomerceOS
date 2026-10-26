# QA Board Revisi — Komerce OS

Dokumen kerja QA untuk tiga task pada board **Revisi**. Catatan ini memisahkan requirement task, referensi Figma, skenario uji, dan hasil aktual agar isu tidak tercampur.

## Ruang lingkup

| ID | Task | Figma | Status QA |
|---|---|---|---|
| KMC-02691 | Rekening Bank (Security, Verification, & Cost Efficiency) | Sprint 3, node `1237-9569` | Sedang diuji |
| KMC-02497 | Security Restriction: Pembatasan Akses Login & Verifikasi Email untuk Role Team Internal | Sprint 1 node `2-576`; Sprint 3 node `5-26154` | Sebagian diuji |
| KMC-02693 | Sistem Autentikasi PIN Akun | Sprint 3, node `1237-15579` | Sebagian diuji |

Kredensial tidak berada di repository. Lihat `.qa/revision_test_accounts.local.md` hanya pada mesin lokal.

## KMC-02691 — Rekening Bank

### Flow yang ditargetkan

1. Pengaturan → Informasi Akun → Rekening Bank.
2. Verifikasi PIN 6 digit sebagai gatekeeper.
3. Sistem mengecek kelengkapan profil.
4. Jika lengkap, tampil daftar rekening/tambah rekening; jika tidak, tampil modal untuk melengkapi profil.
5. Form tambah rekening mendukung pilih/cari bank, nomor rekening maksimal 20 digit, maksimal 6 rekening.

### Skenario device

| Kasus akun | Ekspektasi | Aktual |
|---|---|---|
| KYC + punya rekening + tanggungan | Restriksi tanggungan saldo diterapkan dengan pesan yang jelas; tidak ada `-1` atau logout | **Pass untuk daftar rekening/PIN gate:** `testsuper2` memuat 6 rekening dari `GET /api/v1/bank-account` HTTP 200 tanpa `-1` atau logout. Skenario tanggungan belum dipicu karena kuota rekening sudah penuh dan tidak boleh memodifikasi data. |
| `testsuper6` — belum punya rekening | Gatekeeper PIN → daftar kosong/tambah rekening | **Pass**: halaman empty state `Tidak Ada Rekening Bank` dan tombol `Tambah Rekening` aktif |
| Data profil belum lengkap + punya PIN | Setelah PIN benar, modal kelengkapan profil; tidak masuk form tambah rekening | Belum diuji |

### Temuan awal

- Figma tidak mendefinisikan kelanjutan API untuk pengajuan alasan tanggungan. Field alasan diperlakukan sebagai interaksi UI/validasi saja; tidak ada asumsi bahwa harus mengirim endpoint atau meneruskan penambahan rekening.
- `testsuper6`, build dev `1.1.1` (26 Okt 2026): PIN gatekeeper berhasil membuka halaman Rekening Bank. Menekan `Tambah Rekening` menampilkan modal `Profil Belum Lengkap Nih` / `Lengkapi Profil`; tidak membuka form tambah rekening. Ini sesuai flow gatekeeper kelengkapan profil.
- `testsuper5` (akun yang digunakan pada video error `-1`): login, gatekeeper PIN, dan halaman Rekening Bank empty state berhasil pada build dev `1.1.1`; error `-1` **tidak ter-reproduksi**. Tombol `Tambah Rekening` aktif. Tahap submit tidak diuji agar tidak menciptakan rekening.
- Akun KYC + rekening + tanggungan: PIN valid membuka daftar enam rekening tersimpan. Tombol `Tambah Rekening` nonaktif karena limit enam rekening. Tidak ada error `-1` maupun logout selama pemeriksaan read-only. Skenario operasi yang memicu restriksi tanggungan sengaja belum dijalankan agar tidak mengubah data.
- `testsuper2` (26 Okt 2026, build dev): check-email dan login dibuka manual oleh pemilik akun, lalu alur **Pengaturan → Informasi Akun → Rekening Bank → PIN** berhasil. PIN valid menampilkan enam rekening; Chucker mencatat `GET /api/v1/bank-account` HTTP 200. Membuka **PIN → Ubah PIN** juga tidak mengarahkan sesi ke halaman email. Tidak ada perubahan rekening atau PIN yang dikirim.
- `testsuper2` (26 Okt 2026, build dev): setelah pemeriksaan di atas, aplikasi di-*force-stop* lalu dibuka ulang. Sesi dipulihkan ke **Home** dengan data akun aktif; tidak muncul halaman email, `-1`, atau logout otomatis. Ini memverifikasi penyimpanan/pemulihan token untuk jalur restart aplikasi secara read-only.
- Video tester memperlihatkan indikator loading di item Rekening Bank lalu tester melaporkan `-1` pada akun lain.
- `-1` adalah error transport/client tanpa HTTP response, bukan state bisnis yang didefinisikan task. Endpoint, Dio error, dan UI retry perlu direkam saat reproduksi.

## KMC-02497 — Pembatasan role Team Internal

### Flow yang ditargetkan

1. Akun role Team Internal memasukkan email/password.
2. BE merespons `403` dan `ERR_ROLE_TEAM_INTERNAL_BLOCKED`; token/JWT tidak dibuat.
3. App menampilkan dialog **Akses Tidak Diizinkan** dengan copy task; tidak menyimpan token dan tidak masuk Home.
4. Partner/Owner tetap login normal tanpa dampak.

### Skenario device

| Kasus akun | Ekspektasi | Aktual |
|---|---|---|
| `testsuper6` — akun partner normal | Login stabil, satu kali navigasi ke Home, tanpa flicker | **Pass (observasi manual)**: check-email → password → Home berhasil; tidak muncul dialog akses-role atau redirect ulang |
| Akun Team Internal | Dialog Figma, tidak masuk Home, token tidak tersimpan | Belum ada akun uji role Team Internal |

### Temuan awal

- Video tester memperlihatkan halaman email login merender bertumpuk/ghosting sebelum stabil. Ini bukan tampilan yang ditentukan Figma dan harus diperlakukan sebagai regresi UI Auth.
- Error umum/transport tidak boleh diperlakukan sebagai `ERR_ROLE_TEAM_INTERNAL_BLOCKED` atau menghapus sesi.

### Pemeriksaan implementasi (26 Okt 2026)

- **Temuan sebelum perbaikan:** Team Internal pernah terdeteksi sebagai `isOtherRoleError`, lalu ditampilkan sebagai bottom sheet **Akun Terdaftar di Peran Lain** dan CTA Customer Support. Jalur ini telah dipisahkan pada perbaikan 26 Okt di bawah.
- **Belum dapat diuji end-to-end:** tidak ada akun test role Team Internal pada daftar akun. Diperlukan satu akun khusus untuk memastikan respons BE benar-benar `403` dengan `ERR_ROLE_TEAM_INTERNAL_BLOCKED` dan token tidak tersimpan.
- **Bug yang teramati:** log Android ketika aplikasi berpindah ke halaman email mencatat `Unhandled Exception: Unable to load asset: assets/images/superapp/bg_auth.svg`. Aset yang tersedia berada pada `assets/images/superapp/auth/bg_auth.svg`. Ini kandidat langsung penyebab visual background/login flicker atau blank sesaat.

### Perbaikan implementasi Auth — 26 Okt 2026

- `ERR_ROLE_TEAM_INTERNAL_BLOCKED` sekarang dipertahankan untuk dua bentuk respons BE: HTTP `403` dan respons HTTP `200` dengan `meta.status=failed`.
- Model `MetaResponse.code` diperbaiki dari `int?` menjadi `Object?`, karena backend memakai string error code untuk domain error. Sebelumnya respons meta gagal dengan kode string dapat crash saat parsing sebelum UI menerima error.
- Modal Team Internal sekarang **Akses Tidak Diizinkan** dengan copy dan aksi Kembali sesuai task. Jalur role lain tetap menggunakan modal Customer Support.

## KMC-02693 — PIN akun

### Flow yang ditargetkan

1. Pengaturan → PIN → Ubah PIN membuka modal stack, bukan redirect penuh.
2. PIN lama salah ke-1 dan ke-2: tampil error serta sisa percobaan, sesi tetap aktif.
3. PIN salah ke-3 berturut-turut: force logout seluruh perangkat + lock 24 jam.
4. Counter salah bersifat shared pada Ganti PIN, Tambah Rekening, dan Tarik Saldo.
5. PIN harus tepat 6 digit angka.

### Skenario device

| Kasus | Ekspektasi | Aktual |
|---|---|---|
| `testsuper6` — PIN yang diberikan | Lanjut ke input PIN baru dan konfirmasi | **Blocked**: respons server menyatakan `PIN salah` dan sisa 2 percobaan. Tidak diuji ulang agar counter shared tidak habis. |
| Salah 1x | Error + sisa 2 percobaan, tetap di modal | Video melaporkan logout — **tidak sesuai task** |
| Salah 2x | Error + sisa 1 percobaan, tetap di modal | Belum diuji |
| Salah 3x | Lock 24 jam dan logout seluruh perangkat | Belum diuji; jangan jalankan tanpa persetujuan eksplisit karena mengubah state akun |

### Catatan Figma

- Link task memilih section **Lupa PIN & Pemulihan**, sedangkan file yang sama menyediakan page khusus `→ PIN` dan `→ Rekening`.
- QA visual Ubah PIN harus menggunakan page `→ PIN`; node Lupa PIN saja tidak cukup sebagai acuan.
- Pemeriksaan Figma 26 Okt: node `1237-15579` memang membuka kanvas **Lupa PIN & Pemulihan via Email OTP dengan Escalating Cooldown**, bukan frame utama Ubah PIN. Jadi tidak valid untuk menyatakan visual Ubah PIN sudah sesuai tanpa memilih frame `→ PIN` yang tepat.

### Kelayakan pembandingan visual

- Direct node Rekening yang tercantum pada task membuka artefak akhir **Rekening Berhasil Ditambahkan / Email Rekening Ditambahkan**, bukan layar daftar rekening atau gatekeeper PIN. Karena itu hasil UI device saat ini hanya bisa diberi status flow pass; approval pixel/UI untuk halaman awal Rekening, dialog PIN, dan form tambah rekening masih membutuhkan frame Figma yang spesifik.
- Ketidaksesuaian visual yang sudah pasti: layar email login mempunyai risiko flash/blank karena aset background salah path (lihat KMC-02497). Ini tidak sesuai desain Auth yang mengharuskan pola logo tetap ter-render.

### Hasil test 26 Okt 2026

- Pada `testsuper6`, satu PIN yang ditolak **tidak** me-logout akun. UI menampilkan `PIN salah. Kamu memiliki 2 percobaan lagi sebelum akun kamu logout secara otomatis`; ini sesuai batas 3x task.
- Karena counter percobaan PIN bersifat shared, akun ini tidak boleh dipakai untuk percobaan PIN salah berikutnya sampai counter dipulihkan oleh PIN benar/reset atau dikonfirmasi aman untuk test.
- `testsuper4`: login normal; setelah melewati modal produk menunggu verifikasi, PIN `555555` berhasil membuka Rekening Bank. Halaman empty state dan gatekeeper `Profil Belum Lengkap Nih` muncul saat `Tambah Rekening` ditekan. **Pass** untuk gatekeeper profil, tidak ada form rekening yang terbuka.
- `testsuper8`: login normal ke Home, tetapi saat navigasi menuju Pengaturan → Informasi Akun → PIN/Ubah PIN, aplikasi kembali ke halaman email **sebelum input PIN**. **Fail/reproduced** untuk laporan auto logout. Log yang tersedia tidak mengungkap respons HTTP pemicunya, tetapi saat redirect terjadi ada exception aset background auth yang hilang; request profile auth `401` masih perlu diambil dari Chucker/network log untuk menentukan sumber logout.
- `testsuper7`: check-email berhasil membuka form password, tetapi setelah submit aplikasi kembali ke halaman email tanpa dialog error yang terlihat. Hasil belum dapat diklasifikasikan sebagai kegagalan PIN atau profil karena belum ada body respons/Chucker dari percobaan ini; perlu capture network sebelum mengulang agar penyebab tidak tertutup redirect.

## Bukti yang wajib dicatat setiap test

- Akun/kondisi uji (tanpa password atau PIN di dokumen versioned).
- Build/flavor dan waktu test.
- Endpoint, HTTP status, dan body error yang telah disensor.
- Screenshot sebelum/sesudah dan rekaman Chucker bila `-1`.
- Perbandingan dengan frame Figma serta hasil: Pass / Fail / Blocked.

## Sinkronisasi laporan QA eksternal — 26 Okt 2026

Sumber: tiga spreadsheet Bug Report yang dibagikan tester. Status `x` di bawah adalah status dari tracker tester, bukan klaim verifikasi ulang di device ini. Temuan yang sudah diuji ulang diberi catatan tersendiri.

### KMC-02497 — Auth Team Internal

| ID | Laporan | Severity / priority | Status tracker | Korelasi QA ini |
|---|---|---|---|---|
| AUTH-01 | Login menggunakan role Talent/Team Internal tidak menampilkan popup error. | High / Major | Implemented — automated tested | Error `ERR_ROLE_TEAM_INTERNAL_BLOCKED` sekarang dipertahankan dari HTTP `403` maupun meta gagal HTTP `200`, tidak menyimpan token, dan memicu modal **Akses Tidak Diizinkan** dengan copy task. Role lain tetap memakai modal Customer Support. E2E masih menunggu akun role Team Internal. |

### KMC-02691 — Rekening Bank

| ID | Laporan | Severity / priority | Status tracker | Korelasi QA ini |
|---|---|---|---|---|
| BANK-01 | Empty state tidak sesuai Figma. | Medium / Medium | `x` | Belum pixel-verified; direct node task tidak membuka frame empty state. |
| BANK-02 | Popup rekening berhasil ditambahkan tidak sesuai Figma. | Medium / Medium | Implemented — widget regression passed | Sheet sukses telah diselaraskan dengan struktur Figma: radius/padding sheet, close button bulat, judul/deskripsi terpusat, ilustrasi, dan CTA `Oke`; tinggi tidak lagi dipaksa 75% layar. Widget flow regresi pass. Pixel-check device tetap menunggu jalur add rekening disposable karena `testsuper2` sudah mencapai batas 6 rekening. |
| BANK-03 | Popup belum memiliki PIN tidak sesuai Figma. | Medium / Medium | fixed | Tester menyatakan ini satu-satunya bug baru yang sudah fixed. |
| BANK-04 | Popup lengkapi akun tidak sesuai Figma. | Medium / Medium | `x` | Flow muncul pada `testsuper4`/`testsuper6`; belum pixel-verified. |
| BANK-05 | Popup rekening sudah terdaftar di akun lain: field alasan, copywriting, warna/teks tombol tidak sesuai Figma. | Medium / Medium | Implemented — widget regression passed | Struktur sheet diselaraskan: radius/padding, heading dan close affordance, tabel tanggungan berdivider, input alasan surface putih berborder, serta CTA tetap mempertahankan validasi minimal 10 karakter. Copy/CTA bisnis tidak diubah tanpa kontrak endpoint pengajuan. Pixel-check device menunggu respons tanggungan dari akun disposable. |
| BANK-06 | Validasi field alasan pengajuan tidak muncul ketika isi kurang dari 10 karakter. | Medium / Medium | Implemented — widget tested | Input non-kosong di bawah 10 karakter kini menampilkan `Alasan minimal 10 karakter`; CTA pengajuan tetap nonaktif. Test widget pass. Perlu visual QA terhadap frame Figma sebelum ditutup. |
| BANK-07 | Popup alasan pengajuan tidak sesuai Figma. | Medium / Medium | `x` | Belum diuji. |
| BANK-08 | Setelah tambah rekening pertama tidak tampil; ketika tambah lagi, data lama dan baru muncul/dobel. | High / Major | Client mitigation implemented — pending device/BE verification | Setelah save sukses, aplikasi melakukan refresh daftar hingga empat kali dengan jeda bertahap. Selama rekening baru belum muncul, CTA berubah menjadi `Muat Ulang Daftar`, sehingga user tidak dapat menambah rekening kedua dari state daftar yang belum sinkron. Test widget regresi flow rekening pass. Tetap perlu capture add/list API pada akun disposable untuk membuktikan apakah sumber utama berada di konsistensi BE. |

### KMC-02693 — PIN

| ID | Laporan | Severity / priority | Status tracker | Korelasi QA ini |
|---|---|---|---|---|
| PIN-01 | Popup belum memiliki PIN tidak sesuai Figma. | Medium / Low | fixed | Sesuai laporan tester: fixed. |
| PIN-02 | Saat membuka Ubah PIN lalu PIN pertama salah, aplikasi logout tanpa error. | High / Critical | Fixed — device verified | **Diverifikasi ulang build dev 26 Okt:** akun yang status PIN-nya sudah lock kini menampilkan modal `Terlalu Banyak Percobaan PIN` dan penjelasan 24 jam terlebih dahulu. Logout ke email baru terjadi setelah tombol `Masuk Kembali` ditekan. |

**Akar dan perbaikan PIN-02:** saat backend melaporkan percobaan PIN habis, UI memanggil `AuthLogoutRequested` sebelum bottom sheet lock dirender. GoRouter lalu langsung mengarahkan ke email sehingga modal tidak pernah terlihat. Perbaikan menunggu acknowledgement pada modal lock, kemudian baru membersihkan sesi. Jalur lock dari Rekening Bank memakai urutan yang sama.

### Prioritas tindakan

1. **BANK-08 / High-Major:** client-side guard sudah ada; capture response add-bank pertama dan refresh/list berikutnya untuk menentukan apakah duplikasi juga terjadi pada persistence BE. Jangan lakukan ulang pada akun produktif tanpa data disposable.
2. **PIN-02 / High-Critical:** **fixed & device verified.** Modal lock sekarang muncul sebelum logout; tetap regression-test batas salah PIN ke-3 pada akun disposable sebelum rilis.
3. **AUTH-01 / High-Major:** mapping/modal FE sudah diimplementasikan dan diuji; lakukan E2E memakai akun role Team Internal untuk membuktikan respons `403`, tidak ada token tersimpan, dan tidak ada redirect ke Home.
4. **Mismatch Figma BANK-01, 02, 04–07:** buka frame Figma spesifik per state, lalu lakukan visual regression sebelum ditutup sebagai fixed.

## Risiko test

- Percobaan PIN salah ke-3 dapat mengunci akun 24 jam serta logout semua device. Jangan dipakai untuk exploratory test sebelum ada konfirmasi.
- Perubahan PIN, tambah/hapus rekening, dan verifikasi OTP mengubah data; dipisahkan dari validasi navigasi/read-only.
