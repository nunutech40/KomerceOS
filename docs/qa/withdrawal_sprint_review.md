# Review awal sprint Withdraw Kompay

Sumber:

- Task SDLC: https://sdlc.komerce.id/tasks/view?id=2116 (KMC-03839)
- Figma Sprint 3, halaman Withdraw: https://www.figma.com/design/LkqSMbnuKrsmb34GSfECVO/Sprint-3?node-id=1-61066&p=f&t=k5EfXo3ohMI1V7Nx-0

## Alur yang terlihat di Figma

- Entry point dari tombol Penarikan di kartu saldo Home.
- Prasyarat: KYC, PIN, dan rekening bank. Desain menyediakan alur verifikasi akun, pembuatan PIN, dan penambahan rekening sebelum kembali ke penarikan.
- Form Penarikan Saldo menampilkan saldo Kompay, pilihan nominal Rp12.000/Rp20.000/Rp50.000/Rp100.000/Rp500.000/Rp1.000.000, input nominal manual, informasi biaya, pilihan rekening, dan tombol Ajukan Penarikan.
- Pilihan rekening berupa daftar rekening tersimpan. Nominal di bawah Rp12.000 atau di atas saldo menampilkan error dan menonaktifkan pengajuan.
- Nominal di bawah Rp500.000 menampilkan informasi biaya Rp2.000; Rp500.000 atau lebih gratis.
- Desain menempatkan verifikasi PIN setelah form, lalu layar pengajuan berhasil dan jalur gagal diproses. Untuk branch ini, arahan implementasi terbaru menempatkan verifikasi PIN yang sudah ada sebelum form. Desain juga memuat variasi kesalahan PIN 1/2/3 kali, PIN terblokir, saldo ideal, saldo dalam proses penarikan, dan kondisi gabungan.
- Untuk saldo ideal, popup menjelaskan saldo tertahan, alasan menghindari saldo minus, rincian asal saldo ideal, dan tautan Pelajari lebih lanjut. Untuk antrean penarikan, popup meminta user menunggu sampai proses selesai.

## Kondisi kode pada branch sprint-withdrawal

