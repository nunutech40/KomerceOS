# QA Board Revisi — Komerce OS

Dokumen kerja QA untuk tiga task pada board **Revisi**. Catatan ini memisahkan requirement task, referensi Figma, skenario uji, dan hasil aktual agar isu tidak tercampur.

## Tindak lanjut feedback SQA — 30 Oktober 2026, 15.01–15.06 WIB

Dua video WhatsApp SQA diperiksa: video 6 detik menunjukkan popup tanggungan hingga `Alasan Berhasil Diajukan`; video 10 detik menunjukkan verifikasi OTP hingga `Rekening Berhasil Ditambahkan`. Foto/pesan SQA juga menandai popup PIN salah tiga kali dan meminta keputusan soal logout.

- Tombol `Selesaikan Tanggungan` dihapus. `Kirim Alasan & Ajukan` menjadi satu-satunya CTA utama, aktif setelah alasan minimal 10 karakter.
- Popup sukses rekening dan alasan memakai `BankResultSheet` yang disiapkan mengikuti frame Figma. Ilustrasi hijau Komtim diganti dengan ilustrasi sukses oranye Komerce. Keduanya sudah ditampilkan dan diperiksa secara visual di HP melalui integration test sintetis pada 30 Oktober; pembandingan pixel dengan Figma dan alur API nyata belum selesai.
- Popup lock PIN di jalur Ubah PIN dan Rekening Bank memakai ilustrasi batas percobaan yang sama. **Keputusan SQA terbaru pukul 16.44:** kesalahan PIN ketiga langsung logout. Setelah login ulang, status PIN tetap terkunci; saat pengguna masuk ke verifikasi PIN, popup batas 24 jam muncul dengan pilihan `Reset PIN` atau kembali. Login ulang tidak mereset batas server.
- **Keputusan produk:** pengajuan alasan adalah alur UI saja. Tombol memvalidasi alasan lalu menampilkan popup sukses; tidak ada request, OTP, atau penyimpanan rekening. Endpoint pengajuan bukan pekerjaan tertunda untuk feedback ini.

## Status terbaru — feedback SQA dibaca 30 Oktober 2026

Sumber: chat WhatsApp SQA yang dibuka pemilik, pesan **27 Oktober 2026 pukul 10.06–15.31 WIB**, dibaca sampai pesan terakhir. Tiga video ditinjau melalui WhatsApp: akun `testsuper8` (23 detik, 10.10), perilaku email dev (10 detik, 11.01), dan pembanding production (8 detik, 11.01). Bagian ini mengoreksi status lama di bawah jika bertentangan. Versi/commit APK SQA belum diketahui.

### Regresi langsung di HP — 30 Oktober 2026, build dev lokal terbaru

- **Pembaruan 09.36–09.43 WIB:** BE mengonfirmasi respons role internal memakai bentuk flat `{status: false, error_code: "ERR_ROLE_TEAM_INTERNAL_BLOCKED", message: "Akun Anda tidak memiliki akses untuk masuk ke aplikasi.", data: null}`. Parser sebelumnya hanya mengenali `meta.code`, sehingga hasil `data: null` terbaca sebagai email kosong. Parser HTTP 200 dan handler error HTTP diperbaiki untuk mempertahankan `error_code`. Pada APK dev baru, akun Talent Internal langsung menampilkan popup **Akses Tidak Diizinkan** setelah email dicek otomatis. Uji parser, repository, dan pemilihan popup: 24 lulus. **AUTH-01 PASS pada perangkat.**
- **Pembaruan rekening 09.39–09.43 WIB:** `testsuper5` login, memasukkan PIN, membuka form, memilih **Bank Rakyat Indonesia (BRI)** lalu menekan **Terapkan**. Nomor BRI dari bukti SQA yang sudah diizinkan dimasukkan dan **Cek Nama Pemilik Bank** dijalankan. UI membalas **× Tidak Ditemukan**; tombol Konfirmasi tetap nonaktif. Tahap cek duplikasi, popup tanggungan, dan OTP belum tercapai. Ini terhalang hasil verifikasi pemilik untuk nomor tersebut, bukan oleh OTP. Tidak ada rekening tersimpan.
- Build lokal dari source terbaru berhasil dipasang setelah menghapus APK yang ditandatangani dengan key berbeda; data aplikasi sebelumnya dihapus sesuai instruksi pemilik. Perangkat Infinix HOT 60i, paket `id.android.komerceos.dev`, versi 1.1.1 (code 1). Seluruh langkah di bawah berlangsung pada APK ini.
- **AUTH-05 email otomatis — PASS.** Untuk akun valid, berhenti mengetik saja menjalankan check-email dan membuka halaman password; tidak perlu menekan `Lanjutkan`. Log menunjukkan aksi `CHECK_EMAIL`.
- **AUTH-04 tesSuper8 — PASS dengan batasan data akun.** Login berhasil dan alur Pengaturan → Informasi Akun → PIN → Ubah PIN dibuka tanpa redirect/logout sebelum input PIN. Akun ini sebelumnya tercatat `attempt_left: 0`; tidak memasukkan PIN atau menguji lock lagi.
- **BANK-09 `-1` saat buka profil — tidak terulang.** Setelah login online, halaman Informasi Akun/Profile memuat data dan tetap login. Log tidak menunjukkan `client_transport_error` atau HTTP `-1` pada alur itu. Ini mengonfirmasi skenario online yang dilaporkan, bukan akar error lama.
- **AUTH-01 Talent Internal — PASS setelah perbaikan 09.36 WIB.** Percobaan awal di APK sebelumnya tetap di halaman Email. Setelah bentuk respons flat dari BE diketahui dan parser diperbaiki, APK baru menampilkan popup `Akses Tidak Diizinkan` pada akun yang sama tanpa menekan `Lanjutkan`.
- **Flow rekening testsuper5 — SEBAGIAN DICEK.** Login dan PIN membuka halaman Rekening Bank kosong; `Tambah Rekening` membuka form (jadi profil akun ini memenuhi syarat). Daftar bank berhasil dimuat; Chucker menunjukkan `GET .../disbursementbankAvailable` HTTP 200. BRI berhasil dipilih dan dicek memakai nomor yang diizinkan pemilik, tetapi nama pemilik **Tidak Ditemukan**. Cek duplikasi tidak dapat dilanjutkan karena Konfirmasi nonaktif; tidak ada rekening yang disimpan, OTP tidak disentuh. Popup tanggungan/sukses sudah tampil di HP lewat data sintetis, tetapi belum lewat respons API nyata.
- **Flicker login — belum diuji tuntas di rekaman build ini.**
- Kredensial tidak dicatat di bagian ini. Password dan PIN tidak ditulis ke dokumentasi versioned.

