import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/models/login_response.dart';

// =============================================================================
// PANDUAN: Data Models / Response — Defensive Parsing & Serialization
// =============================================================================
// 1. Entity map/check : toEntity() menghasilkan domain Entity yang benar
// 2. Happy Path fromJson : JSON mulus -> Model utuh
// 3. Edge Path fromJson  : API mengirim string "1" ke field Int -> sukses diparse
// 4. Edge Path fromJson  : API mengirim data bolong (missing fields) -> null-safe/default
// 5. Happy Path toJson   : Model -> Map JSON ekuivalen
// =============================================================================

void main() {
  const tUserLoginData = UserLoginData(
    id: 1,
    username: 'john_doe',
    fullName: 'John Doe',
    email: 'john@example.com',
  );

  const tLoginResponse = LoginResponse(
    accessToken: 'access_abc',
    tokenType: 'Bearer',
    data: tUserLoginData,
  );

  group('toEntity', () {
    test('toEntity UserLoginData harus mereturn domain UserLoginModel ekuivalen',
        () {
      final result = tUserLoginData.toEntity();
      expect(result.id, 1);
      expect(result.username, 'john_doe');
      expect(result.fullName, 'John Doe');
      expect(result.email, 'john@example.com');
    });

    test(
        'toEntity LoginResponse harus mereturn domain LoginModel didalamnya beserta data utuh',
        () {
      final result = tLoginResponse.toEntity();
      expect(result.accessToken, 'access_abc');
      expect(result.tokenType, 'Bearer');
      expect(result.data?.id, 1);
      expect(result.data?.username, 'john_doe');
    });
  });

  group('fromJson (UserLoginData & LoginResponse)', () {
    // ----- HAPPY PATH -----
    test(
        'harus mereturn struktur object yang utuh saat format JSON normal (Happy Path)',
        () {
      final Map<String, dynamic> jsonMap = {
        "access_token": "access_abc",
        "token_type": "Bearer",
        "data": {
          "id": 1,
          "username": "john_doe",
          "full_name": "John Doe",
          "email": "john@example.com"
        }
      };

      final result = LoginResponse.fromJson(jsonMap);

      expect(result.accessToken, 'access_abc');
      expect(result.tokenType, 'Bearer');
      expect(result.data?.username, 'john_doe');
      expect(result.data?.fullName, 'John Doe');
    });

    // ----- EDGE PATH (DEFENSIVE PARSING) -----
    test(
        'harus aman dan melempar value Int jika tiba-tiba API membalas ID dengan String "1" (Defensive Parsing Edge)',
        () {
      final Map<String, dynamic> dirtyJsonMap = {
        "id": "1", // Terjadi keteledoran di sisi backend (String instead of Int)
        "username": "john_doe",
        "full_name": "John Doe",
        "email": null
      };

      final result = UserLoginData.fromJson(dirtyJsonMap);

      // Kriteria: Model parsing wajib menyulap string jadi int sesuai prop nya!
      expect(result.id, 1);
    });

    test(
        'harus melempar empty/null aman ketika field hilang dari JSON (Missing Fields Edge)',
        () {
      final Map<String, dynamic> missingFieldsJson = {
        "id": 1,
        "username": "john_doe",
        // full_name, email ghaib
      };

      final result = UserLoginData.fromJson(missingFieldsJson);

      expect(result.id, 1);
      expect(result.fullName, isNull);
      expect(result.email, isNull);
    });
  });

  group('toJson (UserLoginData & LoginResponse)', () {
    // ----- HAPPY PATH -----
    test(
        'harus mengembalikan formasi JSON murni ekuivalen beserta nested valuenya saat di convert toJson',
        () {
      final result = tLoginResponse.toJson();

      expect(result['access_token'], 'access_abc');
      expect(result['token_type'], 'Bearer');
      final dataMap = result['data'] as Map<String, dynamic>;
      expect(dataMap['id'], 1);
      expect(dataMap['username'], 'john_doe');
      expect(dataMap['full_name'], 'John Doe');
      expect(dataMap['email'], 'john@example.com');
    });
  });
}
