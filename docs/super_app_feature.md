# Super App Feature

Dokumen ini menjelaskan struktur dan alur fitur pada `lib/features/superapp`. Folder ini adalah shell aplikasi baru yang dibangun di atas beberapa modul lama di `lib/features`, `lib/core`, dan `lib/common`.

## Gambaran arsitektur

```text
main.dart
  └── MultiBlocProvider / dependency injection
      └── AppRouter (common/global/router/app_router.dart)
          ├── Splash
          ├── Authentication
          └── MainPageSuperApp (/)
              ├── HomePageSuperapp
              ├── MutasiPage
              └── SettingPage

MainPageSuperApp juga membuka /team sebagai halaman operasional tim.
```

Implementasi mengikuti pola feature based + Clean Architecture:

- `view`/`views` dan `widget`: UI dan interaksi pengguna.
- `bloc`: state management menggunakan `flutter_bloc`.
- `domain`: entity, repository contract, dan use case.
- `data`: datasource remote, model, dan repository implementation.
- `lib/DI/injection.dart`: registrasi datasource, repository, use case, dan BLoC.
- `lib/core/data/apiservice/constat_endpoint.dart`: pembentukan endpoint dari konfigurasi environment.

## Hubungan dengan project lama

`lib/features/superapp` bukan seluruh fitur aplikasi secara mandiri. Router Super App masih mengimpor modul lama berikut:

| Modul lama | Dipakai untuk |
|---|---|
| `lib/features/profile` | Profil dan update data profile |
| `lib/features/pin` | PIN, verifikasi email/OTP, otorisasi pembayaran |
| `lib/features/ratetalent` | Rating talent dan evaluasi Kompoint |
| `lib/features/unhire` | Proses unhire talent |
| `lib/features/update` | Force update aplikasi |
| `lib/core` | API, model, repository, use case, preferences, dan auth |
| `lib/common/global` | Design system, global BLoC, router, dan helper |

Saat memindahkan atau mengubah fitur Super App, periksa dependency lintas folder tersebut sebelum menghapus kode lama.

## Shell dan navigasi

`MainPageSuperApp` menggunakan `ChangeNotifier` bernama `NavigationData` dan `IndexedStack` untuk menjaga state tiga tab utama:

| Tab | Implementasi | Keterangan |
|---|---|---|
| Home | `HomePageSuperapp` | Dashboard partner dan ringkasan operasional |
| Mutasi | `MutasiPage` di `home/view/main_page.dart` | Saat ini masih list transaksi contoh/placeholder |
| Pengaturan | `SettingPage` | Menu akun dan pengaturan |

Tombol floating live chat sudah ditampilkan di shell, tetapi callback `onPressed` masih kosong.

Halaman Team dibuka melalui route `/team`. Halaman ini dibuat dengan `HomeTeamCubit` yang menerima BLoC invoice, shopping, dan feed dari tree yang sudah ada. Jangan membuat instance BLoC baru untuk dependency tersebut di halaman Team.

## Authentication

Lokasi: `features/authentication`.

Alur utama:

1. `/email_check` menerima email dan melakukan validasi format serta pengecekan akun ke API.
2. Akun yang ditemukan diarahkan ke `/login` dengan email sebagai `state.extra`.
3. `/login` mengirim username/password dan token reCAPTCHA ke API.
4. Akun yang belum terverifikasi dapat diarahkan ke alur resend verification dan OTP.
5. Lupa password menggunakan `/forgot_password`, `/auth_otp`, `/reset-password`, dan `/success_new_password`.

BLoC yang digunakan:

- `CheckEmailBloc`: status email terdaftar, belum terdaftar, banned, atau tidak diizinkan.
- `LoginBloc`: validasi form, login, percobaan gagal, lock/penalty, dan akun belum terverifikasi.
- `ForgotPasswordBloc`: kirim email reset, resend, countdown, dan rate limit.
- `VerificationBloc`: pemilihan produk, pengiriman email verifikasi, resend, dan countdown.

