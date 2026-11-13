---
topic: 2FA OTP Partner Login Flow
date: 2026-11-12
status: completed
independence_level: 2
shared_files_touched:
  - lib/core/data/apiservice/constat_endpoint.dart
  - lib/core/data/apiservice/interceptors/auth_interceptor.dart
  - lib/DI/injection.dart
phases_total: 3
phases_completed: 3
---

# Implementation Plan — 2FA OTP Partner Login Flow

Flow autentikasi password + 2FA OTP KomerceOS meniru kontrak endpoint, payload, manajemen dua token, aksi reCAPTCHA Enterprise, dan penanganan error dari `komship-mobile`, sambil mempertahankan endpoint `check-login` dan menyinkronkan profil + `SharedPreferences` setelah verifikasi OTP berhasil.

---

### Phase 1: Data Layer (`constat_endpoint.dart`, `AuthInterceptor`, Entities/Failures, Response Models/Exceptions, `AuthRemoteDataSource`, `AuthRepository`)
**Status:** ✅

**Files dimodifikasi (Level 2 — additive / auth-scoped):**
- [x] `lib/core/data/apiservice/constat_endpoint.dart` — tambah `partnerLogin`, `requestLoginOtp`, `verifyLoginOtp`; tandai `Endpoints.login` sebagai legacy.
- [x] `lib/core/data/apiservice/interceptors/auth_interceptor.dart` — tambah 3 endpoint 2FA ke `_publicEndpoints`, dan kecualikan HTTP/meta 500 `"user not found"` pada `Endpoints.partnerLogin` dari `ShowServerErrorEvent`.
- [x] `lib/core/data/datasources/remote/auth_remote_datasource.dart` — tambah `partnerLogin`, `requestLoginOtp`, `verifyLoginOtp` dengan payload exact Komship (`username_email`/`password`/`recaptcha_token`/`device`, tanpa `'app'`) serta ekstraksi error terstruktur.
- [x] `lib/core/domain/repositories/auth_repository.dart` — tambah kontrak `partnerLogin`, `requestLoginOtp`, `verifyLoginOtp`, `completeTwoFaSession`.
- [x] `lib/core/data/repositories/auth_repository_impl.dart` — implementasi method 2FA, teruskan `PartnerLoginFailure`/`VerifyOtpFailure`, serta `completeTwoFaSession` (simpan sementara JWT -> `SuperappProfileRepository.getProfile()` -> sync `USERANDTOKEN` & `PROFILEDATA` -> rollback penuh bila gagal).

**Files baru:**
- [x] `lib/core/domain/entities/partner_login_model.dart`
- [x] `lib/core/domain/entities/request_login_otp_model.dart`
- [x] `lib/core/domain/entities/verify_login_otp_model.dart`
- [x] `lib/core/domain/entities/two_fa_failure.dart`
- [x] `lib/core/data/models/partner_login_response.dart`
- [x] `lib/core/data/models/request_login_otp_response.dart`
- [x] `lib/core/data/models/verify_login_otp_response.dart`
- [x] `lib/core/data/models/two_fa_auth_exception.dart`

**Tests Phase 1:**
- [x] `test/core/data/models/partner_login_response_test.dart`
- [x] `test/core/data/models/request_login_otp_response_test.dart`
- [x] `test/core/data/models/verify_login_otp_response_test.dart`
- [x] `test/core/data/models/two_fa_auth_exception_test.dart`
- [x] `test/core/data/apiservice/interceptors/auth_interceptor_session_test.dart`
- [x] `test/core/data/apiservice/interceptors/auth_interceptor_server_error_test.dart`
- [x] `test/core/data/datasources/remote/auth_remote_datasource_test.dart`
- [x] `test/core/data/repositories/auth_repository_impl_test.dart`

---

### Phase 2: Domain Layer (UseCases + DI Registration)
**Status:** ✅

**Files baru:**
- [x] `lib/core/domain/usecases/partner_login_use_case.dart`
- [x] `lib/core/domain/usecases/request_login_otp_use_case.dart`
- [x] `lib/core/domain/usecases/verify_login_otp_use_case.dart`

