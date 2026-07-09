---
description: Menjalankan app Flutter komtim_partner di device atau emulator
---

# Run Dev — komtim_partner

Project ini menggunakan **FVM** (Flutter Version Manager) dengan Flutter `3.35.5` dan mendukung 3 flavor: `dev`, `staging`, `production`.

## 1. Pastikan FVM terinstall dan Flutter version sesuai

```bash
fvm use
```

## 2. Cek device yang tersedia

```bash
fvm flutter devices
```

## 3. Install dependencies

```bash
fvm flutter pub get
```

## 4. Jalankan app sesuai flavor

### Dev (default untuk development):
```bash
fvm flutter run --flavor dev --dart-define=FLAVOR=dev
```

### Staging:
```bash
fvm flutter run --flavor staging --dart-define=FLAVOR=staging
```

### Production:
```bash
fvm flutter run --flavor production --dart-define=FLAVOR=production
```

## 5. Jalankan di device/emulator spesifik

Gunakan flag `-d` dengan device ID dari langkah 2:
```bash
fvm flutter run --flavor dev --dart-define=FLAVOR=dev -d <device_id>
```

## Tips
- Gunakan `--debug` (default) untuk hot reload
- Gunakan `--profile` untuk cek performa
- Gunakan `--release` untuk build seperti production tapi masih bisa di-test lokal