### Percobaan regresi perangkat — 30 Oktober 2026, 08.19–08.23 WIB

- ADB mendeteksi Infinix HOT 60i (`1468240586001999`). APK lokal dev berhasil dibangun dari source saat ini, tetapi tidak bisa dipasang sebagai update: sertifikat APK terpasang SHA-256 `4fcd3047…36116a10`, sedangkan APK lokal `47be3c49…2c3f3e9e`. Android menolak update karena signing key berbeda.
- Paket lama dilepas dengan opsi mempertahankan data; APK asal dipasang kembali dan berhasil dibuka. Tidak ada perintah penghapusan data aplikasi. Versi yang tersedia untuk observasi tetap `1.1.1`, asal pemasangan 26 Oktober.
- Pada APK lama, email valid `testsuper2@yopmail.com` diketik dan ditunggu 2 detik. Layar tetap di form Email dengan tombol `Lanjutkan` aktif; jadi APK yang terpasang masih memerlukan tap. Ini **bukan verifikasi perubahan source 30 Oktober**, karena build tersebut tidak berhasil dipasang.
- AUTH-01, AUTH-04, BANK-02, BANK-05, BANK-07, BANK-09, dan flicker login belum dapat dinilai terhadap source terbaru pada perangkat. Agar hasil valid, perlu APK dev yang ditandatangani dengan key yang sama seperti APK CI/HP, atau persetujuan untuk melepas data paket dan memasang build lokal (login serta state lokal dapat hilang).

| ID | Feedback terbaru | Status dan tindak lanjut |
|---|---|---|
| AUTH-01 | Popup untuk role Talent Internal masih belum muncul (10.06 dan 10.55). | **PASS di HP 30 Okt 09.36 WIB.** Respons BE flat `error_code=ERR_ROLE_TEAM_INTERNAL_BLOCKED` kini dikenali; popup `Akses Tidak Diizinkan` tampil otomatis setelah check-email, tanpa sesi login. |
| AUTH-04 | `testsuper8` masih logout saat membuka Ubah PIN, sebelum mengisi PIN (10.10, ditegaskan 10.54). | **Tidak terulang pada build terbaru, dengan batasan:** testsuper8 login dan membuka Ubah PIN tanpa redirect sebelum input. Akun sebelumnya sudah `attempt_left: 0`; tidak menguji PIN. Belum menangkap ulang request lama. |
| BANK-09 | Pemilik mengenali munculnya `-1` lagi dalam konteks video akun tersebut (10.12). | **Tidak terulang pada skenario online Profil di build terbaru.** Profile memuat data dan tetap login; log tidak menunjukkan transport `-1`. Akar kejadian historis belum diketahui. |
| BANK-02 | Tampilan popup berhasil menambahkan rekening masih belum sesuai Figma (10.54). | **Tampilan diperiksa di HP dengan data sintetis.** Jalur add nyata belum mencapai popup sukses; testsuper2 sudah memiliki enam rekening dan OTP tidak disentuh. Pixel comparison Figma belum tuntas. |
| BANK-05 | Warna field dan teks tombol pada alur rekening masih tidak sesuai (10.54). | **Tampilan popup tanggungan diperiksa di HP dengan data sintetis.** Pada testsuper5, nomor BRI uji menghasilkan `Tidak Ditemukan`, sehingga cek duplikasi/respons tanggungan nyata belum terjangkau. |
| BANK-07 | SQA mengharapkan popup sukses setelah pengajuan alasan (10.54). | **UI-only disetujui; tampilan dan transisi diperiksa di HP.** Popup `Alasan Berhasil Diajukan` tidak melakukan request pengajuan, OTP, atau menyimpan rekening. |
| AUTH-05 | SQA menanyakan pengecekan email yang tidak otomatis lagi dibanding production (11.01). | **PASS di device build terbaru.** Email valid memicu request setelah debounce 500ms; halaman Password terbuka tanpa tap `Lanjutkan`; log `CHECK_EMAIL`. |

**Yang dinyatakan aman oleh SQA:** pada 10.07/10.09 beberapa skenario fungsi/tampilan sudah aman; pada 14.18–14.20 SQA menyatakan flow yang memakai OTP/add rekening aman dan OTP tetap diterima. Ini memperbarui status “OTP belum diuji” menjadi **sudah diuji SQA**, sedangkan pengujian langsung oleh agen sebelumnya memang berhenti di OTP. Chat tidak menyertakan capture add/list atau response `check-wa` terbaru, sehingga tidak membuktikan tersendiri bahwa HTTP 500 historis atau konsistensi BANK-08 telah dianalisis.

Pada 10.48 SQA menyatakan spreadsheet bug Rekening Bank dan PIN telah diperbarui. Isi terbaru spreadsheet belum dibaca ulang dalam peninjauan chat ini. Pesan terakhir yang tersedia adalah permintaan update bug fix pada **27 Oktober pukul 15.31 WIB**.

### Perbaikan pertama — popup role internal, 30 Oktober 2026

- Pemeriksaan source menemukan handler login menggunakan `contains('lock')` sebelum memeriksa role internal. Teks `ERR_ROLE_TEAM_INTERNAL_BLOCKED` juga memenuhi kondisi tersebut, sehingga respons dengan kode itu dapat masuk popup gagal login/lock. Ini temuan jalur kode; respons aktual akun SQA belum diambil ulang.
- Handler popup role internal/peran lain sekarang berjalan lebih dahulu. Deteksi lock memakai field `lock:` numerik atau pesan akun terkunci yang eksplisit, sehingga `BLOCKED` tidak lagi dianggap field lock.
- Pesan yang eksplisit menyebut Team Internal/Talent Internal dipetakan ke popup `Akses Tidak Diizinkan`, dan dikecualikan dari popup generik `Akun Terdaftar di Peran Lain`.
- Repository mempertahankan `ERR_ROLE_TEAM_INTERNAL_BLOCKED` meskipun `meta.message` kosong, dengan pesan akses sebagai fallback.
- **Status: implementasi saja.** Sesuai instruksi pemilik, tidak menjalankan test, build, request API, atau mengakses Android. Pengujian berikutnya menunggu pemilik mengganti model ke Luna; skenario: akun internal pada halaman email dan/atau password mendapat popup akses, tanpa modal gagal password/lock dan tanpa masuk Home.

