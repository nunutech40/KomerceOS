---
topic: 2FA OTP Partner Login Flow
date: 2026-11-13
version: 2
status: completed
related_files:
  - lib/core/data/apiservice/constat_endpoint.dart
  - lib/core/data/apiservice/interceptors/auth_interceptor.dart
  - lib/core/data/datasources/remote/auth_remote_datasource.dart
  - lib/core/data/repositories/auth_repository_impl.dart
  - lib/core/data/repositories/superapp_profile_repository_impl.dart
  - lib/core/data/models/two_fa_auth_exception.dart
  - lib/core/domain/usecases/verify_login_otp_use_case.dart
  - lib/DI/injection.dart
  - lib/common/global/bloc/superapp_profile/superapp_profile_event.dart
  - lib/common/global/bloc/superapp_profile/superapp_profile_bloc.dart
  - lib/features/superapp/features/authentication/bloc/login_bloc.dart
  - lib/features/superapp/features/authentication/views/login_page.dart
  - lib/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart
  - lib/features/superapp/features/authentication/widgets/two_fa_verify_otp_bottom_sheet.dart
  - lib/features/superapp/features/authentication/widgets/two_fa_locked_bottom_sheet.dart
---

# Research: 2FA OTP Partner Login Flow & Profile Optimization

## Summary
Flow login KomerceOS telah diperbarui menjadi 4 langkah terstruktur yang disinkronkan 1:1 dengan backend `komship-mobile`: `check-login` tetap dipertahankan di tahap cek email, lalu login password memanggil `auth/api/v1/auth/partner/login`, dilanjutkan pemilihan metode 2FA (`v2/otp/request`) dan verifikasi OTP (`v2/otp/verify-login`). Setelah verifikasi OTP sukses menghasilkan `jwt_token`, repository otomatis memvalidasi profil via `SuperappProfileRepository.getProfile()`, menyinkronkan `USERANDTOKEN` serta `PROFILEDATA` ke `SharedPreferences`, lalu menyimpan profil in-memory sementara (`seedPendingProfile`). Saat `AuthBloc` menjadi `authenticated`, `SuperappProfileBloc` mengonsumsi profil sementara tersebut (`consumePendingProfile`, consume-once) sehingga endpoint `get-profile-mobile` hanya dipanggil **tepat 1x** tanpa hit ganda, saldo langsung tampil seketika di Home tanpa jeda shimmer.

## File yang Relevan
- `lib/core/data/apiservice/constat_endpoint.dart` — tambah `partnerLogin`, `requestLoginOtp`, `verifyLoginOtp`; tandai `Endpoints.login` sebagai `[LEGACY]`.
- `lib/core/data/apiservice/interceptors/auth_interceptor.dart` — mendaftarkan 3 endpoint 2FA ke `_publicEndpoints` dan mengecualikan HTTP/meta `500` `"user not found"` pada `Endpoints.partnerLogin` agar tidak memicu `ShowServerErrorEvent`.
- `lib/core/data/models/partner_login_response.dart`, `request_login_otp_response.dart`, `verify_login_otp_response.dart` — parsing response 2FA + `PendingOtpResponse` + `otp_limit_exceeded`.
- `lib/core/data/models/two_fa_auth_exception.dart` & `lib/core/domain/entities/two_fa_failure.dart` — parser exception/failure terstruktur (`userNotFound`, `otpLocked24Hours`, `passwordLocked24Hours`, `incorrectPassword`, `expiredToken`, `otpInvalidLocked`, `otpInvalid`).
- `lib/core/data/datasources/remote/auth_remote_datasource.dart` — implementasi `partnerLogin`, `requestLoginOtp`, `verifyLoginOtp` dengan payload exact Komship (`username_email`, `password`, `token`, `type`, `otp_value`, `recaptcha_token`, `device`, tanpa `'app'`).
- `lib/core/data/repositories/auth_repository_impl.dart` — meneruskan failure terstruktur dan menjalankan `completeTwoFaSession(jwtToken)` (simpan JWT sementara -> `getProfile()` -> `saveUserAndToken` + `saveProfileData` -> `seedPendingProfile(profile)` -> rollback penuh bila gagal).
- `lib/core/data/repositories/superapp_profile_repository_impl.dart` — tambah `seedPendingProfile` dan `consumePendingProfile` (consume-once in-memory handover) serta reset saat `clearCache()`.
- `lib/core/domain/usecases/partner_login_use_case.dart`, `request_login_otp_use_case.dart`, `verify_login_otp_use_case.dart` — domain use cases; `VerifyLoginOtpUseCase` memanggil `completeTwoFaSession` dan dispatch `AuthLoginRequested(user)`.
- `lib/DI/injection.dart` — menyuntikkan `SuperappProfileRepository` ke `AuthRepositoryImpl`, registrasi 3 use case baru, dan wiring ke `LoginBloc` serta `SuperappProfileBloc`.
- `lib/common/global/bloc/superapp_profile/superapp_profile_event.dart` — `FetchSuperappProfileEvent(usePreloaded: true)`.
- `lib/common/global/bloc/superapp_profile/superapp_profile_bloc.dart` — saat `AuthStatus.authenticated`, trigger `FetchSuperappProfileEvent(usePreloaded: true)`; jika preloaded profil tersedia, langsung emit `loaded` tanpa hit API kedua.
- `lib/features/superapp/features/authentication/bloc/login_bloc.dart` (+ `login_event.dart`, `login_state.dart`) — state machine 2FA (`LoginTwoFaStage`), pemisahan `loginToken` vs `otpToken`, reCAPTCHA action (`CHECK_EMAIL`, `LOGIN`, `REQUEST_OTP`, `VERIFY_OTP`), dan guard cancellation `_twoFaSessionVersion`.
- `lib/features/superapp/features/authentication/views/login_page.dart` — satu host modal bottom sheet (`_TwoFaModalContent`) untuk seluruh transisi `selectMethod` ↔ `verifyOtp` ↔ `otpLocked24Hours` serta handling popup `PartnerLoginErrorType`.
- `lib/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart`, `two_fa_verify_otp_bottom_sheet.dart`, `two_fa_locked_bottom_sheet.dart` — komponen UI 2FA (`bgPopup` `#DCDCDC`, radius `30`, border putih `1px`, aset `ic_email_two_fa.svg`, `ic_wa_two_fa.svg`, `ic_message_two_fa.svg`, `failed_img.svg`).