- Tombol Penarikan di Home ada di `lib/features/superapp/features/home/view/sections/balance_section.dart`. Status KYC memakai `verificationKtpStatus` dan pemetaan `KycKtpStatus` yang sama dengan Pengaturan Akun: status `0` membuka `KycVerificationBottomSheet` (biaya Rp25.000; saldo kurang memakai popup dan Top Up yang sudah ada), status `5`/`3` meneruskan riwayat via `KycResumeFlow` tanpa bayar ulang, status `1` membuka info verifikasi dalam proses, dan hanya status `2` lanjut. Bila status profil belum dimuat, profil dimuat ulang dan penarikan belum diteruskan. Setelah KYC terverifikasi, tombol memeriksa keberadaan PIN melalui `CheckPinSettingUseCase`, sama seperti alur tambah rekening di Pengaturan Akun. Jika PIN belum ada, popup mengarahkan user ke `PinFlowPage` untuk membuatnya. Jika PIN sudah ada, komponen `BankAccountPinSheet` yang sudah dipakai di Pengaturan Rekening memverifikasi PIN melalui API. Sesudah PIN valid, Home mengecek daftar rekening; jika kosong menampilkan popup `WithdrawalNoBankSheet` dan membuka halaman tambah rekening yang sudah ada. Jika rekening tersedia, flow membuka `WithdrawalPage`.
- Jalur pintas pratinjau UI sudah dilepas. Tombol Penarikan kembali menjalankan KYC → PIN → rekening sebelum membuka form. Tombol Ajukan di form tetap membuka layar hasil pratinjau tanpa mengirim transaksi.
- Frame “Metode Pembayaran” pada halaman Figma Withdraw berlabel `Home/Topup`: bagian alur saldo KYC kurang, bukan metode pencairan Withdrawal. Jalurnya sudah terhubung melalui popup `KycInsufficientBalanceBottomSheet` → `CheckBillBloc` → `TopupPage(isFromKyc: true)` → pilihan Transfer Bank/QRIS → konfirmasi → halaman invoice/QRIS. Layout info biaya KYC dan konfirmasi Top Up sudah diperbaiki agar tidak overflow pada lebar 375 px; widget test memeriksa kedua pilihan dan konfirmasinya.
- Form dan prasyarat rekening kini membaca `BankAccountRepository.accounts()` yang memakai endpoint `api/v1/bank-account`, sama dengan Pengaturan dan form Komship. Nominal minimal Rp12.000 divalidasi lokal; nominal Rp12.000 ke atas dicek ke `GET api/v1/partner/withdrawal/check-possible-withdraw` setelah jeda ketik 350 ms dan dibatasi oleh `maximum_withdraw_nominal` dari respons Komship (fallback saldo dikurangi saldo ideal jika field maksimum tidak tersedia). CTA form menunggu nominal valid dan satu rekening dipilih. Pengajuan transaksi tetap belum dihubungkan.
- Form dan BLoC withdrawal lama (`lib/features/kompay/...`) dihapus oleh commit `09b57da` pada 28 Juli 2026. Keduanya hanya tersedia di riwayat Git.
- Endpoint POST `/api/v1/mobile/transaction/withdraw`, use case, serta proses withdrawal di `PinBloc` masih ada. `PinPage` masih merujuk route sukses withdrawal, tetapi route form maupun sukses tidak terdaftar di router aktif.
- Form baru menampilkan saldo, preset nominal, input manual, pesan biaya dan validasi, serta rekening tersimpan dari API. Pemilih rekening di form tetap memakai popup `WithdrawalNoBankSheet` saat daftar kosong dan mengarah ke halaman tambah rekening yang sama. Informasi saldo ideal, penarikan berjalan, dan kondisi gabungan dapat membuka popup sesuai varian Figma. Tombol pengajuan membuka pratinjau layar hasil dengan nominal dan rekening pilihan. View hasil berhasil, gagal diproses, dan riwayat penarikan tersedia sebagai pratinjau; belum ada POST withdrawal, data mutasi nyata, atau status sukses transaksi nyata karena tahap ini hanya view.
- Dokumen `docs/flows/kompay_flow.md` menyebut minimum withdrawal Rp50.000 dan file form lama. Dokumen itu sudah tidak sesuai task (minimum Rp12.000) maupun source aktif.

## Hal yang perlu diselaraskan sebelum implementasi final

- Copy rincian rumus pada popup saldo ideal Figma menempatkan Potensi Pendapatan sebagai suku positif dan ongkir retur sebagai pengurang. Task REQ13 memakai kebalikannya; task secara eksplisit menjadikan rumus REQ13 sebagai acuan.
- Layar Figma berjudul "Penarikan Saldo Berhasil", sedangkan penjelasannya menyebut dana *akan diproses*. Task AC37 meminta status pengajuan dibedakan dari dana cair.
- Komentar Figma pada cabang PIN menyebut tidak langsung logout, sementara task REQ15/AC31 meminta logout seluruh perangkat pada kesalahan ketiga. Perilaku final perlu dikonfirmasi terhadap Komship/backend.
- Implementasi lama membatasi input nominal sampai Rp5.000.000. Task belum menetapkan batas maksimum di luar saldo ideal; batas lama tidak otomatis menjadi aturan sprint ini.
- Task masih mencatat ketidakpastian tentang pengecualian KYC penarikan pertama, hubungan biaya dengan batas penarikan, transaksi bersamaan, dan pemetaan status. Desain visual sendiri tidak menyelesaikan aturan backend tersebut.

## Audit task SDLC KMC-03839 — 17 November 2026

Task `https://sdlc.komerce.id/tasks/view?id=2116` dibaca ulang langsung di SDLC. Status berikut menilai kode aktif pada branch `sprint-withdrawal`, bukan sekadar keberadaan view pratinjau.