**Files dimodifikasi:**
- [x] `lib/core/domain/usecases/do_login_use_case.dart` — tandai komentar dokumentasi sebagai legacy (`[LEGACY]`).
- [x] `lib/DI/injection.dart` — inject `superappProfileRepository` ke `AuthRepositoryImpl` dan daftarkan `PartnerLoginUseCase`, `RequestLoginOtpUseCase`, `VerifyLoginOtpUseCase` (factory `LoginBloc` akan diperbarui di Phase 3 agar Phase 2 tetap terisolasi dan compile-clean).
- [x] `test/helpers/mocks/mocks.dart` — tambah mock untuk `CheckEmailLoginUseCase`, `PartnerLoginUseCase`, `RequestLoginOtpUseCase`, `VerifyLoginOtpUseCase` dan regenerasi `mocks.mocks.dart`.

**Tests Phase 2:**
- [x] `test/core/domain/usecases/partner_login_use_case_test.dart`
- [x] `test/core/domain/usecases/request_login_otp_use_case_test.dart`
- [x] `test/core/domain/usecases/verify_login_otp_use_case_test.dart`

---

### Phase 3: Presentation Layer (`LoginBloc` + `LoginPage` Wiring + UI Tests)
**Status:** ✅

**Files dimodifikasi:**
- [x] `lib/DI/injection.dart` — perbarui factory `LoginBloc` dengan 3 UseCase 2FA baru (`PartnerLoginUseCase`, `RequestLoginOtpUseCase`, `VerifyLoginOtpUseCase`).
- [x] `lib/features/superapp/features/authentication/bloc/login_event.dart` — tambah event `LoginTwoFaMethodSelectedEvent`, `LoginOtpResendRequestedEvent`, `LoginOtpSubmittedEvent`, `LoginTwoFaChangeMethodRequestedEvent`, `LoginTwoFaDismissedEvent`.
- [x] `lib/features/superapp/features/authentication/bloc/login_state.dart` — tambah `LoginTwoFaStage`, `loginToken`, `otpToken`, `twoFaEmail`, `twoFaPhone`, `selectedMethod`, `otpExpiresIn`, `otpCountdownKey`, `otpLimitExceeded`, `otpAttemptsLeft`, `otpErrorMessage`, `isOtpSessionExpired`, `isOtpLocked`, `isRequestingOtp`, `isResendingOtp`, `isVerifyingOtp`, `twoFaActionErrorMessage`, `twoFaLockedVariant`, `partnerLoginErrorType`, `loginAttemptsLeft`.
- [x] `lib/features/superapp/features/authentication/bloc/login_bloc.dart` — orkestrasi flow `CHECK_EMAIL` -> `LOGIN` -> `REQUEST_OTP` -> `VERIFY_OTP`, aturan dual-token (`loginToken` vs `otpToken`), mapping error terstruktur (`userNotFound`, `otpLocked24Hours`, `passwordLocked24Hours`, `incorrectPassword`, `expiredToken`, `otpInvalidLocked`, `otpInvalid`), guard `_twoFaSessionVersion`, dan `otpLimitExceeded`.
- [x] `lib/features/superapp/features/authentication/views/login_page.dart` — host single modal 2FA (`_TwoFaModalContent`) agar controller OTP aman terhadap redirect GoRouter, tampilkan notice inline & handling `PartnerLoginErrorType`.
- [x] `lib/features/superapp/features/authentication/widgets/two_fa_method_bottom_sheet.dart` — UI pemilihan metode Email/WA/SMS + notice batas request OTP.
- [x] `lib/features/superapp/features/authentication/widgets/two_fa_verify_otp_bottom_sheet.dart` — UI 6-digit OTP box, countdown kirim ulang / ganti metode, notice `'Request OTP sudah mencapai batas.'`, state sesi berakhir & salah OTP.
- [x] `lib/features/superapp/features/authentication/widgets/two_fa_locked_bottom_sheet.dart` — UI lock 24 jam (`Verifikasi Kode OTP Gagal` & `Akun Kamu Dibatasi!`).