### Perbaikan lanjutan — popup rekening dan error transport, 30 Oktober 2026

- **BANK-02/07:** menambahkan `BankResultSheet` yang dipakai kedua popup. Acuan Figma: frame sukses rekening `1291-19769`, panel `1291-19803`, ilustrasi `1291-19814`; frame sukses alasan `1284-18335`. Panel mengikuti ukuran 615px (dibatasi tinggi layar dan dapat discroll), inset horizontal 8px, radius atas 30px, border putih 1px, padding atas 18px/samping 20px/bawah 40px. Ilustrasi yang sudah ada memakai rasio yang sama dan kini berukuran 223.4×300px; backdrop blur 4/45%, close button 40px, CTA 44px/radius 8px.
- **BANK-07:** atas instruksi eksplisit pemilik, alasan valid memunculkan `Alasan Berhasil Diajukan` dengan copy Figma `Alasan penambahan rekening berhasil dikirim dan sedang ditinjau oleh tim.` Ini alur UI final yang disetujui; tidak meneruskan add rekening/OTP dan tidak memerlukan endpoint pengajuan.
- **BANK-05/06:** field alasan mengikuti varian tanggungan yang terlihat di Figma: putih, radius 6px, border netral, fokus oranye/error merah, tanpa counter/hint tambahan. Tombol `Kirim Alasan & Ajukan` memakai latar oranye dan teks putih; disabled 50%, aktif setelah trim minimal 10 karakter. Label wajib dan warna error ditetapkan eksplisit. Token dan komponen `DsButton` tetap dipakai; opsi ukuran, radius, typography, dan elevation ditambahkan dengan default lama dipertahankan.
- **BANK-09 — mitigasi, bukan klaim akar sudah ditemukan:** `DioClient.get` mengulang maksimal sekali setelah 300ms hanya untuk GET allowlist profil, status/sisa PIN, daftar rekening/bank, dan saldo yang gagal transport tanpa HTTP response. Tidak mengulang error bisnis/401/403, request batal, logout, kirim OTP, verifikasi PIN, atau penyimpanan rekening. Retry dihentikan jika token sesi berubah/hilang. Request saldo bersamaan untuk partner yang sama ditahan dan respons lama diabaikan.
- **Diagnostik BANK-09:** sebelumnya instance Chucker yang sama menyimpan satu waktu request untuk beberapa request bersamaan. Capture sekarang per request. Jika tidak ada response HTTP, salinan log berisi `client_transport_error.type`, tipe cause, dan kode OS socket bila ada; status tetap `-1`. Data ini tidak mengubah respons/exception yang diterima aplikasi dan tidak mencetak token/password. Detail exception lama belum tersedia, sehingga perlu pengujian yang ditunda untuk memastikan apakah retry memulihkan kasus SQA.
- **Status seluruh perubahan ini: belum diuji.** Tidak menjalankan automated test, analyze, build, API, atau Android; hanya membaca source/Figma, mengedit, dan memformat kode. Regression ditunda sampai pemilik mengganti model ke Luna.

### Pemulihan pengecekan email otomatis — 30 Oktober 2026

- Sesuai koreksi pemilik, email yang formatnya valid kembali memicu pengecekan API otomatis setelah pengguna berhenti mengetik 500ms. Tombol tetap bisa dipakai untuk mengirim segera/mencoba ulang, tanpa kewajiban klik untuk pemeriksaan pertama.
- Setiap perubahan teks membatalkan debounce dan mereset versi request BLoC, sehingga hasil email lama tidak mengubah UI atau memicu navigasi/popup. Perubahan posisi kursor/seleksi saja tidak memicu request baru. Pending email mencegah tombol dan debounce mengirim duplikat.
- Timer dibatalkan ketika page dispose atau hasil valid membuka Password. Callback/listener hanya bekerja ketika halaman Email aktif. Saat kembali dari Password tidak otomatis memantul ke Password lagi; teks perlu diubah atau tombol ditekan.
- Reset hasil sebelum berpindah ke Password tetap ada. Halaman baru menampilkan state awal sampai request miliknya sendiri dikirim, sehingga hasil app-scoped dari sesi sebelumnya tidak berkedip di layar.
- **Status: implementasi selesai, belum diuji/build/API/device** sesuai instruksi pemilik untuk menunda regression sampai model diganti ke Luna.

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
| Data profil belum lengkap + punya PIN | Setelah PIN benar, modal kelengkapan profil; tidak masuk form tambah rekening | **Pass** pada `testsuper4`: modal `Profil Belum Lengkap Nih` muncul dan form tambah rekening tidak terbuka. |

### Temuan awal

