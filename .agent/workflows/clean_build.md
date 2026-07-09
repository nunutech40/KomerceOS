---
description: Membersihkan build artifacts Flutter dan iOS (Pods, build folder, cache)
---

# Clean Build — komtim_partner

Gunakan workflow ini ketika terjadi build error yang aneh, perubahan dependency, atau ingin fresh start.

## Flutter Clean (wajib)

// turbo
1. Jalankan flutter clean:
```bash
fvm flutter clean
```

// turbo
2. Hapus cache pub:
```bash
fvm flutter pub cache repair
```

// turbo
3. Install ulang dependencies:
```bash
fvm flutter pub get
```

## iOS Clean (jika ada masalah di iOS)

// turbo
4. Masuk ke folder ios dan hapus Pods:
```bash
cd ios && rm -rf Pods Podfile.lock && cd ..
```

5. Install ulang Pods:
```bash
cd ios && pod install && cd ..
```

> **Tips**: Jika `pod install` hang, pastikan CDN source sudah dipakai di `Podfile`:
> ```ruby
> source 'https://cdn.cocoapods.org/'
> ```

## Android Clean (jika ada masalah di Android)

// turbo
6. Clean gradle:
```bash
cd android && ./gradlew clean && cd ..
```

## Full Clean (nuclear option)

// turbo
7. Hapus semua build artifacts sekaligus:
```bash
fvm flutter clean && rm -rf ios/Pods ios/Podfile.lock && fvm flutter pub get
```

Lalu lanjutkan dengan `pod install` di folder `ios/`.