## Architecture / Data Flow
```
EmailCheckPage / LoginPage (cek email)
  → reCAPTCHA(CHECK_EMAIL) → Endpoints.checkEmail
  → isAllowedLogin == true

LoginPage (submit password)
  → LoginBloc: LoginButtonPressedEvent
  → reCAPTCHA(LOGIN) → PartnerLoginUseCase → POST /auth/api/v1/auth/partner/login
      ├─ pending_otp != null → stage = verifyOtp (pakai pending_otp.token sebagai otpToken, simpan loginToken)
      └─ pending_otp == null → stage = selectMethod (simpan loginToken, twoFaEmail, twoFaPhone, otpLimitExceeded)

TwoFaMethodBottomSheet (pilih email/whatsapp/sms)
  → LoginBloc: LoginTwoFaMethodSelectedEvent
  → reCAPTCHA(REQUEST_OTP) → RequestLoginOtpUseCase(loginToken, type)
  → POST /auth/api/v2/otp/request
  → stage = verifyOtp (update otpToken, otpExpiresIn, otpCountdownKey++, loginToken tetap utuh)

TwoFaVerifyOtpBottomSheet
  ├─ Kirim Ulang → LoginOtpResendRequestedEvent → reCAPTCHA(REQUEST_OTP) → v2/otp/request(loginToken, type)
  ├─ Gunakan Metode Lain → LoginTwoFaChangeMethodRequestedEvent → stage = selectMethod
  └─ Konfirmasi OTP (6 digit) → LoginOtpSubmittedEvent
       → reCAPTCHA(VERIFY_OTP) → VerifyLoginOtpUseCase(otpToken, otp)
       → POST /auth/api/v2/otp/verify-login → dapat jwt_token
       → AuthRepository.completeTwoFaSession(jwt_token):
            1. SecureStorageService.saveAccessToken(jwt_token)
            2. SuperappProfileRepository.getProfile() [HIT #1 - satu-satunya hit ke server]
            3. SharedPref.saveUserAndToken(...) & SharedPref.saveProfileData(...)
            4. SuperappProfileRepository.seedPendingProfile(profile) [Simpan in-memory handover]
            (gagal di langkah mana pun → _rollbackTwoFaSession)
       → AuthBloc.add(AuthLoginRequested(user))
       → SuperappProfileBloc mendengar authState.status == authenticated
            → dispatch FetchSuperappProfileEvent(usePreloaded: true)
            → repo.consumePendingProfile() mengambil profil in-memory & langsung clear
            → emit SuperappProfileStatus.loaded seketika [0 hit API tambahan!]
       → GoRouter redirect /login → /main (Home langsung menampilkan profil & saldo fresh tanpa shimmer)
```