- Figma tidak mendefinisikan kelanjutan API untuk pengajuan alasan tanggungan. Field alasan diperlakukan sebagai interaksi UI/validasi saja; tidak ada asumsi bahwa harus mengirim endpoint atau meneruskan penambahan rekening.
- `testsuper6`, build dev `1.1.1` (26 Okt 2026): PIN gatekeeper berhasil membuka halaman Rekening Bank. Menekan `Tambah Rekening` menampilkan modal `Profil Belum Lengkap Nih` / `Lengkapi Profil`; tidak membuka form tambah rekening. Ini sesuai flow gatekeeper kelengkapan profil.
- `testsuper5` (akun yang digunakan pada video error `-1`): login, gatekeeper PIN, dan halaman Rekening Bank empty state berhasil pada build dev `1.1.1`; error `-1` **tidak ter-reproduksi**. Tombol `Tambah Rekening` aktif. Tahap submit tidak diuji agar tidak menciptakan rekening.
- Akun KYC + rekening + tanggungan: PIN valid membuka daftar enam rekening tersimpan. Tombol `Tambah Rekening` nonaktif karena limit enam rekening. Tidak ada error `-1` maupun logout selama pemeriksaan read-only. Skenario operasi yang memicu restriksi tanggungan sengaja belum dijalankan agar tidak mengubah data.
- `testsuper2` (26 Okt 2026, build dev): check-email dan login dibuka manual oleh pemilik akun, lalu alur **Pengaturan → Informasi Akun → Rekening Bank → PIN** berhasil. PIN valid menampilkan enam rekening; Chucker mencatat `GET /api/v1/bank-account` HTTP 200. Membuka **PIN → Ubah PIN** juga tidak mengarahkan sesi ke halaman email. Tidak ada perubahan rekening atau PIN yang dikirim.
- `testsuper2` (26 Okt 2026, build dev): setelah pemeriksaan di atas, aplikasi di-*force-stop* lalu dibuka ulang. Sesi dipulihkan ke **Home** dengan data akun aktif; tidak muncul halaman email, `-1`, atau logout otomatis. Ini memverifikasi penyimpanan/pemulihan token untuk jalur restart aplikasi secara read-only.
- **Regression device terbaru, 26 Okt 2026 — Infinix HOT 60i / Android 15 / package `id.android.komerceos.dev`, `fvm flutter run --flavor dev` dari workspace saat ini:** pada `testsuper2`, PIN benar membuka **Ubah PIN → Masukkan 6 Digit PIN Baru**; tester mundur sebelum mengubah PIN. Dari Informasi Akun, PIN benar juga membuka daftar enam rekening. Tombol `Tambah Rekening` nonaktif sesuai limit. Tidak terjadi redirect ke email atau logout otomatis pada flow yang diamati.
- **Regression device terbaru, 26 Okt 2026 — `testsuper5`:** logout dilakukan manual untuk berpindah ke akun QA. Email langsung beralih ke form password; tidak terlihat frame email ghosting saat transisi yang diamati. Login berhasil ke Home. Flow Rekening Bank → PIN benar menampilkan empty state `Tidak Ada Rekening Bank`; `Tambah Rekening` aktif. Form tambah rekening terbuka, dan selector bank memuat opsi (misalnya Allo Bank Indonesia, Anglomas International Bank, BPD Aceh/Bali). Form ditutup tanpa memilih data, cek nama pemilik, atau submit. Jadi ini **pass sampai form + daftar opsi**, belum membuktikan API cek pemilik atau penyimpanan rekening.
- **Update regression device, 26 Okt 2026 — cek rekening `testsuper5`:** memakai rekening QA yang sebelumnya disetujui pemilik. `POST /api/v1/bank/check-bank-owner` mendapat HTTP 200 dan menampilkan nama pemilik. `POST /api/v1/bank/check` mendapat HTTP 200 dengan `meta.status=success`; pesannya menyatakan kombinasi rekening/bank tidak sama dengan data lama. Saat lanjut verifikasi, `POST /api/v1/check-wa` mendapat HTTP 500, pesan aman dari response: `Undefined array key "content"`. Aplikasi kemudian menawarkan verifikasi SMS dan membuka layar OTP. **OTP sengaja dilewati atas instruksi; rekening tidak selesai ditambahkan, dan tidak ada bukti persistensi/list setelah add.** Laporkan `check-wa` 500 ke BE.
- **Update offline, 26 Okt 2026 — `testsuper5`:** saat konektivitas dimatikan pada halaman rekening, aplikasi menampilkan `Gagal mengambil data`, keterangan koneksi dan tombol `Coba Lagi`; setelah koneksi dipulihkan halaman kembali ke empty state. Ini hanya memverifikasi penanganan offline/retry. Pemicu historis `-1` adalah alur **online: login → Pengaturan → Informasi Profil**.
- Pada sesi build terbaru tersebut tidak tampak error `-1`, dialog gagal, logout spontan, atau Flutter/Android crash di layar/logcat yang diperiksa. HTTP status lengkap tidak diambil dari Chucker, jadi ini bukan bukti bahwa semua request backend sukses.
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
- **Bukti build lama:** log Android sebelumnya mencatat `Unhandled Exception` untuk `assets/images/superapp/bg_auth.svg`. Source saat ini konsisten memakai path yang tersedia, `assets/images/superapp/auth/bg_auth.svg`. Flicker login tetap perlu diuji di APK dari commit terbaru; jangan lagi memakai exception aset lama sebagai akar pasti tanpa reproduksi baru.

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
| PIN benar (`testsuper7`) | Lanjut ke input PIN baru dan konfirmasi | **Pass:** benar membuka input PIN baru; mundur tanpa menyimpan perubahan. Tidak redirect/logout spontan. |
| Salah 1x (`testsuper5`) | Error + sisa 2 percobaan, tetap di modal | **Pass:** pesan menyebut 2 percobaan tersisa; halaman tetap terbuka. |
| Salah 2x (`testsuper5`) | Error + sisa 1 percobaan, tetap di modal | **Pass:** pesan menyebut 1 percobaan tersisa; halaman tetap terbuka. |
| Salah 3x (`testsuper5`) | Lock 24 jam; modal terlihat sebelum logout | **Pass pada UI:** modal `Terlalu Banyak Percobaan PIN` terlihat; sesi baru keluar setelah CTA `Masuk Kembali` ditekan. Akun kini terkunci 24 jam akibat uji ini. |
| Locked account (`testsuper8`) | Modal lock, aksi kembali ke login hanya setelah CTA | **Pass pada state terkunci:** API memberi `attempt_left: 0`; modal lock muncul dan tidak ada redirect otomatis sebelum CTA. Akun sudah terkunci sebelum pengujian ini, jadi bukan uji ulang penyebab logout historis. |

### Catatan Figma

- Link task memilih section **Lupa PIN & Pemulihan**, sedangkan file yang sama menyediakan page khusus `→ PIN` dan `→ Rekening`.
- QA visual Ubah PIN harus menggunakan page `→ PIN`; node Lupa PIN saja tidak cukup sebagai acuan.
- Pemeriksaan Figma 26 Okt: node `1237-15579` memang membuka kanvas **Lupa PIN & Pemulihan via Email OTP dengan Escalating Cooldown**, bukan frame utama Ubah PIN. Jadi tidak valid untuk menyatakan visual Ubah PIN sudah sesuai tanpa memilih frame `→ PIN` yang tepat.

### Kelayakan pembandingan visual

