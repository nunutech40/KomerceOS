# Code Review Checklist — komtim_partner
> Flutter + BLoC + Clean Architecture + FVM + Flavor + GitLab CI
> Last reviewed: 2026-03-30

---

## 1. 🏗️ Architecture & Code Structure
- [ ] Layer separation konsisten? (`data` → `domain` → `presentation`) — cek apakah ada feature yang masih campur logika di UI
- [ ] Feature folder (`attendance`, `auth`, `invoice`, dst.) — apakah masing-masing punya `bloc/`, `view/`, `data/` sendiri, atau masih ciprate ke `core/`?
- [ ] `lib/DI/injection.dart` sebesar 23KB — cek circular dependency atau registrasi yang tidak perlu
- [ ] `common/` vs `core/` — apakah pembagiannya jelas? (`string.dart` 11KB di `common/` bisa jadi terlalu besar, perlu dipecah)

---

## 2. 🔐 Security
- [ ] `flutter_secure_storage` — apakah semua token/credential tersimpan di sini, **bukan** di `shared_preferences`?
- [ ] `firebase_options.dart` — pastikan tidak ada sensitive key yang ter-commit ke repo
- [ ] API key / base URL di `config/dev.dart`, `staging.dart`, `production.dart` — apakah hardcoded atau pakai env?
- [ ] `dart_jsonwebtoken` — apakah JWT di-decode/verify di client? (ini anti-pattern, verifikasi harusnya di server)
- [ ] `chucker_flutter` — pastikan **hanya aktif di dev/staging**, bukan production build

---

## 3. 📦 Dependency Management
- [ ] `go_router: ^9.0.0` — sudah jauh tertinggal (sekarang v14+), perlu cek breaking changes sebelum upgrade
- [ ] Font family ada 3 (PlusJakartaSans, Poppins, Inter) — apakah ketiganya benar-benar dipakai semua? Audit & hapus yang tidak terpakai
- [ ] `in_app_update` + `upgrader` — ada **dua package** untuk fitur yang sama, pilih salah satu
- [ ] **`flutter_lints: ^2.0.0` → pindah ke `dev_dependencies`** (sekarang salah tempat)
- [ ] **`change_app_package_name` → pindah ke `dev_dependencies`** (sekarang salah tempat)

---

## 4. 🧪 Testing
- [ ] `integration_test/` hanya ada 2 folder (`auth/`, `robots/`) — seberapa besar coverage-nya?
- [ ] Apakah ada file `_test.dart` unit test di feature folders (BLoC layer)?
- [ ] CI pipeline tidak ada step `flutter test` — build bisa jalan meskipun test failure

---

## 5. 🚀 CI/CD Pipeline (`gitlab-ci.yml`)
- [ ] `image: instrumentisto/flutter:latest` — **ganti ke versi spesifik**, `latest` tidak deterministik dan bisa break kapan saja
- [ ] Tidak ada step `flutter analyze` di CI — lint errors bisa lolos ke build
- [ ] Tidak ada step `flutter test` di CI
- [ ] Artifact iOS build tidak ada di CI (hanya APK Android)
- [ ] Masih pakai `only:` — pertimbangkan migrasi ke `rules:` (syntax GitLab CI yang lebih baru)

---

## 6. 🎨 UI/UX Consistency
- [ ] `analysis_options.yaml` masih default kosong — tambah custom lint rules (misal: `avoid_print`, `prefer_single_quotes`)
- [ ] `styles.dart` 6KB di `common/` — apakah design system sudah konsisten antar feature, atau tiap feature punya style sendiri?
- [ ] Cek apakah ada `setState` berlebih di widget yang seharusnya dihandle BLoC

---

## 7. ⚡ Performance
- [ ] `cached_network_image` — apakah dipakai konsisten atau masih ada yang pakai `Image.network()` langsung?
- [ ] BLoC `BlocBuilder` — apakah rebuild scope-nya sudah kecil? Idealnya pakai `buildWhen` untuk hindari unnecessary rebuild
- [ ] `shimmer` — apakah loading state konsisten di semua feature?
- [ ] Cek memory leak: `StreamSubscription` di BLoC/Widget yang tidak di-`cancel` / `close`

---

## 8. 🌐 Networking & Error Handling
- [ ] `dio` — apakah ada interceptor yang handle 401 (token refresh) dan retry logic?
- [ ] `exception.dart` dan `failure.dart` — apakah semua error path sudah ter-cover dan konsisten?
- [ ] `connectivity_plus` — apakah ada global offline handler, atau per-feature saja?

---

## 9. 📋 Documentation & Maintainability
- [ ] `README.md` — apakah sudah up-to-date dengan cara run per-flavor (`dev`, `staging`, `production`)?
- [ ] `auth_refactoring_task.md` di root — pindah ke `docs/` atau hapus setelah selesai
- [ ] `list_api.txt` di root — pindah ke `docs/` atau hapus

---

## 🔑 Priority Quick Wins

| Priority | Item |
|---|---|
| 🔴 Critical | `flutter_lints` & `change_app_package_name` → pindah ke `dev_dependencies` |
| 🔴 Critical | Tambah `flutter analyze` di CI sebelum build |
| 🟠 High | `in_app_update` vs `upgrader` — pilih satu, hapus yang lain |
| 🟠 High | Pastikan `chucker_flutter` di-disable di production |
| 🟡 Medium | Pin Flutter version di CI (jangan `latest`) |
| 🟡 Medium | Tambah minimal unit test di BLoC layer |
| 🟢 Low | Audit 3 font family, hapus yang tidak dipakai |
| 🟢 Low | Rapikan file `.txt` dan `.md` yang ada di root ke `docs/` |