Semua request autentikasi mengirim `device` (`android` atau `ios`) dan, jika tersedia, `recaptcha_token`. Konfigurasi Android reCAPTCHA dipisahkan untuk dev, staging, dan production di `lib/config/app_recaptcha_config.dart`. Site key iOS masih berupa placeholder `YOUR_IOS_SITE_KEY` dan perlu diisi sebelum login iOS digunakan.

## Home Super App

Lokasi: `features/home`.

`HomePageSuperapp` memuat header partner, saldo Kompay, menu layanan, grafik performa/revenue, notifikasi, dan refresh data. BLoC utama:

- `BalanceSummaryBloc`: ringkasan saldo dari service Komship.
- `RevenuePerformanceBloc`: data revenue dan order untuk grafik.
- `SuperappProfileBloc` (global): profile partner dan status akun.
- BLoC invoice, shopping, dan notifikasi untuk badge/ringkasan menu.

Komponen penting:

- `balance_section.dart`: saldo, top up, withdrawal, dan pending balance.
- `menu_content_section.dart`: menu dan filter periode grafik.
- `home_header_section.dart`/`ds_home_header.dart`: identitas partner dan akses notifikasi.
- `topup_flow_manager.dart`: orkestrasi status top up dan navigasi ke tagihan aktif.
- `home_verification_bottom_sheet.dart`: pengingat verifikasi akun.

## My App (`Aplikasiku`)

Lokasi: `features/myapp`.

Halaman `MyAppPage` menampilkan daftar layanan/aplikasi yang tersedia untuk partner. Alurnya sudah mengikuti pemisahan penuh:

```text
AplikasikuBloc
  → GetAplikasikuListUseCase
    → AplikasikuRepository
      → AplikasikuRemoteDataSource
        → AplikasikuResponse / AplikasikuEntity
```

`AppServiceCard`, `AppStatusChip`, dan `AppServiceShimmer` menangani tampilan kartu, status layanan, serta loading.

## Notification

Lokasi: `features/notification`.

Terdapat dua alur data:

- `NotificationV2Bloc` + `notification_v2_remote_datasource.dart`: daftar notifikasi Super App (`/komship/api/v1/notifications/v2/list`) dan mark as read.
- `NotificationInfoBloc`: detail/metadata notifikasi (`/komship/api/v1/notifications/info`).

`NotificationPage` memakai `AppNotificationCard`, icon kategori, dan shimmer. Badge notifikasi pada header mengambil count dari BLoC/use case notifikasi.

Push notification juga diinisialisasi pada `SplashCreenPage` melalui Firebase Messaging dan local notifications. Callback background sudah memakai `@pragma('vm:entry-point')` pada handler Firebase.

## Setting

### Informasi Akun / Profile (UI)

Menu Informasi Akun membuka `setting/view/account_profile_page.dart` melalui
`Navigator.push`, mengikuti pola Aplikasiku pada Pengaturan. Halaman menggunakan
`DsAppBar`, `DsButton`, `DsBottomSheet`, dan token design system Super App.

- `domain/entities/account_profile.dart`: nilai awal dan draft profil, gender
  bertipe enum, serta pilihan lokasi/sektor dengan ID dan label terpisah.
- `bloc/account_profile_cubit.dart`: perubahan draft, validasi field bisnis,
  status saving, dan penanganan kegagalan. Baseline baru diganti setelah callback
  penyimpanan berhasil; kegagalan mempertahankan input untuk dicoba kembali.
- `widget/profile_form_card.dart`: kartu dan baris form berlabel.
- `widget/profile_option_sheet.dart`: pilihan sementara dengan Kembali, tutup,
  dan Terapkan; pembatalan tidak mengubah draft.

Data pribadi awal berasal dari snapshot `SuperappProfileBloc.displayProfile`.
Data bisnis tidak diisi dengan identitas contoh desain. Kontrak API bisnis dan
pemetaan angka gender belum ditentukan, sehingga gender awal belum dipetakan
dari `SuperappProfileModel.gender`.