- Direct node Rekening yang tercantum pada task membuka artefak akhir **Rekening Berhasil Ditambahkan / Email Rekening Ditambahkan**, bukan layar daftar rekening atau gatekeeper PIN. Karena itu hasil UI device saat ini hanya bisa diberi status flow pass; approval pixel/UI untuk halaman awal Rekening, dialog PIN, dan form tambah rekening masih membutuhkan frame Figma yang spesifik.
- Ketidaksesuaian visual yang sudah pasti: layar email login mempunyai risiko flash/blank karena aset background salah path (lihat KMC-02497). Ini tidak sesuai desain Auth yang mengharuskan pola logo tetap ter-render.

### Hasil test 26 Okt 2026

#### Update regression manual terbaru

- **PIN salah bertahap pada `testsuper5`:** percobaan salah pertama dan kedua mempertahankan halaman serta menampilkan sisa percobaan yang benar. Percobaan ketiga menampilkan modal lock 24 jam; logout hanya terjadi setelah tester menekan `Masuk Kembali`. Ini memverifikasi urutan modal → aksi logout. Akun terkunci 24 jam setelah skenario ini.
- **`testsuper7`:** login berhasil pada build dev terbaru. Membuka Pengaturan → Informasi Akun → PIN → Ubah PIN, lalu memasukkan PIN benar, membuka input PIN baru. Tidak ada redirect ke email atau logout spontan pada observasi ini; perubahan dibatalkan sebelum disimpan.
- **Uji ulang khusus logout saat membuka Pengaturan/PIN, 26 Okt 2026 pukul 18.07 WIB — `testsuper7`:** mulai dari Pengaturan, buka Informasi Akun lalu PIN. Aplikasi tetap berada di halaman PIN; tidak kembali ke login dan sesi tetap aktif. Chucker menampilkan `GET /api/v1/pin/check` HTTP 200. Ini pass untuk reproduksi jalur tersebut pada akun unlocked/build dev yang diuji; tidak membuktikan penyebab laporan lama, tetapi laporan tidak terulang pada uji ulang ini.
- **Uji silang akun unlocked, 26 Okt 2026 pukul 18.28 WIB — `testsuper4`:** login berhasil, lalu buka Pengaturan → Informasi Akun → PIN. Halaman PIN terbuka dan sesi tetap aktif; tidak ada redirect ke email/logout. Ini uji silang akun kedua khusus untuk laporan navigasi tersebut. Bersama `testsuper7` dan pemeriksaan read-only `testsuper2` sebelumnya, bug tidak terulang pada tiga akun normal/unlocked yang dicoba.
- **`testsuper8`:** saat dibuka, akun sudah dalam status lock (`attempt_left: 0`). API PIN merespons HTTP 200 dan UI menampilkan modal lock; halaman login baru muncul setelah `Masuk Kembali`. Karena akun sudah terkunci, bug redirect lama saat navigasi belum berhasil direproduksi pada kondisi akun fresh.
- **Tambah rekening `testsuper5`:** cek pemilik rekening HTTP 200; cek rekening HTTP 200 dengan `meta.status=success`; request cek WhatsApp HTTP 500 (`Undefined array key "content"`). UI menyediakan SMS OTP dan mencapai layar input OTP. OTP dilewati sesuai instruksi; tidak ada penyimpanan rekening yang dikonfirmasi. Isu `check-wa` memerlukan perbaikan BE atau kontrak fallback yang jelas.
- **Offline rekening `testsuper5`:** offline state menampilkan pesan gagal muat dan tombol coba lagi; pulih setelah koneksi dinyalakan. Ini skenario terpisah dari `-1` Informasi Profil yang muncul online.
- **Auth/flicker:** email → password → Home tampak normal dalam pengamatan singkat pada `testsuper5` dan `testsuper7`. Ini belum pengukuran visual/video yang cukup untuk menutup bug flicker. Tidak tersedia akun role Team Internal, sehingga pembatasan role belum diuji end-to-end.
- **Figma visual:** belum dilakukan pembandingan pixel-by-pixel di perangkat untuk semua state; frame node pada task tidak selalu menunjuk ke layar awal flow. Status visual tetap perlu dirujuk ke frame spesifik yang benar.

#### Bukti tambahan — regression login, Figma, dan offline 26 Okt 2026

- **Login flicker, build dev terbaru pada Infinix HOT 60i:** rekaman memperlihatkan Home stabil → halaman email → halaman password → submit. Transisi email/password yang terlihat tidak menunjukkan blank/ghosting. Login berhasil; sesudahnya muncul modal produk menunggu verifikasi, lalu Home setelah `Lewati`. Tidak tampak flicker pada bagian yang terekam, tetapi rekaman tidak cukup rapat untuk menutup kemungkinan flash satu-dua frame. Status: **tidak terulang pada observasi ini; belum ditutup sepenuhnya**.
- **Uji ulang login setelah logout, 26 Okt 2026, Infinix HOT 60i / dev:** screen recording perangkat 720×1600 rata-rata sekitar 57 fps tidak menunjukkan frame kosong/ghosting. Namun setelah logout normal, halaman Email menampilkan `Email berhasil ditemukan` dan tombol `Memuat halaman login...` sementara input email kosong; state itu tetap terlihat setelah menunggu sekitar 7 detik dan baru bersih setelah kolom email diubah. Pemeriksaan kode mengonfirmasi `CheckEmailBloc` disediakan pada lingkup aplikasi dan state hasil belum direset saat menavigasi ke halaman password.
- **Perbaikan dan uji ulang:** state `CheckEmailBloc` sekarang direset saat hasil email valid akan membuka halaman password. Build dev berhasil dibuat/dipasang ke HP. Setelah pemasangan, halaman Email tampil bersih; transisi email valid → password stabil; kembali dari password ke Email tidak lagi menampilkan label sukses/loading lama. Tidak terlihat frame kosong/ghosting pada rekaman transisi build ini. Status AUTH-02: **fixed dan lolos uji transisi yang direproduksi**.
- **Perbandingan Figma Rekening:** frame `→ Rekening` → `[Empty State] Rekening Bank` (414×896) dibandingkan dengan empty state di perangkat. Header, ilustrasi, judul/deskripsi, dan CTA terlihat searah dengan rancangan. Ini pemeriksaan visual kualitatif untuk **empty state saja**, bukan pixel-by-pixel atau semua popup/form.
- **Perbandingan Figma PIN:** page `→ PIN`, frame `PIN` (414×896) diperiksa. Struktur halaman PIN yang tampil di device sejalan secara umum. Modal Ubah PIN dan state lain belum dicocokkan satu per satu.
- **Error `-1` pada Informasi Profil:** pemicu laporan awal adalah alur online **login → Pengaturan → Informasi Profil**. Pada regression build dev terbaru, alur itu sudah dibuka dan error `-1` tidak muncul lagi. Status: **resolved pada build yang diuji / tidak terulang**. Uji offline rekening dicatat terpisah dan bukan bukti untuk bug ini.