## Existing Patterns yang Diikuti
- **Consume-Once Preloaded Profile Handshake**: Menghilangkan redudansi request jaringan saat login 2FA tanpa memutus integritas rollback. Repository tetap memverifikasi token dengan `getProfile()` sebelum sesi disimpan, tetapi hasil in-memory dibagikan ke `SuperappProfileBloc` via `seedPendingProfile`/`consumePendingProfile`.
- **Dual-token discipline**: `loginToken` dari `partner/login` hanya dipakai untuk `v2/otp/request` (request awal, resend, ganti metode) dan tidak pernah ditimpa oleh `pending_otp.token` / `v2/otp/request.data.token` (`otpToken` khusus `v2/otp/verify-login`).
- **Endpoint publik & interceptor**: Ketiga endpoint 2FA termasuk `_publicEndpoints` di `AuthInterceptor`; respons HTTP/meta `500` dengan pesan `"user not found"` di `Endpoints.partnerLogin` ditekan dari `ShowServerErrorEvent` agar ditangani inline sebagai `'Email belum terdaftar'`.
- **Single modal host & controller lifecycle**: `_TwoFaModalContent` mengelola `TextEditingController` OTP di dalam route modal agar aman dari dispose dini saat GoRouter meng-unmount `LoginPage`.
- **Error priority order**: Pada response error `partner/login`, `ERR_ROLE_TEAM_INTERNAL_BLOCKED` dan error non-partner dicek lebih dulu sebelum klasifikasi password-attempt agar tidak salah terdeteksi karena substring `"lock"`.
- **Unit & widget test conventions**: Mock di `test/helpers/mocks/mocks.dart`, `bloc_test` untuk `LoginBloc` dan `SuperappProfileBloc`, `DsPasswordField` wajib diinput karakter demi karakter pada widget test karena `_NoPasteFormatter`.

## Risks & Edge Cases
- **Pull to refresh tetap fetch fresh**: Di `HomePageSuperapp`, event `FetchSuperappProfileEvent()` dikirim tanpa parameter `usePreloaded` (`default: false`), sehingga pull-to-refresh selalu meminta data live dari server.
- **Cold start tidak terpengaruh**: Saat app baru dibuka dari posisi sudah login (`AuthCheckRequested`), `consumePendingProfile()` bernilai `null` sehingga BLoC membaca cache lokal lebih dulu lalu merefresh dari server sesuai mekanisme aslinya.
- **Rollback safety**: Jika penyimpanan pref gagal, `_rollbackTwoFaSession` memanggil `profileRepo.clearCache()` yang sekaligus menghapus `_pendingFreshProfile` sehingga tidak ada kebocoran data di memori.
- **Otp invalid preserves digits, switch method clears digits**: Saat OTP salah (`attemptLeft > 0`), input OTP dipertahankan; ketika `otpCountdownKey` bertambah atau user kembali dari pilih metode, `_otpController` di-clear.
- **Otp limit exceeded**: Dapat muncul baik di response awal `partner/login` (`otp_limit_exceeded: true` → nonaktifkan pemilihan metode & tampilkan `'Request OTP sudah mencapai batas.'`) maupun di response `v2/otp/request` saat resend.
- **Expired token OTP**: Error `422` `"Expired token"` menandai `isOtpSessionExpired = true` & `isOtpLocked = true` sehingga input, kirim ulang, ganti metode, dan konfirmasi dinonaktifkan dengan notice `'Sesi telah berakhir, silahkan coba lagi'`.

## Notes
- Endpoint `get-profile-mobile` pada flow login terbukti terpanggil tepat **1x** di Chucker.
- Saldo dan kompoints langsung tampil di Home tanpa menunggu loading API kedua.
- Verifikasi terakhir (2026-11-13): `fvm flutter analyze --no-pub` 0 errors, automated test suite 107/107 passed!

---

## 📋 Changelog
| Versi | Tanggal    | Perubahan |
|-------|------------|-----------|
| v1    | 2026-11-12 | Initial: implementasi lengkap Data, Domain, DI, BLoC, UI bottom sheet, dan verifikasi 255 test 2FA OTP Partner Login |
| v2    | 2026-11-13 | Optimisasi 1x hit API `get-profile-mobile` pasca-login 2FA via Consume-Once Preloaded Profile Handshake (`seedPendingProfile` / `consumePendingProfile`) |