Integrasi berikutnya dilakukan pada composition layer: fetch detail lalu berikan
`initialProfile`; sambungkan use case update ke `onSave`, lookup lokasi/sektor ke
`loadLocations`/`loadBusinessSectors`, hasil upload URL ke `selectLogo`, dan URL
portal sesuai environment ke `partnerPortal`. Belum ada endpoint baru yang
dipanggil. Tanpa integrasi, lookup menunjukkan pilihan belum tersedia dan upload
menampilkan pemberitahuan; Simpan tidak mengklaim data telah tersimpan.

Nomor HP dan email bersifat read-only dengan penjelasan verifikasi melalui Web
Partner. Tombol Simpan tetap di bawah layar; aktif saat draft berubah dan field
wajib valid. Nama bisnis dibatasi 30 karakter.

Lokasi: `features/setting`.

`SettingPage` adalah menu pengaturan/akun pada tab ketiga shell. Item menu dirender oleh `SettingMenuItem` dan menavigasi ke fitur lintas folder seperti profile, ubah password, PIN, dan logout.

## Team workspace

Lokasi: `features/team`.

### Team home

`HomePageTeam` menampilkan:

- banner action required untuk invoice belum diproses dan shopping request berstatus `requested`;
- grid menu Team;
- feed informasi terbaru.

`HomeTeamCubit` meneruskan navigasi ke invoice, shopping, attendance, performance, talent pool, dan feed.

### Invoice

Lokasi: `team/invoice`.

Fitur:

- daftar invoice dan filter status akun;
- invoice baru;
- ringkasan/detail invoice;
- pilihan metode pembayaran;
- pembayaran Kompay/Xendit;
- halaman sukses pembayaran;
- download invoice dan pengecekan evaluasi talent.

BLoC: `InvoiceListBloc`, `InvoiceReportSummaryBloc`, dan `PaymentMethodBloc`. Beberapa alur pembayaran meneruskan `invoiceId`, `invoiceCode`, `statusAccount`, `xenditUrl`, dan `from` melalui query parameter atau `state.extra`.

### Shopping

Lokasi: `team/shopping`.

Fitur: daftar shopping request, filter, detail item/talent, pembatalan, pembayaran, dan status request. BLoC `ShoppingBloc` mengelola list, detail, cancel, dan pay.

### Attendance

Lokasi: `team/attendance`.

Menampilkan daftar presensi, presensi gagal/ticket, ketidakhadiran, empty state, filter/search, shimmer, dan export/download laporan. BLoC: `AttendanceBloc`.

### Feed

Lokasi: `team/feed`.

Menampilkan daftar berita/informasi dan detail berita. BLoC: `FeedBloc`; detail menerima id melalui `state.extra` pada route `/feed_detail`.

### Performance

Lokasi: `team/performance`.

Menampilkan laporan performa talent dengan ringkasan hari/minggu/bulan, filter produk, kartu detail bulan, dan modal detail. BLoC: `ReportPerformanceBloc`.

### Talent Pool

Lokasi: `team/talentpool`.

Menampilkan talent yang tersedia dengan filter sektor bisnis, pencarian, rekomendasi, statistik, dan wishlist. BLoC: `TalentPoolBloc` dan `BusinessSectorBloc`. Data berasal dari endpoint resource talent pool dan endpoint rekomendasi talent.

### List of Team

Lokasi: `team/listteam`.

Menampilkan daftar team internal/Komtim, anggota, role/access, pencarian, dan status akses. BLoC: `ListOfTeamBloc`.

## Top up dan pembayaran

Lokasi: `features/topup`.

Alur top up mencakup:

- top up melalui bank/Kompay;
- pembuatan dan pengecekan invoice;
- QRIS: create QR, check QR, expire QR;
- web view pembayaran;
- pengecekan tagihan dan pembatalan transaksi.