**Tests Phase 3:**
- [x] `test/features/superapp/features/authentication/recaptcha_action_flow_test.dart`
- [x] `test/features/superapp/features/authentication/bloc/login_bloc_test.dart`
- [x] `test/features/superapp/features/authentication/login_2fa_flow_test.dart`

---

## Decisions Log
- **check-login dipertahankan**: Tahap cek email tetap memanggil `Endpoints.checkEmail` (`CHECK_EMAIL`), sedangkan tahap password beralih dari `Endpoints.login` ke `Endpoints.partnerLogin` (`LOGIN`).
- **Payload disinkronkan dengan Komship**: `partner/login`, `v2/otp/request`, dan `v2/otp/verify-login` tidak mengirim field `'app'`, hanya mengirim `'device'` (`android`/`ios`) dan `'recaptcha_token'`.
- **Dual token rule**: `loginToken` (`partner/login.data.token`) khusus untuk `v2/otp/request` (awal, resend, ganti metode); `otpToken` (`pending_otp.token` / `v2/otp/request.data.token`) khusus untuk `v2/otp/verify-login` dan tidak boleh menimpa `loginToken`.
- **Post-verify profile & SharedPreferences sync**: Setelah OTP terverifikasi -> simpan JWT sementara ke `SecureStorageService` -> panggil `SuperappProfileRepository.getProfile()` -> simpan juga `USERANDTOKEN` & `PROFILEDATA` ke `SharedPref` -> dispatch `AuthLoginRequested(user)`. Gagal = rollback token + cache + pref sesi.
- **Single Modal 2FA Host (`_TwoFaModalContent`)**: Seluruh transisi modal (`selectMethod` ↔ `verifyOtp` ↔ `otpLocked24Hours`) di-host dalam satu `showModalBottomSheet` dengan `_TwoFaModalContent` `StatefulWidget` yang memiliki `_otpController` sendiri di rute modal sehingga aman saat GoRouter me-unmount `LoginPage` ketika redirect `/login` → `/main`.
- **Endpoints & legacy code**: `Endpoints.login`, `doLogin`, dan `DoLoginUseCase` dibiarkan sementara dan ditandai komentar `[LEGACY]`.

## Progress Notes
- UI widgets Phase-1 (`TwoFaMethodBottomSheet`, `TwoFaVerifyOtpBottomSheet`, `TwoFaLockedBottomSheet`, assets, preview app) sudah tersedia dan terisolasi di working tree (`two_fa_ui_preview_main.dart` tetap dipertahankan sebagai entrypoint simulator UI terpisah).
- Phase 1 (Data Layer) selesai & terverifikasi: `fvm flutter analyze` pada 19 file Phase 1 menghasilkan `No issues found!` (proyek penuh 0 errors), dan `fvm flutter test test/core/data/` lulus seluruhnya (`+188: All tests passed!`).
- Phase 2 (Domain Layer + DI Registration UseCases/Repository) selesai & terverifikasi: `fvm flutter analyze` pada 10 file Phase 2 menghasilkan `No issues found!` (proyek penuh `--no-pub` 0 errors), `fvm flutter test test/core/domain/usecases/` lulus (`+25`), dan suite gabungan `test/core/data/ test/core/domain/usecases/ test/features/superapp/features/authentication/` lulus seluruhnya (`+220: All tests passed!`).
- Phase 3 (Presentation Layer + End-to-End UI Wiring) selesai & terverifikasi: `fvm flutter analyze --no-pub` proyek penuh menghasilkan 0 errors dan 0 warnings/infos pada seluruh file yang dimodifikasi/baru; suite gabungan `fvm flutter test --no-pub test/core/data/ test/core/domain/usecases/ test/features/superapp/features/authentication/` lulus seluruhnya (**`+255: All tests passed!`**), mencakup `recaptcha_action_flow_test.dart`, `login_bloc_test.dart`, dan 5 widget test end-to-end di `login_2fa_flow_test.dart`.

