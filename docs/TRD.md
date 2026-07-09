# Technical Requirements Document (TRD)
# Komtim Partner

> **Versi Aplikasi:** 1.2.6  
> **Tanggal Dokumen:** 20 Januari 2026  
> **Platform:** Android & iOS

---

## Daftar Isi

1. [Ringkasan Proyek](#1-ringkasan-proyek)
2. [Spesifikasi Teknis](#2-spesifikasi-teknis)
3. [Arsitektur Aplikasi](#3-arsitektur-aplikasi)
4. [State Management](#4-state-management)
5. [Struktur Folder](#5-struktur-folder)
6. [Fitur-Fitur Aplikasi](#6-fitur-fitur-aplikasi)
7. [Flow Diagram](#7-flow-diagram)
8. [Dependency & Package](#8-dependency--package)
9. [Konfigurasi Build](#9-konfigurasi-build)
10. [API Integration](#10-api-integration)

---

## 1. Ringkasan Proyek

**Komtim Partner** adalah aplikasi mobile untuk partner/mitra Komtim yang memungkinkan mereka mengelola talent, invoice, pembayaran, dan berbagai aktivitas bisnis lainnya. Aplikasi ini dibangun menggunakan Flutter dan mendukung platform Android dan iOS.

### Tujuan Aplikasi
- Mengelola talent pool dan rekomendasi talent
- Mengelola invoice dan pembayaran
- Melakukan top-up dan withdrawal saldo Kompay
- Memonitor performa dan kehadiran talent
- Memberikan rating dan evaluasi talent
- Mengelola shopping list dan belanja

---

## 2. Spesifikasi Teknis

### Environment & SDK

| Komponen | Versi |
|----------|-------|
| Flutter SDK | ^3.6.1 |
| Dart | Compatible with SDK 3.6.1 |
| Android | Min SDK sesuai konfigurasi flavor |
| iOS | Compatible |

### Platform Target
- **Android**: Production, Staging, Development
- **iOS**: Production

---

## 3. Arsitektur Aplikasi

Aplikasi menggunakan **Clean Architecture** dengan pemisahan layer yang jelas:

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│              (Features: Views, Widgets, BLoC)                │
├─────────────────────────────────────────────────────────────┤
│                       DOMAIN LAYER                           │
│            (Entities, Repositories, Use Cases)               │
├─────────────────────────────────────────────────────────────┤
│                        DATA LAYER                            │
│      (Models, Remote DataSources, Repository Impl)           │
├─────────────────────────────────────────────────────────────┤
│                     EXTERNAL SERVICES                        │
│         (Firebase, HTTP API, Shared Preferences)             │
└─────────────────────────────────────────────────────────────┘
```

### Layer Description

#### Presentation Layer (`lib/features/`)
- **Views/Pages**: UI screens yang ditampilkan ke user
- **Widgets**: Reusable UI components
- **BLoC**: Business Logic Components untuk state management

#### Domain Layer (`lib/core/domain/`)
- **Entities**: Business objects/model domain
- **Repositories**: Abstract interface untuk data access
- **Use Cases**: Business logic yang reusable

#### Data Layer (`lib/core/data/`)
- **Models**: Data transfer objects (DTO)
- **DataSources**: Remote/Local data source implementation
- **Repository Impl**: Concrete implementation of domain repositories

---

## 4. State Management

### Flutter BLoC Pattern

Aplikasi menggunakan **flutter_bloc** package untuk state management dengan pattern:

```
┌──────────────────────────────────────────────────────┐
│                        UI                             │
│                         │                             │
│              ┌──────────▼──────────┐                 │
│              │    BlocProvider     │                 │
│              └──────────┬──────────┘                 │
│                         │                             │
│              ┌──────────▼──────────┐                 │
│              │   BlocConsumer/     │                 │
│              │   BlocBuilder       │                 │
│              └──────────┬──────────┘                 │
│                         │                             │
└─────────────────────────┼────────────────────────────┘
                          │
              ┌───────────▼───────────┐
              │         BLoC          │
              │  ┌─────┐   ┌───────┐  │
              │  │Event│──▶│ State │  │
              │  └─────┘   └───────┘  │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │      Use Cases        │
              └───────────────────────┘
```

### BLoC Files Structure
Setiap feature memiliki minimal 3 file BLoC:
- `*_bloc.dart` - Business logic handler
- `*_event.dart` - Event definitions
- `*_state.dart` - State definitions

### Request Status Enum
```dart
enum RequestStatus {
  empty,
  loading,
  success,
  failure
}
```

---

## 5. Struktur Folder

```
lib/
├── DI/
│   └── injection.dart          # Dependency Injection dengan GetIt
│
├── common/
│   ├── constants.dart          # App constants
│   ├── styles.dart             # Global styles & themes
│   ├── string.dart             # String resources
│   ├── failure.dart            # Failure handling
│   ├── exception.dart          # Custom exceptions
│   ├── global/
│   │   ├── mixin/              # Reusable mixins
│   │   ├── pages/              # Common pages
│   │   ├── router/             # GoRouter configuration
│   │   └── widgets/            # Reusable widgets
│   └── utils/                  # Utility functions
│
├── config/
│   ├── config.dart             # Abstract config
│   ├── dev.dart                # Development config
│   ├── staging.dart            # Staging config
│   └── production.dart         # Production config
│
├── core/
│   ├── data/
│   │   ├── apiservice/         # HTTP service & response parser
│   │   ├── datasources/
│   │   │   ├── preferences/    # SharedPreferences
│   │   │   └── remote/         # Remote data sources
│   │   ├── models/             # Data models
│   │   └── repositories/       # Repository implementations
│   │
│   └── domain/
│       ├── entities/           # Domain entities
│       ├── repositories/       # Repository interfaces
│       └── usecases/           # Use case implementations
│
├── features/
│   ├── auth/                   # Authentication feature
│   ├── home/                   # Home & main navigation
│   ├── invoice/                # Invoice management
│   ├── kompay/                 # Kompay wallet
│   ├── attendance/             # Attendance tracking
│   ├── shopping/               # Shopping management
│   ├── performance/            # Performance reports
│   ├── ratetalent/             # Talent rating
│   ├── unhire/                 # Talent unhiring
│   ├── pin/                    # PIN management
│   ├── profile/                # User profile
│   ├── feed/                   # News feed
│   ├── notifications/          # Push notifications
│   └── update/                 # App update handling
│
├── firebase_options.dart       # Firebase configuration
└── main.dart                   # Application entry point
```

---

## 6. Fitur-Fitur Aplikasi

### 6.1 Authentication (`features/auth/`)

| Fitur | Deskripsi |
|-------|-----------|
| Login | Login dengan username dan password |
| Forgot Password | Reset password via email |
| Change Password | Ubah password user |
| Splash Screen | Initial loading dengan version check |

**Flow Dokumentasi**: [Authentication Flow](./flows/auth_flow.md)

---

### 6.2 Home & Navigation (`features/home/`)

| Fitur | Deskripsi |
|-------|-----------|
| Home Page | Dashboard utama dengan saldo, talent pool, feed |
| History Page | Riwayat transaksi (Invoice, Saldo, Penarikan, TopUp) |
| Profile Page | Halaman profil user |
| Bottom Navigation | Navigasi utama (Beranda, Riwayat, Profile) |

**Flow Dokumentasi**: [Home Flow](./flows/home_flow.md)

---

### 6.3 Invoice Management (`features/invoice/`)

| Fitur | Deskripsi |
|-------|-----------|
| Invoice List | Daftar semua invoice |
| Invoice Report Summary | Detail ringkasan invoice |
| Payment Method | Pilih metode pembayaran |
| Success Payment | Konfirmasi pembayaran sukses |

**Flow Dokumentasi**: [Invoice Flow](./flows/invoice_flow.md)

---

### 6.4 Kompay Wallet (`features/kompay/`)

| Fitur | Deskripsi |
|-------|-----------|
| Top Up | Isi saldo Kompay |
| QRIS Payment | Pembayaran via QRIS |
| Bank Transfer | Pembayaran via transfer bank |
| Saldo Withdrawal | Tarik saldo Kompay |
| Success Withdrawal | Konfirmasi withdrawal sukses |

**Flow Dokumentasi**: [Kompay Flow](./flows/kompay_flow.md)

---

### 6.5 Attendance Tracking (`features/attendance/`)

| Fitur | Deskripsi |
|-------|-----------|
| Attendance List | Daftar absensi talent |
| Attendance Detail | Detail absensi |
| Failed Attendance | Daftar absensi gagal |
| Absence Report | Laporan ketidakhadiran |

**Flow Dokumentasi**: [Attendance Flow](./flows/attendance_flow.md)

---

### 6.6 Shopping Management (`features/shopping/`)

| Fitur | Deskripsi |
|-------|-----------|
| Shopping List | Daftar belanja/shopping |
| Detail Shopping | Detail item shopping |
| Filter & Search | Filter berdasarkan status & tanggal |

**Flow Dokumentasi**: [Shopping Flow](./flows/shopping_flow.md)

---

### 6.7 Performance Reports (`features/performance/`)

| Fitur | Deskripsi |
|-------|-----------|
| Report Performance | Laporan performa keseluruhan |
| Detail Report Monthly | Detail performa bulanan |
| Weekly Report | Laporan performa mingguan |

**Flow Dokumentasi**: [Performance Flow](./flows/performance_flow.md)

---

### 6.8 Talent Rating (`features/ratetalent/`)

| Fitur | Deskripsi |
|-------|-----------|
| Rate Talent Notification | Notifikasi untuk rating talent |
| Rate Talent Check | Form rating talent |
| Evaluation Kompoint | Evaluasi dan pemberian Kompoint |
| WebView | Halaman web untuk pembayaran Xendit |

**Flow Dokumentasi**: [Rate Talent Flow](./flows/ratetalent_flow.md)

---

### 6.9 Talent Unhire (`features/unhire/`)

| Fitur | Deskripsi |
|-------|-----------|
| Unhire Page | Halaman untuk mem-unhire talent |
| Reason Unhire | Input alasan unhire |
| Dialog Unhire Finish | Konfirmasi unhire selesai |

**Flow Dokumentasi**: [Unhire Flow](./flows/unhire_flow.md)

---

### 6.10 PIN Management (`features/pin/`)

| Fitur | Deskripsi |
|-------|-----------|
| Set PIN | Atur PIN baru |
| Verify PIN | Verifikasi PIN untuk transaksi |
| Update PIN | Update PIN yang sudah ada |
| Email Verification | Verifikasi OTP via email |

**Flow Dokumentasi**: [PIN Flow](./flows/pin_flow.md)

---

### 6.11 User Profile (`features/profile/`)

| Fitur | Deskripsi |
|-------|-----------|
| Profile Info | Informasi profil user |
| Profile Update | Update informasi profil |
| Logout | Keluar dari aplikasi |

---

### 6.12 News Feed (`features/feed/`)

| Fitur | Deskripsi |
|-------|-----------|
| Feed List | Daftar berita/informasi |
| Feed Detail | Detail berita |

---

### 6.13 Notifications (`features/notifications/`)

| Fitur | Deskripsi |
|-------|-----------|
| Notification List | Daftar notifikasi |
| Push Notification | FCM push notification handling |

---

### 6.14 App Update (`features/update/`)

| Fitur | Deskripsi |
|-------|-----------|
| Force Update | Paksa update untuk major version |
| Update Status | Status update progress |

---

## 7. Flow Diagram

Dokumentasi flow diagram tersedia dalam file terpisah:

| Flow | File | Deskripsi |
|------|------|-----------|
| Auth Flow | [auth_flow.md](./flows/auth_flow.md) | Alur autentikasi |
| Home Flow | [home_flow.md](./flows/home_flow.md) | Alur navigasi utama |
| Invoice Flow | [flows/invoice_flow.md](./flows/invoice_flow.md) | Alur invoice & pembayaran |
| Kompay Flow | [flows/kompay_flow.md](./flows/kompay_flow.md) | Alur wallet Kompay |
| Attendance Flow | [flows/attendance_flow.md](./flows/attendance_flow.md) | Alur absensi |
| Shopping Flow | [flows/shopping_flow.md](./flows/shopping_flow.md) | Alur shopping |
| Performance Flow | [flows/performance_flow.md](./flows/performance_flow.md) | Alur laporan performa |
| Rate Talent Flow | [flows/ratetalent_flow.md](./flows/ratetalent_flow.md) | Alur rating talent |
| Unhire Flow | [flows/unhire_flow.md](./flows/unhire_flow.md) | Alur unhire talent |
| PIN Flow | [flows/pin_flow.md](./flows/pin_flow.md) | Alur PIN management |

---

## 8. Dependency & Package

### Core Dependencies

| Package | Versi | Fungsi |
|---------|-------|--------|
| flutter_bloc | ^8.0.1 | State management |
| go_router | ^9.0.0 | Navigation/Routing |
| get_it | ^7.6.0 | Dependency Injection |
| dartz | ^0.10.1 | Functional programming |
| equatable | ^2.0.5 | Value equality |
| http | ^1.0.0 | HTTP client |

### Firebase

| Package | Versi | Fungsi |
|---------|-------|--------|
| firebase_core | ^2.17.0 | Firebase core |
| firebase_messaging | ^14.2.0 | Push notifications |
| firebase_analytics | ^10.6.0 | Analytics |
| firebase_remote_config | ^4.3.14 | Remote configuration |

### UI & UX

| Package | Versi | Fungsi |
|---------|-------|--------|
| google_fonts | ^5.0.0 | Typography |
| flutter_svg | ^2.0.9 | SVG support |
| cached_network_image | ^3.3.0 | Image caching |
| shimmer | ^3.0.0 | Loading placeholder |
| lottie | ^2.6.0 | Animations |
| qr_flutter | ^4.1.0 | QR code generator |

### Storage & Security

| Package | Versi | Fungsi |
|---------|-------|--------|
| shared_preferences | ^2.2.0 | Local storage |
| flutter_secure_storage | ^8.0.0 | Secure storage |
| dart_jsonwebtoken | ^2.2.0 | JWT handling |

### Utilities

| Package | Versi | Fungsi |
|---------|-------|--------|
| intl | ^0.20.2 | Internationalization |
| url_launcher | ^6.1.12 | URL launcher |
| connectivity_plus | ^4.0.1 | Network connectivity |
| device_info_plus | ^9.1.0 | Device info |
| package_info_plus | ^4.2.0 | Package info |
| webview_flutter | ^4.0.1 | WebView |
| permission_handler | ^12.0.1 | Permission handling |

---

## 9. Konfigurasi Build

### Flavor Configuration

Aplikasi mendukung 3 environment:

```dart
// lib/config/config.dart
abstract class Config {
  String get baseUrl;
  String get baseUrlInternal;
  String get baseUrlTalentPool;
  String get baseUrlWebUrlTalentPool;
}
```

### Build Commands

```bash
# Development
flutter run --flavor dev --dart-define=FLAVOR=dev
flutter build apk --flavor dev --dart-define=FLAVOR=dev

# Staging
flutter run --flavor staging --dart-define=FLAVOR=staging
flutter build apk --flavor staging --dart-define=FLAVOR=staging

# Production
flutter run --flavor production --dart-define=FLAVOR=production
flutter build apk --flavor production --dart-define=FLAVOR=production

# App Bundle (Production)
flutter build appbundle --flavor production --dart-define=FLAVOR=production
```

### Font Configuration

Aplikasi menggunakan custom fonts:
- **PlusJakartaSans** (Primary font)
- **Poppins**
- **Inter**

---

## 10. API Integration

### Remote Data Sources

| Data Source | File | Endpoint |
|-------------|------|----------|
| Auth | `auth_remote_datasource.dart` | Login, Register, Token |
| Invoice | `invoice_remote_datasource.dart` | Invoice CRUD |
| Kompay | `kompay_remote_datasource.dart` | Wallet operations |
| TopUp | `topup_remote_datasource.dart` | Top up saldo |
| Attendance | `attendance_remote_datasource.dart` | Attendance data |
| Shopping | `shopping_remote_datasource.dart` | Shopping operations |
| Profile | `profile_remote_datasource.dart` | Profile data |
| PIN | `pin_remote_datasource.dart` | PIN operations |
| Feed | `feed_remote_datasource.dart` | Feed/News |
| Talent | `talent_remote_datasource.dart` | Talent management |
| Performance | `report_performance_datasource.dart` | Performance reports |
| Transaction | `transaction_history_remote_datasource.dart` | Transaction history |
| Kompoin | `kompoin_remote_datasource.dart` | Kompoin/points |

### HTTP Service

Aplikasi menggunakan HTTP service wrapper dengan response parser untuk standardisasi API response handling.

```dart
// lib/core/data/apiservice/
├── http_service.dart       # HTTP client wrapper
└── response_parser.dart    # Response parsing utility
```

---

## Appendix

### A. Routing Configuration

Semua route didefinisikan di `lib/common/global/router/`:
- `app_router.dart` - GoRouter configuration
- `router_utils.dart` - Route enum & extensions

### B. Dependency Injection

Semua dependency diregister di `lib/DI/injection.dart` menggunakan GetIt service locator.

### C. Error Handling

Error handling menggunakan:
- `Failure` class untuk standar error
- `Exception` class untuk custom exceptions
- `ErrorHandlingMixin` untuk UI error display

---

*Dokumen ini dibuat secara otomatis berdasarkan analisis kode sumber aplikasi Komtim Partner.*