BLoC yang terlibat: `CheckBillBloc`, `CreateInvoiceBloc`, `ExpireInvoiceBloc`, `CheckQrcodeBloc`, `CreateQrcodeBloc`, dan `ExpireQrcodeBloc`. `TopupFlowManager` membantu menghubungkan state BLoC dengan navigasi UI.

## Route penting

Router utama berada di `lib/common/global/router/app_router.dart`. `lib/core/router/app_router.dart` adalah implementasi router lain yang masih ada di repository; perubahan route sebaiknya disamakan atau dipastikan router yang dipakai oleh `main.dart`.

| Route | Halaman | Parameter penting |
|---|---|---|
| `/splash` | Splash/startup | — |
| `/email_check` | Check email | — |
| `/login` | Login | `state.extra`: email |
| `/forgot_password` | Lupa password | — |
| `/auth_otp` | OTP auth | `state.extra`: email |
| `/reset-password` | Password baru | query `code` |
| `/` | Main Super App | — |
| `/team` | Team home | — |
| `/notifications` | Daftar notifikasi | — |
| `/profile_info` | Profile | — |
| `/invoice_list` | Daftar invoice | query `statusAccount` |
| `/invoice_summary_report` | Ringkasan invoice | `invoiceCode`, `statusAccount`, `from` |
| `/payment_method` | Metode pembayaran | `id`, `xenditUrl` |
| `/success_payment` | Hasil pembayaran | `invoiceId`, `status` |
| `/shopping_list_page` | Shopping request | — |
| `/detail_shopping_page` | Detail shopping | query `id` |
| `/attendance_pages` | Attendance | — |
| `/feed` | Feed | — |
| `/feed_detail` | Detail feed | `state.extra`: id |
| `/report_performance` | Performance report | — |
| `/report_detail_performance` | Detail performance | `state.extra`: detail model/product |
| `/talent_pool` | Talent pool | — |
| `/list_of_team` | Daftar team | — |
| `/pin_page` | PIN | `pinType`, `firstPin`, `doJobFor`, `invoiceId`, `statusA` |

Semua route selain splash, force update, dan route authentication diperlakukan sebagai protected route. `AuthBloc` menjadi sumber status autentikasi dan `GoRouterRefreshStream` memicu evaluasi redirect.

## API dan environment

`Config.instance` memilih environment dari `--dart-define=FLAVOR`:

| Flavor | Base URL partner | Base URL Super App |
|---|---|---|
| `dev` | `https://dev.go.komtim.komerce.my.id` | `https://api.internal.komerce.my.id/dev` |
| `staging` | `https://staging.go.komtim.komerce.my.id` | `https://api.internal.komerce.my.id/staging` |
| `production` | `https://api.komtim.komerce.id` | `https://api.partner.komerce.id` |

Endpoint API dikelompokkan di `Endpoints` untuk auth, profile, invoice, transaction/top up, PIN, history, shopping, attendance, feed, notification, Kompay, talent pool, performance, balance summary, dan team.

Contoh menjalankan dev ke device Android wireless:

```bash
fvm flutter run \
  -d adb-1468240586001999-5wEPWu._adb-tls-connect._tcp \
  --flavor dev \
  --dart-define=FLAVOR=dev
```

## Catatan pemeliharaan

- Jalankan `flutter pub get` setelah perubahan dependency.
- Perubahan route harus mempertimbangkan redirect auth dan parameter `state.extra`/query.
- Fitur yang menggunakan payment, PIN, top up, dan profile bergantung pada modul lama di luar folder `superapp`.
- `MutasiPage` dan tombol live chat masih berupa implementasi awal.
- Jangan menganggap `dev` menonaktifkan reCAPTCHA; backend tetap memvalidasi token dan threshold.
- Saat mengubah endpoint, periksa pemilihan base URL karena sebagian endpoint memakai `_BaseURL`, sebagian `_BaseURLSuperApp`, `_BaseURLInternal`, `_BaseURLKomship`, atau `_BaseURLTalentPool`.
