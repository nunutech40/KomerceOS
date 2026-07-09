---
name: unit-test-datasource-remote
description: Panduan unit test untuk Remote DataSource (API via DioClient + DioResponseParser). Mock HTTP layer.
---

# Skill: Unit Test — Remote DataSource

## Aturan Folder
**Test file HARUS mirror folder lib:**
```
lib/core/data/datasources/remote/xyz_remote_datasource.dart
 → test/core/data/datasources/remote/xyz_remote_datasource_test.dart
```

## Filosofi
Remote DataSource bertugas **dua hal saja**:
1. Memanggil `DioClient` dengan endpoint dan body yang benar
2. Meneruskan raw `Response` ke `DioResponseParser` untuk diparse jadi Model

Ia **tidak tahu** tentang Failure/Either/domain. Gagal → throw Exception, bukan return Left.

---

## Tiga Path Wajib (per method)

| Path | Skenario | Ekspektasi |
|---|---|---|
| **Happy Path** | `parseResponse` return model valid | Return model + field spesifik dicek |
| **Error Path** | `parseResponse` throw Exception / `DioClient` throw DioException | Exception naik (re-throw), tidak ditelan |
| **Edge Path** | Response di luar dugaan (parsing mismatch, null data) | Throw error yang tepat |

---

## Aturan Kualitas

### ❌ Jangan lakukan ini
```dart
// BURUK — body tidak diverifikasi, dead variable
final tBody = {'username': tUser};
verify(mockClient.post(Endpoints.login, data: anyNamed('data'))); // ← body tidak dicek!
```

### ✅ Lakukan ini
```dart
// BAIK — verifikasi exact body yang dikirim ke server
final tBody = {'username': tUser, 'password': tPass, 'fcm_token': tFcm};
verify(mockClient.post(Endpoints.login, data: tBody)).called(1);
```

### ❌ Jangan lakukan ini
```dart
// BURUK — terlalu generic, tidak tahu Exception apa yang melewati
expect(() => dataSource.doLogin(tUser, tPass, tFcm), throwsException);
```

### ✅ Lakukan ini
```dart
// BAIK — assert tipe Exception yang benar dan cek field jika perlu
expect(
  () => dataSource.doLogin(tUser, tPass, tFcm),
  throwsA(isA<ServerException>().having((e) => e.message, 'message', contains('error'))),
);
```

### ❌ Jangan lakukan ini
```dart
// BURUK — hanya cek objek sama via Equatable
expect(result, tLoginResponse);
```

### ✅ Lakukan ini
```dart
// BAIK — cek field untuk verifikasi data mengalir tidak berubah dari parser
expect(result.accessToken, 'access_token_abc');
expect(result.data?.username, 'john_doe');
```

> **⚠️ Catatan Filosofis — Penting:**
> Field check di layer DataSource **bukan** untuk mendeteksi bug parsing JSON.
> Bug parsing ditangkap oleh `unit-test-response`.
>
> Field check di sini hanya memverifikasi satu hal:
> **"DataSource meneruskan output parser apa adanya — tidak menambah, tidak mengubah, tidak membuang field."**
>
> Bug yang BENAR-BENAR ditangkap layer DataSource:
> - Endpoint salah → `verify(mockClient.post(Endpoints.login, ...))`
> - Key body salah → `verify(mockClient.post(..., data: tBody))`
> - Exception ditelan (try-catch tersembunyi) → Error + Edge path
>
> Jangan menambah field check berlebihan di DataSource test hanya supaya terlihat "banyak". Itu ABS.

---

## Template Lengkap

