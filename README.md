# Komtim Partner

<p align="center">
  <img src="assets/images/logo.png" alt="Komtim Partner Logo" width="120"/>
</p>

> **Aplikasi mobile untuk partner/mitra Komtim dalam mengelola talent, invoice, pembayaran, dan aktivitas bisnis lainnya.**

[![Flutter](https://img.shields.io/badge/Flutter-3.6.1-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6.1-blue.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-1.2.6-orange.svg)](./CHANGELOG.md)

---

## 📱 Tentang Aplikasi

**Komtim Partner** adalah aplikasi mobile yang dirancang khusus untuk partner/mitra Komtim. Aplikasi ini menyediakan berbagai fitur untuk memudahkan pengelolaan bisnis sehari-hari, mulai dari manajemen talent hingga pembayaran dan invoice.

### 🎯 Tujuan Utama
- Mengelola talent pool dan rekomendasi talent
- Mengelola invoice dan pembayaran
- Melakukan top-up dan withdrawal saldo Kompay
- Memonitor performa dan kehadiran talent
- Memberikan rating dan evaluasi talent
- Mengelola shopping list dan belanja

---

## ✨ Fitur-Fitur Utama

### 🔐 Autentikasi
| Fitur | Deskripsi |
|-------|-----------|
| Login | Masuk dengan username dan password |
| Lupa Password | Reset password melalui email |
| Ubah Password | Mengubah password akun |

### 🏠 Beranda & Navigasi
| Fitur | Deskripsi |
|-------|-----------|
| Dashboard | Menampilkan saldo, talent pool, dan feed terbaru |
| Riwayat Transaksi | Melihat riwayat invoice, saldo, penarikan, dan top-up |
| Profil | Mengelola informasi profil pengguna |

### 💳 Invoice & Pembayaran
| Fitur | Deskripsi |
|-------|-----------|
| Daftar Invoice | Melihat semua invoice yang ada |
| Ringkasan Invoice | Detail ringkasan setiap invoice |
| Metode Pembayaran | Memilih berbagai metode pembayaran |
| Konfirmasi Pembayaran | Konfirmasi setelah pembayaran berhasil |

### 💰 Kompay Wallet
| Fitur | Deskripsi |
|-------|-----------|
| Top Up Saldo | Mengisi saldo Kompay |
| Pembayaran QRIS | Pembayaran cepat via QRIS |
| Transfer Bank | Pembayaran via transfer bank |
| Withdrawal | Menarik saldo ke rekening bank |

### 📋 Manajemen Absensi
| Fitur | Deskripsi |
|-------|-----------|
| Daftar Absensi | Melihat daftar absensi talent |
| Detail Absensi | Melihat detail per absensi |
| Absensi Gagal | Mengelola absensi yang gagal |
| Laporan Ketidakhadiran | Report talent yang tidak hadir |

### 🛒 Shopping Management
| Fitur | Deskripsi |
|-------|-----------|
| Shopping List | Mengelola daftar belanja |
| Detail Shopping | Melihat detail item belanja |
| Filter & Search | Filter berdasarkan status dan tanggal |

### 📊 Laporan Performa
| Fitur | Deskripsi |
|-------|-----------|
| Performa Keseluruhan | Melihat laporan performa secara umum |
| Detail Bulanan | Melihat performa per bulan |
| Laporan Mingguan | Melihat performa per minggu |

### ⭐ Rating Talent
| Fitur | Deskripsi |
|-------|-----------|
| Notifikasi Rating | Menerima notifikasi untuk memberikan rating |
| Form Rating | Mengisi form rating untuk talent |
| Evaluasi Kompoint | Memberikan evaluasi dan Kompoint |

### 👤 Unhire Talent
| Fitur | Deskripsi |
|-------|-----------|
| Halaman Unhire | Proses unhire talent |
| Input Alasan | Memberikan alasan unhire |
| Konfirmasi | Konfirmasi proses unhire selesai |

### 🔒 Manajemen PIN
| Fitur | Deskripsi |
|-------|-----------|
| Buat PIN | Membuat PIN baru |
| Verifikasi PIN | Verifikasi PIN untuk transaksi |
| Update PIN | Mengubah PIN yang sudah ada |
| Verifikasi Email | OTP verification via email |

### 📰 News Feed
| Fitur | Deskripsi |
|-------|-----------|
| Daftar Berita | Melihat berita dan informasi terbaru |
| Detail Berita | Membaca detail berita |

### 🔔 Notifikasi
| Fitur | Deskripsi |
|-------|-----------|
| Push Notification | Menerima notifikasi real-time |
| Daftar Notifikasi | Melihat semua notifikasi |

---

## 🛠️ Teknologi yang Digunakan

### Core Framework
- **Flutter SDK** ^3.6.1
- **Dart** Compatible with SDK 3.6.1

### State Management
- **flutter_bloc** ^8.0.1 - BLoC pattern untuk state management

### Navigation
- **go_router** ^9.0.0 - Declarative routing

### Dependency Injection
- **get_it** ^7.6.0 - Service locator

### Firebase
- **firebase_core** ^2.17.0
- **firebase_messaging** ^14.2.0 - Push notifications
- **firebase_analytics** ^10.6.0
- **firebase_remote_config** ^4.3.14

### Storage & Security
- **shared_preferences** ^2.2.0
- **flutter_secure_storage** ^8.0.0
- **dart_jsonwebtoken** ^2.2.0

---

## 🏗️ Arsitektur

Aplikasi ini menggunakan **Clean Architecture** dengan layer yang terpisah:

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                │
│     (Features: Views, Widgets, BLoC)        │
├─────────────────────────────────────────────┤
│             DOMAIN LAYER                    │
│   (Entities, Repositories, Use Cases)       │
├─────────────────────────────────────────────┤
│              DATA LAYER                     │
│ (Models, Remote DataSources, Repository)    │
├─────────────────────────────────────────────┤
│          EXTERNAL SERVICES                  │
│ (Firebase, HTTP API, Shared Preferences)    │
└─────────────────────────────────────────────┘
```

---

## 📁 Struktur Project

```
lib/
├── DI/                     # Dependency Injection
├── common/                 # Constants, styles, utilities
│   ├── global/             # Global pages, widgets, router
│   └── utils/              # Utility functions
├── config/                 # Environment configurations
├── core/
│   ├── data/               # Models, DataSources, Repository Impl
│   └── domain/             # Entities, Repository Interface, Use Cases
└── features/               # Feature modules
    ├── auth/               # Authentication
    ├── home/               # Home & Navigation
    ├── invoice/            # Invoice Management
    ├── kompay/             # Kompay Wallet
    ├── attendance/         # Attendance Tracking
    ├── shopping/           # Shopping Management
    ├── performance/        # Performance Reports
    ├── ratetalent/         # Talent Rating
    ├── unhire/             # Talent Unhiring
    ├── pin/                # PIN Management
    ├── profile/            # User Profile
    ├── feed/               # News Feed
    ├── notifications/      # Notifications
    └── update/             # App Update
```

---

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK ^3.6.1
- Android Studio / VS Code
- Emulator atau device fisik

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/your-repo/komtim_partner.git
   cd komtim_partner
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   # Development
   flutter run --flavor dev --dart-define=FLAVOR=dev

   # Staging
   flutter run --flavor staging --dart-define=FLAVOR=staging

   # Production
   flutter run --flavor production --dart-define=FLAVOR=production
   ```

### Build APK

```bash
# Development
flutter build apk --flavor dev --dart-define=FLAVOR=dev

# Staging
flutter build apk --flavor staging --dart-define=FLAVOR=staging

# Production
flutter build apk --flavor production --dart-define=FLAVOR=production

# App Bundle (Production)
flutter build appbundle --flavor production --dart-define=FLAVOR=production
```

---

## 🖼️ Mengganti App Icon

App icon dikelola menggunakan package [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) yang secara otomatis men-generate semua ukuran icon untuk **Android** dan **iOS** dari satu file sumber.

### File Sumber Icon

| File | Keterangan |
|------|------------|
| `assets/images/superapp/home/ic_komerce_os.svg` | File SVG original logo |
| `assets/images/superapp/home/ic_komerce_os_1024.png` | File PNG 1024×1024 (sumber untuk generator) |

### Konfigurasi (`pubspec.yaml`)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/superapp/home/ic_komerce_os_1024.png"
  min_sdk_android: 21
  remove_alpha_ios: true
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/superapp/home/ic_komerce_os_1024.png"
```

### Langkah-Langkah Mengganti Icon

**1. Siapkan file PNG baru (1024×1024 px)**

Jika icon bersumber dari SVG, convert dulu ke PNG menggunakan Node.js:
```bash
# Install sharp (hanya perlu sekali)
npm install --save-dev sharp

# Jalankan script convert (file: convert_icon.mjs)
node convert_icon.mjs
```

> Atau bisa langsung menyediakan PNG 1024×1024 dari Figma/desainer dan simpan di path yang sama.

**2. Update `image_path` di `pubspec.yaml`** (jika nama file berubah)

```yaml
flutter_launcher_icons:
  image_path: "assets/images/superapp/home/NAMA_FILE_BARU.png"
  adaptive_icon_foreground: "assets/images/superapp/home/NAMA_FILE_BARU.png"
```

**3. Jalankan generator**

```bash
dart run flutter_launcher_icons
```

Output sukses:
```
✓ Successfully generated launcher icons
```

**4. Rebuild aplikasi**

```bash
# Development
flutter run --flavor dev --dart-define=FLAVOR=dev
```

### Catatan Penting

| | Keterangan |
|---|---|
| `min_sdk_android: 21` | Sesuai `minSdkVersion` project (Android 5.0+). Device API 21–25 pakai PNG biasa, API 26+ pakai Adaptive Icon |
| `remove_alpha_ios: true` | Wajib agar icon tidak ditolak saat submit ke App Store |
| `adaptive_icon_background` | Warna background adaptive icon Android (hex color) |
| Icon iOS | Otomatis di-generate ke `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (16 ukuran) |
| Icon Android | Otomatis di-generate ke `android/app/src/main/res/mipmap-*/` |

---

## 🧪 Testing (Unit Test)

Project ini memiliki arsitektur 3-layer. Terdapat skenario unit/widget testing untuk meng-cover logika API, lokal / preferensi, hingga ke BLoC (State Management).

### Mocking Library
Project ini menggunakan `mocktail` untuk unit test. Seluruh mock class didaftarkan secara terpusat di `test/helpers/mocks/` sehingga tidak memerlukan proses code-generation (`build_runner`) untuk membuat file mock baru.

### Menjalankan Test
Berikut adalah command yang bisa digunakan untuk mem-validasi test:

**1. Menjalankan Semua Test Sekaligus**
```bash
fvm flutter test
```
*(Catatan: Jika semua pass, Flutter secara default akan merahasiakan nama test untuk menghemat log.)*

**2. Menjalankan Semua Test (Verbose Mode)**
Jika ingin melihat detail list tiap *test suite* yang sukses:
```bash
fvm flutter test -r expanded
```

**3. Menjalankan Test Per File/Folder**
Cukup cantumkan path spesifik untuk hanya mengeksekusi test tertentu:
```bash
fvm flutter test test/core/data/datasources/remote/auth_remote_datasource_test.dart
# atau
fvm flutter test test/features/auth/
```

**✅ Menjalankan Test via IDE (VS Code / Android Studio)**
- **VS Code**: Manfaatkan panel "Testing" (ikon tabung lab) pada sidebar untuk memutar test satu per satu secara visual (centang hijau).
- Atau **klik "Run" / "Debug"** langsung di atas method `void main() { ... }` pada masing-masing file `*_test.dart`.

---

## 📚 Dokumentasi

Untuk dokumentasi teknis lebih lengkap, silakan lihat:

- [Technical Requirements Document (TRD)](./docs/TRD.md)
- [Authentication Flow](./docs/flows/auth_flow.md)
- [Home Flow](./docs/flows/home_flow.md)
- [Invoice Flow](./docs/flows/invoice_flow.md)
- [Kompay Flow](./docs/flows/kompay_flow.md)
- [Attendance Flow](./docs/flows/attendance_flow.md)
- [Shopping Flow](./docs/flows/shopping_flow.md)
- [Performance Flow](./docs/flows/performance_flow.md)
- [Rate Talent Flow](./docs/flows/ratetalent_flow.md)
- [Unhire Flow](./docs/flows/unhire_flow.md)
- [PIN Flow](./docs/flows/pin_flow.md)

---

## 📄 License

Copyright © 2026 Komtim. All rights reserved.

---

<p align="center">
  Made with ❤️ using Flutter
</p>