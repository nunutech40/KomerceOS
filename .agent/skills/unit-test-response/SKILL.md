p---
name: unit-test-response
description: Panduan unit test untuk Data Models/Response (serialisasi JSON ↔ Dart). Buat file test yang mirror struktur folder lib.
---

# Skill: Unit Test — Data Models / Response

## Aturan Folder
**Test file HARUS mirror folder lib:**
```
lib/core/data/models/xyz_response.dart
 → test/core/data/models/xyz_response_test.dart
```

## Filosofi
Unit Test untuk Model / Response sangatlah krusial di pengembangan aplikasi Mobile, karena di sinilah **Gerbang Pertama** dimana data kotor dari Backend (JSON) menyentuh dunia ketat (Type-Safe) milik Dart/Flutter. Di project ini: `*Response` berfungsi sebagai data model.

---

## Empat Skenario Wajib (Standar Kualitas)

| Skenario | Definisi |
|---|---|
| **1. Entity / Type Check** | Memastikan Model/Response dapat memetakan field secara ekuivalen ke Entity `toEntity()` (atau jika inherit, subclass murni dari Entity). |
| **2. Happy Path (fromJson)** | Memastikan data JSON sempurna diterjemahkan ke Data Model. |
| **3. Edge Path (Defensive Parsing)** | Uji ketangguhan! API sering plin-plan (id format string `"12"`, field bolong/null). Pastikan converter bisa menyulapnya ke tipe kuat atau melempar default value yang aman tanpa crash. |
| **4. Happy Path (toJson)** | Memastikan Model/Response bisa di-pack ulang jadi JSON murni (biasa dipakai jika dilempar ke Local Storage). |

---

## Template Lengkap

```dart
// test/core/data/models/xyz_response_test.dart

// =============================================================================
// PANDUAN: Data Models / Response — Defensive Parsing & Serialization
// =============================================================================
// 1. Entity map/check : toEntity() menghasilkan domain Entity yang benar
// 2. Happy Path fromJson : JSON mulus → Model utuh
// 3. Edge Path fromJson  : API mengirim string "1" ke field Int → sukses diparse
// 4. Edge Path fromJson  : API mengirim data bolong (missing fields) → selamat, null-safe/default
// 5. Happy Path toJson   : Model → Map JSON ekuivalen
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

void main() {
  final tXyzResponse = XyzResponse(
    id: 1,
    name: 'Nunu Nugraha',
    email: 'nunu@mail.com',
    createdAt: DateTime.parse('2026-04-01T12:00:00.000Z'),
  );

  test('toEntity: harus mereturn domain Entity yang tepat dengan value ekuivalen', () {
    // Act
    final result = tXyzResponse.toEntity();

    // Assert
    expect(result.id, 1);
    expect(result.name, 'Nunu Nugraha');
  });
  
  // Kalau modelnya merupakan extend dari Entity (misal UserModel extends UserEntity)
  // test('harus merupakan subclass murni dari User Entity', () {
  //   expect(tXyzResponse, isA<UserEntity>());
  // });

  group('fromJson', () {
    // ----- HAPPY PATH -----
    test('harus mereturn struktur Model yang utuh saat format JSON normal (Happy Path)', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'Nunu Nugraha',
        'email': 'nunu@mail.com',
        'created_at': '2026-04-01T12:00:00.000Z',
      };

      // Act
      final result = XyzResponse.fromJson(jsonMap);

      // Assert
      expect(result, tXyzResponse);
    });

    // ----- EDGE PATH (DEFENSIVE PARSING) -----
    test('harus tetap selamat jika tipe data ID dikirim sebagai String bukan Integer (Edge Path - Tipe Kotor)', () {
      // API diam-diam error format mengirim tipe String "1"
      final Map<String, dynamic> jsonMapStringId = {
        'id': '1', 
        'name': 'Nunu Nugraha',
        'email': 'nunu@mail.com',
        'created_at': '2026-04-01T12:00:00.000Z',
      };

      final result = XyzResponse.fromJson(jsonMapStringId);

      // Pastikan custom parser/converter (jika ada) menyulap String "1" menjadi Int 1
      expect(result.id, 1);
    });

    test('harus melempar empty/default value jika data JSON terpotong (Missing Fields) (Edge Path)', () {
      // API mengirim data bolong (Tidak ada nama/email/created_at)
      final Map<String, dynamic> jsonMapMissing = {
        'id': 1,
      };

      final result = XyzResponse.fromJson(jsonMapMissing);

      // Defensive Parsing menjaganya agar null-safe / default value!
      expect(result.id, 1);
      expect(result.name, isEmpty); // Jika default string kosong
      expect(result.email, isNull); // Sesuai kesepakatan field
    });
  });

  group('toJson', () {
    // ----- HAPPY PATH -----
    test('harus mengembalikan Map JSON murni yang ekuivalen dengan Model (Happy Path)', () {
      // Act
      final result = tXyzResponse.toJson();

      // Assert
      final expectedMap = {
        'id': 1,
        'name': 'Nunu Nugraha',
        'email': 'nunu@mail.com',
        'created_at': '2026-04-01T12:00:00.000Z',
      };
      
      expect(result, expectedMap);
    });
  });
}
```

> **Catatan:** Test respon/data model **tidak butuh mock** dan **tidak butuh `build_runner`** — murni unit test instan.

---

## ✅ Checklist Kualitas

- [ ] File test di `test/core/data/models/<nama>_response_test.dart` (mirror lib)
- [ ] Test `toEntity` (atau subclass check) : Cek mapping field ke ranah domain.
- [ ] Test `fromJson` Happy Path : Mapping sempurna.
- [ ] Test `fromJson` Edge Path (Sangat Penting!) : Tipe kotor (String "12" to Int), missing field, null safe tanpa crash.
- [ ] Test `toJson` Happy Path : Map ekuivalen format JSON asli.
- [ ] Lulus test: `fvm flutter test test/core/data/models/`

---

## ⛔ Jika Test Merah — Protokol Wajib (Termometer Bug)

> 1. Cek apakah ekspektasi / mock setup unit test-nya salah?
> 2. Tetap tulis Test se-ideal mungkin sesuai best-practice. Jangan disesuaikan (ABS) dengan kode yang buruk.
> 3. **JANGAN AUTO-REFACTOR KODE `lib/`**. 
> 4. Biarkan test-nya MERAH di terminal. Laporan Output Terminal kegagalan itu adalah Bukti (Laporan Resmi) bagi developer untuk didiskusikan! Jangan rendahkan ekspektasi `assertion` di test.