```dart
// test/core/data/datasources/remote/xyz_remote_datasource_test.dart

// =============================================================================
// PANDUAN: Remote DataSource — 3 Path per Method
// =============================================================================
// Happy Path : DioClient + parseResponse sukses → return Model + cek field
// Error Path : parseResponse throw Exception → exception naik (re-throw)
// Edge Path  : Data null / parsing mismatch → throw error tepat
//
// WAJIB: Verifikasi EXACT endpoint + EXACT body request body (bukan anyNamed)
// JANGAN: Test kode HTTP (404, 500) — itu urusan DioClient & Repository
// =============================================================================

@GenerateMocks([DioClient, DioResponseParser])
void main() {
  late XyzRemoteDataSourceImpl dataSource;
  late MockDioClient mockClient;
  late MockDioResponseParser mockParser;

  setUp(() {
    mockClient = MockDioClient();
    mockParser = MockDioResponseParser();
    dataSource = XyzRemoteDataSourceImpl(
      client: mockClient,
      responseParser: mockParser,
    );
    // Jika ada return type custom, daftarkan dummy di sini:
    // provideDummy<XyzResponse>(XyzResponse(...));
  });

  // ── Fixture ──────────────────────────────────────────────────────────────
  final tDioResponse = Response(
    requestOptions: RequestOptions(path: 'https://test.com'),
    data: {'meta': {'status': 'success', 'code': 200, 'message': 'OK'}, 'data': {}},
    statusCode: 200,
  );

  final tModel = XyzResponse(id: 1, name: 'Test');

  // ── Method: getData ───────────────────────────────────────────────────────
  group('getData', () {
    const tId = '1';
    final tQueryParams = {'id': tId};

    // ----- HAPPY PATH -----
    test('return model dengan field benar saat API sukses', () async {
      when(mockClient.get(Endpoints.xyz, queryParameters: tQueryParams))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<XyzResponse>(any, any)).thenReturn(tModel);

      final result = await dataSource.getData(tId);

      // Cek field spesifik, bukan hanya objek sama
      expect(result.id, 1);
      expect(result.name, 'Test');
      // Verifikasi exact endpoint + exact params
      verify(mockClient.get(Endpoints.xyz, queryParameters: tQueryParams)).called(1);
    });

    // ----- ERROR PATH -----
    test('throw Exception saat parseResponse gagal (meta error)', () async {
      when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<XyzResponse>(any, any))
          .thenThrow(Exception('meta error'));

      expect(
        () => dataSource.getData(tId),
        throwsException,
      );
    });

    test('throw DioException saat network error (tidak ditangkap datasource)', () async {
      when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ));

      expect(() => dataSource.getData(tId), throwsA(isA<DioException>()));
    });

    // ----- EDGE PATH -----
    test('throw error saat parseResponse return null (parsing mismatch)', () async {
      // Simulasi: server berubah, 'data' jadi null → fromJson meledak
      when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<XyzResponse>(any, any))
          .thenThrow(TypeError());

      expect(() => dataSource.getData(tId), throwsA(isA<TypeError>()));
    });
  });

  // ── Method: postData (contoh POST dengan body) ────────────────────────────
  group('postData', () {
    const tParam1 = 'value1';
    const tParam2 = 'value2';
    // Definisi body di sini, gunakan di both setup DAN verify
    final tBody = {'param1': tParam1, 'param2': tParam2};

    // ----- HAPPY PATH -----
    test('return true saat API sukses dan body terkirim benar', () async {
      when(mockClient.post(Endpoints.xyzPost, data: tBody))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any)).thenReturn(true);

      final result = await dataSource.postData(tParam1, tParam2);

      expect(result, true);
      // WAJIB: verifikasi exact body yang dikirim
      verify(mockClient.post(Endpoints.xyzPost, data: tBody)).called(1);
    });

    // ----- ERROR PATH -----
    test('throw Exception saat server return meta error', () async {
      when(mockClient.post(Endpoints.xyzPost, data: tBody))
          .thenAnswer((_) async => tDioResponse);
      when(mockParser.parseResponse<bool>(any, any))
          .thenThrow(Exception('invalid request'));

      expect(() => dataSource.postData(tParam1, tParam2), throwsException);
    });
  });
}
```

---

## ✅ Checklist Kualitas

- [ ] File test mirror folder lib
- [ ] `@GenerateMocks([DioClient, DioResponseParser])`
- [ ] **Happy Path**: return model + cek **field spesifik** (bukan hanya `expect(result, tModel)`)
- [ ] **Happy Path**: `verify(mockClient.xxx(endpoint, data: tBody)).called(1)` — **exact body, bukan `anyNamed`**
- [ ] **Error Path**: Exception dari `parseResponse` naik (re-throw) — cek tipe Exception minimal
- [ ] **Error Path**: `DioException` dari `DioClient` naik (re-throw)
- [ ] **Edge Path**: Skenario parsing mismatch (null data / field hilang) → throw error tepat
- [ ] Variable fixture (`tBody`, `tQueryParams`) **dipakai di verify**, bukan dead variable
- [ ] Mock di-generate: `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] Lulus: `fvm flutter test test/core/data/datasources/remote/`

---

## ⛔ Jika Test Merah — Protokol Wajib (Termometer Bug)

> 1. Cek apakah ekspektasi / mock setup unit test-nya salah?
> 2. Tetap tulis Test se-ideal mungkin sesuai best-practice. Jangan disesuaikan (ABS) dengan kode yang buruk.
> 3. **JANGAN AUTO-REFACTOR KODE `lib/`**. 
> 4. Biarkan test-nya MERAH di terminal. Laporan Output Terminal kegagalan itu adalah Bukti (Laporan Resmi) bagi developer untuk didiskusikan! Jangan rendahkan ekspektasi `assertion` di test.