| Area task | Status | Temuan |
| --- | --- | --- |
| REQ08 / AC08 entry point | Sudah | Tombol Penarikan pada Financial Summary Card membuka flow. |
| REQ09 / AC24 PIN dan rekening | Sebagian | PIN dan rekening diperiksa, tetapi antrean belum mempunyai sumber status yang terhubung. Popup antrean sudah ada dan copy-nya kini `Masih ada penarikan yang diproses. Silakan tunggu hingga selesai untuk mengajukan penarikan baru.` |
| REQ09 / AC24 antrean | Pratinjau debug saja | Sesudah membuka hasil berhasil pratinjau, percobaan Penarikan berikutnya pada build debug menampilkan popup antrean dengan copy `Masih ada penarikan yang diproses. Silakan tunggu hingga selesai untuk mengajukan penarikan baru.` Status sementara ini tidak mewakili transaksi server. `_pending` pada form belum diisi dari API. Endpoint riwayat `api/kmpoin/mobile/kmPoinWithdrawalRequest` yang digunakan Android Komship mengembalikan HTTP 404 pada host dev yang diperiksa tanpa kredensial. Respons validasi nominal dan saldo ideal yang tersedia tidak menyatakan status antrean. Jangan menyamakan `pending_balance` dengan antrean penarikan. |
| REQ10 / AC26 nominal | Sebagian | Minimal Rp12.000, format ribuan, dan batas `maximum_withdraw_nominal` sudah dipakai. Kegagalan validasi menahan tombol, tetapi sebagian tampilan saldo ideal yang diminta AC20–AC22 belum muncul otomatis saat nominal melewati batas. |
| REQ11 / AC27 rekening tujuan | Sebagian | Daftar rekening milik akun dimuat dari API Komship. Validasi kepemilikan di request belum bisa dinilai karena pengajuan transaksi belum terhubung. |
| REQ12 / AC28–AC29 biaya | Sebagian | Pesan Rp2.000 dan gratis ada pada form. Pesan masih selalu tampil; perhitungan dana diterima dan pemotongan di proses admin belum terhubung. |
| REQ13–14 / AC17–AC23 saldo ideal | Sebagian | Endpoint partner `check-possible-withdraw` memberi saldo ideal dan maksimum; diperiksa saat input dan sebelum tombol Ajukan melanjutkan. Endpoint admin Komship ditolak HTTP 403 oleh token user dan tidak dipakai oleh form. Popup rincian saldo ideal ada, tetapi tidak otomatis tampil ketika tombol Ajukan nonaktif karena batas nominal. |
| REQ15 / AC11, AC30–AC34 PIN | Sebagian | Flow memakai komponen PIN bersama dari Pengaturan. Verifikasi terjadi sebelum form sesuai arahan sprint ini, sedangkan task meminta navigasi PIN setelah form; perilaku reset 24 jam dan logout seluruh perangkat perlu pengujian backend lintas fitur. |
| REQ16 / AC35 KYC | Sebagian | Status KYC dari profil dipakai untuk mengarahkan ke flow yang sudah ada. Pengecualian berdasarkan riwayat penarikan completed belum diterapkan. |
| AC25 hak akses | Belum | Belum terlihat pemeriksaan eksplisit partner versus pengguna Akses Akun pada entry point. |
| REQ17–18 / AC09, AC12–AC14, AC36–AC37 transaksi | Belum | Tombol Ajukan masih membuka layar hasil dan riwayat pratinjau. Belum ada POST Withdrawal, status transaksi nyata, pembaruan saldo, atau validasi backend pada flow ini. Tombol Kembali dari hasil sudah menuju Home. |
| REQ02–03 / AC15–AC16 visual dan respons | Sebagian | View utama dan beberapa varian popup tersedia; audit pixel per pixel dan seluruh jalur error/sukses runtime belum tuntas. |

Dengan kondisi ini, seluruh task **belum** dapat dinyatakan selesai. Untuk mengaktifkan validasi antrean tanpa menebak aturan bisnis, diperlukan endpoint user yang masih aktif dan mengembalikan status pengajuan atau penanda antrean. Status Android Komship untuk riwayat adalah `requested`, `on_review`, `in_process`, `completed`, `rejected`, dan `canceled`; tiga status pertama berpotensi menjadi kondisi menunggu, tetapi pemetaan final harus mengikuti backend yang aktif.