- Pada test terdahulu `testsuper6`, satu PIN yang ditolak **tidak** me-logout akun. UI menampilkan `PIN salah. Kamu memiliki 2 percobaan lagi sebelum akun kamu logout secara otomatis`; pengujian terbaru dengan `testsuper5` juga memverifikasi sisa percobaan 2 → 1 → lock.
- Counter percobaan PIN bersifat shared; `testsuper5` kini terkunci 24 jam setelah uji salah PIN ketiga. Jangan gunakan untuk tes PIN lagi sampai masa lock berakhir.
- `testsuper4`: login normal; setelah melewati modal produk menunggu verifikasi, PIN `555555` berhasil membuka Rekening Bank. Halaman empty state dan gatekeeper `Profil Belum Lengkap Nih` muncul saat `Tambah Rekening` ditekan. **Pass** untuk gatekeeper profil, tidak ada form rekening yang terbuka.
- `testsuper8` dan `testsuper7`: catatan historis di chat/video menyebut redirect/logout. Pada regression terbaru, `testsuper7` login dan masuk ke Ubah PIN tanpa redirect; `testsuper8` sudah terkunci sebelum navigasi dan modal lock bekerja sesuai CTA. Temuan historis tetap belum dapat dinyatakan fixed untuk akun fresh tanpa reproduksi dan capture request terbaru.

## Bukti yang wajib dicatat setiap test

- Akun/kondisi uji (tanpa password atau PIN di dokumen versioned).
- Build/flavor dan waktu test.
- Endpoint, HTTP status, dan body error yang telah disensor.
- Screenshot sebelum/sesudah dan rekaman Chucker bila `-1`.
- Perbandingan dengan frame Figma serta hasil: Pass / Fail / Blocked.

## Audit gap QA — setelah regression 26 Okt

Yang belum dapat ditutup bukan lagi daftar bug yang tidak tercatat, melainkan bukti berikut:

1. **AUTH-01:** satu akun role Team Internal untuk membuktikan respons `403`/`ERR_ROLE_TEAM_INTERNAL_BLOCKED`, modal yang tepat, dan tidak ada token tersimpan.
2. **PIN-02:** salah PIN 1/2/3 sudah diuji pada `testsuper5`; modal lock muncul sebelum logout. Akun kini lock 24 jam. Skenario ini teruji, tetapi akun tidak dapat dipakai ulang selama lock.
3. **BANK-08:** flow add belum mencapai penyimpanan karena tahap verifikasi SMS OTP sengaja dilewati. Selain OTP, `POST /api/v1/check-wa` mendapat HTTP 500. Setelah kontrak/perbaikan BE dan OTP QA tersedia, uji add → refresh list pada akun disposable.
4. **BANK-05 tanggungan:** popup sudah diuji melalui widget/varian, tetapi belum diuji terhadap respons backend nyata yang memicunya. Sesuai keputusan produk, `note` hanya input UI, tidak memicu OTP, dan tidak menambah rekening; tidak ada pekerjaan endpoint pengajuan.
5. **Visual Figma:** empty state Rekening dan halaman PIN sudah dicocokkan secara kualitatif. Popup/form rekening dan seluruh state PIN/Auth belum dibandingkan satu per satu secara pixel-by-pixel.
6. **AUTH-02 flicker/state email:** state `CheckEmailFound` stale sudah direproduksi, reset sebelum membuka halaman password, lalu diuji di device pada build dev. Halaman email bersih dan transisi email/password/back tidak menunjukkan flicker. Belum ada pengujian ulang logout penuh pada APK staging/release.
7. **AUTH-03/04 redirect historis:** logout/redirect historis tidak terulang pada akun unlocked yang diuji, tetapi capture Chucker saat kejadian lama tidak tersedia untuk memastikan penyebab. `testsuper8` sudah terkunci sebelum bisa diuji dalam kondisi fresh.

## Sinkronisasi laporan QA eksternal — 26 Okt 2026

Sumber: tiga spreadsheet Bug Report yang dibagikan tester. Status `x` di bawah adalah status dari tracker tester, bukan klaim verifikasi ulang di device ini. Temuan yang sudah diuji ulang diberi catatan tersendiri.

### KMC-02497 — Auth Team Internal

| ID | Laporan | Severity / priority | Status tracker | Korelasi QA ini |
|---|---|---|---|---|
| AUTH-01 | Login menggunakan role Talent/Team Internal tidak menampilkan popup error. | High / Major | Fixed — device verified | Error `ERR_ROLE_TEAM_INTERNAL_BLOCKED` dipertahankan dari respons flat maupun meta, tidak menyimpan token, dan memicu modal **Akses Tidak Diizinkan**. Akun Talent Internal sudah menampilkan popup di HP pada 30 Okt. |

### KMC-02691 — Rekening Bank

| ID | Laporan | Severity / priority | Status tracker | Korelasi QA ini |
|---|---|---|---|---|
| BANK-01 | Empty state tidak sesuai Figma. | Medium / Medium | Implemented — visual device checked qualitatively | Frame Figma `[Empty State] Rekening Bank` dibandingkan dengan build dev di HP; ilustrasi, header, copy, dan CTA terlihat searah. Pixel-by-pixel belum dilakukan. |
| BANK-02 | Popup rekening berhasil ditambahkan tidak sesuai Figma. | Medium / Medium | Implemented — visual device checked with synthetic data | Sheet sukses telah diselaraskan dengan struktur Figma: radius/padding sheet, close button bulat, judul/deskripsi terpusat, ilustrasi oranye, dan CTA `Oke`. Ditampilkan pada HP lewat integration test 30 Okt; jalur add rekening nyata belum diuji karena memerlukan OTP. |
| BANK-03 | Popup belum memiliki PIN tidak sesuai Figma. | Medium / Medium | fixed | Tester menyatakan ini satu-satunya bug baru yang sudah fixed. |
| BANK-04 | Popup lengkapi akun tidak sesuai Figma. | Medium / Medium | Implemented — flow device checked; pixel QA pending | Sheet disesuaikan dengan frame `Kondisi Profil Belum Lengkap`; gatekeeper profil muncul pada `testsuper4`. Copy dan flow teruji, tetapi pembandingan pixel-by-pixel di perangkat belum selesai. |
| BANK-05 | Popup rekening sudah terdaftar di akun lain: field alasan, copywriting, warna/teks tombol tidak sesuai Figma. | Medium / Medium | Implemented — visual device checked with synthetic data | Sheet, tabel, dan field alasan ditampilkan pada HP 30 Okt. Tombol `Selesaikan Tanggungan` dihapus; `Kirim Alasan & Ajukan` aktif setelah alasan valid. Respons tanggungan nyata belum diuji; pengajuan alasan memang hanya UI. |
| BANK-06 | Validasi field alasan pengajuan tidak muncul ketika isi kurang dari 10 karakter. | Medium / Medium | Implemented — widget tested; visual QA pending | Input non-kosong di bawah 10 karakter menampilkan `Alasan minimal 10 karakter`; CTA tetap nonaktif. Test widget pass; popup belum diuji visualnya terhadap frame Figma di device. |
| BANK-07 | Popup alasan pengajuan tidak sesuai Figma. | Medium / Medium | UI-only — visual device checked | Sesuai keputusan produk, setelah `Kirim Alasan & Ajukan` tampil popup `Alasan Berhasil Diajukan` dengan ilustrasi oranye dan CTA `Oke`. Transisi dan visual diperiksa pada HP 30 Okt dengan data sintetis. Request pengajuan memang tidak diperlukan. |
| BANK-08 | Setelah tambah rekening pertama tidak tampil; ketika tambah lagi, data lama dan baru muncul/dobel. | High / Major | Client mitigation implemented — pending device/BE verification | Setelah save sukses, aplikasi melakukan refresh daftar hingga empat kali dengan jeda bertahap. Selama rekening baru belum muncul, CTA berubah menjadi `Muat Ulang Daftar`, sehingga user tidak dapat menambah rekening kedua dari state daftar yang belum sinkron. Test widget regresi flow rekening pass. Tetap perlu capture add/list API pada akun disposable untuk membuktikan apakah sumber utama berada di konsistensi BE. |

### KMC-02693 — PIN

| ID | Laporan | Severity / priority | Status tracker | Korelasi QA ini |
|---|---|---|---|---|
| PIN-01 | Popup belum memiliki PIN tidak sesuai Figma. | Medium / Low | fixed | Sesuai laporan tester: fixed. |
| PIN-02 | Saat membuka Ubah PIN lalu PIN pertama salah, aplikasi logout tanpa error. | High / Critical | Fixed in code — latest flow tested with synthetic data | Sesuai keputusan SQA 30 Okt pukul 16.44, kesalahan ketiga langsung logout. Setelah login ulang, status terkunci menampilkan popup batas 24 jam dan opsi Reset PIN. Uji widget dan integration test HP dengan repository palsu lulus; respons server nyata pada build terbaru belum diuji. |

**Akar dan perbaikan PIN-02:** laporan awal mencampur salah PIN pertama dengan status akun yang sudah terkunci. Flow terbaru membedakan respons kesalahan ketiga (logout langsung) dari status terkunci saat verifikasi berikutnya (popup batas 24 jam). Jalur Ubah PIN dan Rekening Bank memakai aturan yang sama.

## Temuan tambahan di luar tiga Bug Report

Lima temuan berikut berasal dari video/device test dan belum memiliki baris pada tiga spreadsheet eksternal. Statusnya **untriaged**, sehingga tidak boleh dihitung sebagai bug selesai atau digabungkan ke item berbeda tanpa bukti baru.

| ID kerja | Temuan | Korelasi tracker | Bukti/status saat ini | Tindakan berikutnya |
|---|---|---|---|---|
| AUTH-02 | Halaman email login tampak flicker/ghosting sebelum stabil. | Tidak ada baris khusus pada Bug Report Auth. | **Fixed dan diuji pada build dev di device:** state lama setelah logout teridentifikasi, direset saat transisi ke password; Email tampil bersih dan transisi ke Password/back stabil. Logout penuh setelah fix dan build staging/release belum diuji ulang. | Smoke test logout penuh pada staging/release. |
| AUTH-03 | `testsuper7` kembali ke halaman email setelah submit password tanpa dialog error. | Tidak ada baris khusus pada Bug Report Auth. | **Belum ter-reproduksi** pada build dev terbaru: login berhasil. | Ulangi bila kejadian muncul; ambil Chucker tepat pada request redirect. |
| AUTH-04 | `testsuper8` kembali ke email saat menuju Pengaturan/PIN, sebelum input PIN. | Berbeda dari PIN-02, yang terjadi setelah PIN salah. | **Tidak terulang pada tiga akun normal/unlocked yang dicoba:** `testsuper7`, `testsuper4`, dan read-only `testsuper2`; `testsuper7` juga menunjukkan `GET /api/v1/pin/check` HTTP 200. `testsuper8` sendiri sudah terkunci (`attempt_left:0`), sehingga laporan lama pada akun itu belum terjelaskan. | Tidak ada reproduksi pada build dev saat ini. Jika terulang, capture Chucker/log saat redirect untuk menetapkan penyebab. |
| BANK-09 | Chucker/video melaporkan status `-1` saat online membuka Informasi Profil setelah login. | Berbeda dari BANK-08, yang membahas daftar rekening tidak langsung sinkron/duplikat setelah tambah. | **Resolved pada build dev yang diuji:** login → Pengaturan → Informasi Profil tidak lagi menampilkan `-1`. Uji offline rekening adalah skenario terpisah. | Pantau regresi; bila muncul lagi, capture request dan detail exception Chucker. |
| BANK-10 | Request pengecekan WhatsApp saat tambah rekening gagal HTTP 500. | Temuan integrasi baru dari regression device. | `POST /api/v1/check-wa`; response `Undefined array key "content"`; SMS OTP tersedia sebagai jalur berikutnya. OTP dilewati dan add tidak selesai. | BE perbaiki kontrak/response check-wa; setelah itu uji ulang dengan OTP QA dan pastikan add/list tersinkron. |

### Prioritas tindakan

1. **BANK-08 / High-Major:** client-side guard sudah ada; capture response add-bank pertama dan refresh/list berikutnya untuk menentukan apakah duplikasi juga terjadi pada persistence BE. Jangan lakukan ulang pada akun produktif tanpa data disposable.
2. **PIN-02 / High-Critical:** flow baru lulus uji sintetis di HP; regression-test salah PIN ke-3 terhadap server pada akun disposable sebelum rilis.
3. **AUTH-01 / High-Major:** popup role internal sudah tampil pada akun Talent Internal di HP; pantau regresi pada build rilis.
4. **Mismatch Figma BANK-01, 02, 04–07:** BANK-02/05/07 sudah diperiksa visualnya di HP dengan data sintetis pada 30 Okt. BANK-07 tetap UI-only tanpa request/OTP. BANK-01/04 dan kecocokan pixel per frame masih perlu regression terpisah.

## Risiko test

- Percobaan PIN salah ke-3 dapat mengunci akun 24 jam serta logout semua device. Uji tersebut sudah dilakukan sekali pada `testsuper5`; jangan ulangi pada akun itu selama lock aktif.
- Perubahan PIN, tambah/hapus rekening, dan verifikasi OTP mengubah data; dipisahkan dari validasi navigasi/read-only.

## Perbaikan kode sebelum regression berikutnya — 26 Okt 2026

Perubahan ini sudah diuji lewat test lokal dan sebagian flow sudah diregresi di device; hasil device terbaru dicatat pada bagian Hasil test di atas. Status berikut membedakan perbaikan yang dapat dibuktikan dari kode/test lokal dengan gap yang masih memerlukan kontrak API, frame Figma, atau reproduksi.

| ID | Perubahan atau status aktual |
|---|---|
| AUTH-01 | Mapping role Team Internal dan modal sudah ada; E2E tetap memerlukan akun role terkait. |
| AUTH-02 | Pengecekan email otomatis saat mengetik dihapus. Halaman password langsung memakai email yang sudah lolos `check-login`, tanpa request kedua atau animasi transisi email 800 ms. Hasil check-email lama diabaikan setelah email berubah. Test action dan state lulus; visual device belum diuji. |
| AUTH-03 | Dua sumber redirect yang mungkin dari FE dipersempit: password tidak memanggil `check-login` ulang, dan `401` profil tanpa token request atau dengan token lama tidak menghapus sesi aktif. Penyebab persis pada `testsuper7` belum terbukti tanpa respons request terbaru. |
| AUTH-04 | Guard `401` profil kini hanya logout bila request memakai token yang sama dengan token sesi yang masih tersimpan. `401` layanan fitur tetap lokal. Penyebab `testsuper8` belum dapat diklaim selesai tanpa log saat redirect. |
| BANK-01 | Tinggi empty state mengikuti ruang layar. Ilustrasi SVG persis dari frame `[Empty State] Rekening Bank` mengganti aset hijau, dan ukuran 243×220 mengikuti desain. Masih perlu screenshot build baru. |
| BANK-02/03/06, PIN-01/02 | Perbaikan sebelumnya tetap ada; test lokal terkait lulus. Tidak ada perubahan baru pada modal ini. |
| BANK-04/05/07 | Modal kelengkapan profil dan tanggungan disesuaikan dengan frame Figma. Keputusan 30 Okt menggantikan catatan 26 Okt: alasan tetap UI-only tanpa submit/OTP, tetapi setelah CTA aplikasi menampilkan popup `Alasan Berhasil Diajukan`. |
| BANK-08 | Guard sinkronisasi sesudah add tetap aktif. Request daftar yang lebih tua kini tidak boleh menimpa hasil refresh baru. Konsistensi add/list BE tetap memerlukan bukti request nyata. |
| BANK-09 | Error `-1` yang sebelumnya muncul online saat membuka Informasi Profil setelah login tidak muncul lagi pada regression build dev terbaru. Uji offline rekening terpisah mengonfirmasi UI retry. |

Verifikasi lokal: `flutter analyze` untuk source yang berubah tidak menemukan issue; 35 test terfokus Auth reCAPTCHA/guard sesi, rekening, dan PIN gate lulus pada 26 Okt. Ini bukan pengganti regression di perangkat.

## Uji visual HP — 30 Okt 2026

Pada Infinix X6728 yang terhubung USB, `integration_test/qa_feedback_visual_test.dart` menjalankan widget asli dalam aplikasi uji dengan data sintetis. Empat skenario lulus: popup rekening berhasil ditambahkan, popup tanggungan lalu popup alasan berhasil diajukan, popup batas PIN saat login ulang, dan kesalahan PIN ketiga memicu logout callback. Screenshot di perangkat memperlihatkan ilustrasi oranye pada dua popup sukses dan CTA `Kirim Alasan & Ajukan` tanpa `Selesaikan Tanggungan`. Popup PIN setelah koreksi flow memakai opsi `Reset PIN`.

Pengujian ini memverifikasi tampilan dan transisi widget di HP. Ini belum membuktikan add rekening nyata, respons tanggungan server, atau batas percobaan PIN server; jalur tersebut tidak dipanggil oleh integration test sintetis. Pengajuan alasan sengaja hanya UI sesuai keputusan produk. Tidak ada OTP atau rekening sungguhan yang digunakan.

### Koreksi flow PIN dari SQA — 30 Okt 2026, 16.44 WIB

SQA menetapkan: salah PIN ketiga langsung logout; setelah itu user dapat login lagi, tetapi verifikasi PIN tetap dibatasi selama 24 jam sejak kesalahan terakhir atau sampai reset lewat Lupa PIN. Implementasi Ubah PIN dan gate rekening sekarang memicu logout langsung pada respons percobaan habis. Saat membuka verifikasi PIN dengan status terkunci yang sudah ada, aplikasi menampilkan popup pembatasan 24 jam dan opsi Reset PIN. Uji widget lokal untuk kedua jalur lulus (23 tes terkait); empat skenario integration test sintetis pada HP juga lulus. Uji API nyata setelah koreksi ini masih perlu dilakukan. Catatan lama di atas yang menyebut logout setelah tombol `Masuk Kembali` berlaku untuk build sebelum koreksi ini.
