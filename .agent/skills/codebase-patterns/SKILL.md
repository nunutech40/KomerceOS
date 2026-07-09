---
name: codebase-patterns
description: Referensi pattern kode aktual di project ini — Model vs Response, DataSource, Repository, UseCase, BLoC, DI, dan semua helpers yang tersedia.
---

# Skill: Codebase Patterns — komtim_partner

Skill ini adalah **peta lengkap** pattern dan helper yang ada di codebase.
Baca skill ini sebelum bikin file baru agar konsisten dengan yang sudah ada.

---

## 1. Entity (Model) vs Response

**Aturan naming project ini sedikit unik:**
- **Entity** → file dinamai `*_model.dart`, ada di `lib/core/domain/entities/`
- **Data model (JSON)** → file dinamai `*_response.dart`, ada di `lib/core/data/models/`

### Entity (Domain Layer) — `lib/core/domain/entities/`

```dart
// lib/core/domain/entities/xyz_model.dart
import 'package:equatable/equatable.dart';

class XyzModel extends Equatable {
  final int? id;
  final String? name;
  // ...field lain dengan tipe Dart murni

  const XyzModel({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
```

**Ciri khas:**
- Extends `Equatable` (wajib)
- Field pakai tipe Dart murni (`int?`, `String?`)
- **Tidak ada** `fromJson` / `toJson`
- **Tidak import** library data layer

### Response (Data Layer) — `lib/core/data/models/`

```dart
// lib/core/data/models/xyz_response.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/xyz_model.dart';

class XyzResponse extends Equatable {
  final int? id;
  final String? name;
  // ...field sesuai JSON API

  const XyzResponse({required this.id, required this.name});

  // Parse dari JSON
  factory XyzResponse.fromJson(Map<String, dynamic> json) {
    return XyzResponse(
      id: json['id'],
      name: json['name'],
    );
  }

  // Pack ke JSON (untuk cache ke SharedPref)
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };

  // ⭐ Konversi ke Entity
  XyzModel toEntity() {
    return XyzModel(id: id, name: name);
  }

  @override
  List<Object?> get props => [id, name];
}
```

**Ciri khas:**
- Extends `Equatable`
- Punya `fromJson()`, `toJson()`, `toEntity()`
- JSON key pakai **snake_case** (`json['full_name']`)
- Dart field pakai **camelCase** (`fullName`)

### Response Wrapper (Meta) — `lib/core/data/models/meta_response.dart`

API selalu mengembalikan wrapper: `{ "meta": {...}, "data": {...} }`

```dart
class MetaResponse extends Equatable {
  final String? message;
  final int? code;
  final String? status;  // "success" atau lainnya
}
```

`DioResponseParser` sudah handle pengecekan `meta.status == 'success'`.

---

## 2. Remote DataSource — `lib/core/data/datasources/remote/`

```dart
// Abstract
abstract class XyzRemoteDataSource {
  Future<XyzResponse> getData(String id);
  Future<List<XyzResponse>> getList({int? page});
}

// Impl
class XyzRemoteDataSourceImpl implements XyzRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  XyzRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<XyzResponse> getData(String id) async {
    final response = await client.get(
      '${Endpoints.xyz}/$id',
    );
    return responseParser.parseResponse<XyzResponse>(
      response,
      (json) => XyzResponse.fromJson(json),
    );
  }

  // Untuk list response
  @override
  Future<List<XyzResponse>> getList({int? page}) async {
    final response = await client.get(
      Endpoints.xyz,
      queryParameters: {'page': page},
    );
    return responseParser.parseListResponse<XyzResponse>(
      response,
      (json) => XyzResponse.fromJson(json),
    );
  }
}
```

**Pattern wajib:**
- Selalu inject `DioClient` + `DioResponseParser`
- Endpoint ambil dari `constat_endpoint.dart` (bukan hardcode string)
- Return **Response** object, bukan Entity

---

## 3. Repository — `lib/core/data/repositories/`

```dart
class XyzRepositoryImpl extends BaseRepository implements XyzRepository {
  final XyzRemoteDataSource remoteDataSource;
  final SharedPref? sharedPref;  // opsional, jika ada cache

  XyzRepositoryImpl({required this.remoteDataSource, this.sharedPref});

  @override
  Future<Either<Failure, XyzModel>> getData(String id) async {
    return executeEither<XyzModel>(() async {
      final response = await remoteDataSource.getData(id);
      return response.toEntity();  // ← konversi di sini
    });
  }
}
```

**Pattern wajib:**
- `extends BaseRepository` — jangan handle error manual
- Gunakan `executeEither<T>()` — otomatis konversi Exception → Failure
- Konversi `.toEntity()` di sini, bukan di layer lain
- Return `Either<Failure, Entity>` selalu

---

## 4. UseCase — `lib/core/domain/usecases/`

```dart
class GetXyzUseCase {
  final XyzRepository repository;
  GetXyzUseCase(this.repository);

  Future<Either<Failure, XyzModel>> call(String id) {
    return repository.getData(id);
  }
}
```

**Pattern:**
- Constructor inject Repository interface (bukan impl)
- Biasanya `call()` method — forward ke repo
- UseCase kompleks boleh chain ke useCase lain (contoh: `DoLoginUseCase` → `GetProfileUseCase`)

---

## 5. BLoC — `lib/features/<fitur>/bloc/`

### Event (pakai `part of`)

```dart
part of 'xyz_bloc.dart';

@immutable
abstract class XyzEvent extends Equatable {
  const XyzEvent();
  @override
  List<Object?> get props => [];
}

class FetchXyzEvent extends XyzEvent {
  final String id;
  const FetchXyzEvent(this.id);
  @override
  List<Object?> get props => [id];
}
```

### State (pakai `part of`)

```dart
part of 'xyz_bloc.dart';

@immutable
abstract class XyzState extends Equatable {
  const XyzState();
  @override
  List<Object?> get props => [];
}

class XyzInitial extends XyzState {}
class XyzLoading extends XyzState {}
class XyzLoaded extends XyzState {
  final XyzModel data;
  const XyzLoaded(this.data);
  @override
  List<Object?> get props => [data];
}
class XyzError extends XyzState {
  final String message;
  const XyzError(this.message);
  @override
  List<Object?> get props => [message];
}
```

### Bloc

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'xyz_event.dart';
part 'xyz_state.dart';

class XyzBloc extends Bloc<XyzEvent, XyzState> {
  final GetXyzUseCase getXyzUseCase;

  XyzBloc({required this.getXyzUseCase}) : super(XyzInitial()) {
    on<FetchXyzEvent>(_onFetch);
  }

  void _onFetch(FetchXyzEvent event, Emitter<XyzState> emit) async {
    emit(XyzLoading());
    final result = await getXyzUseCase.call(event.id);
    result.fold(
      (failure) => emit(XyzError(failure.message)),
      (data) => emit(XyzLoaded(data)),
    );
  }
}
```

**Pattern:**
- Event & State pakai `part of` (bukan file terpisah tanpa part)
- BLoC inject UseCase (bukan Repository)
- `result.fold()` untuk handle Left/Right
- State `extends Equatable`

---

## 6. DI — `lib/DI/injection.dart`

Urutan registrasi di file ini:

```
1. BLoC          → registerFactory (baru tiap dipanggil)
2. UseCase       → registerLazySingleton
3. Repository    → registerLazySingleton<Interface>(() => Impl(...))
4. DataSource    → registerLazySingleton<Interface>(() => Impl(...))
5. SharedPref    → registerLazySingleton
6. External      → DioClient, DioResponseParser, AuthInterceptor
```

**Cara tambah fitur baru di DI:**

```dart
// 1. BLoC (di bagian atas, bersama bloc lain)
locator.registerFactory(() => XyzBloc(getXyzUseCase: locator()));

// 2. UseCase (di bagian usecase)
locator.registerLazySingleton(() => GetXyzUseCase(locator()));

// 3. Repository (di bagian repository)
locator.registerLazySingleton<XyzRepository>(
    () => XyzRepositoryImpl(remoteDataSource: locator()));

// 4. DataSource (di bagian datasource)
locator.registerLazySingleton<XyzRemoteDataSource>(
    () => XyzRemoteDataSourceImpl(
        client: locator(), responseParser: locator()));
```

---

## 7. Helpers & Utilities yang Tersedia

### Date & Time — `lib/common/time_convert.dart` + `lib/common/utils/custom_date_format.dart`

```dart
// Format "2024-01-15 10:30:00" → "15.30" (waktu saja)
timeConvert(dateString);

// Format "2024-01-15 10:30:00" → "15 Januari 2024"
dateConvert(dateString);

// Format ISO "2024-01-15T10:30:00Z" → "15 Januari 2024"
dateConvertWithT(dateString);

// Format ISO + tambah 1 hari → "16 Januari 2024"
formatToIndonesianDateNextDay(isoString);

// Custom format dengan locale Indonesia
CustomDateFormat.convertToDateFormat(date);                     // "15-Januari-2024"
CustomDateFormat.convertToDateFormat(date, format: "dd/MM/yyyy"); // "15/01/2024"
CustomDateFormat.convertToDateFormatOnlyDate(date);             // tanggal saja
CustomDateFormat.convertToDateFormatDMY(date);                  // "15-01-2024"
```

### Currency — `lib/common/utils/currency_format.dart`

```dart
CurrencyFormat.convertToIdr(50000, 0);           // "Rp50.000"
CurrencyFormat.convertToIdrWithSpasi(50000, 0);   // "Rp 50.000"
CurrencyFormat.convertToIdrDouble(50000.5, 2);    // "Rp50.000,50"
CurrencyFormat.convertToIdrNum(50000, 0);         // "Rp50.000" (num input)
CurrencyFormat.convertWithoutSymbol(50000, 0);    // "50.000"
```

### String — `lib/common/extension.dart` + `lib/common/convert_string_to_map.dart`

```dart
truncateText("Teks yang sangat panjang", 10);  // "Teks yang ..."
parseStringToMap("{key: value}");               // Map<String, dynamic>
```

### String Constants — `lib/common/string.dart`

UI label dan dialog text. Gunakan `Strings.label_xxx` atau `Strings.dialog_xxx`.

### Failure Types — `lib/common/failure.dart`

```dart
ServerFailure(message)       // API/server error
ConnectionFailure(message)   // Network/timeout error
DatabaseFailure(message)     // Local DB error
UnknownFailure(message)      // Lainnya
```

### Exception Types — `lib/common/exception.dart`

```dart
ServerException(message)
DatabaseException(message)
UnauthorizedException(message)
UnknownException(message)
TokenExpiredException(message)
TokenRefreshFailedException(message)
```

### Request Status Enum — `lib/common/enum_status.dart`

```dart
enum RequestStatus { empty, success, failure, loading, dataExhausted }
```

### Colors & Typography — `lib/common/styles.dart`

```dart
// Colors
primaryColor        // hijau #34A853
secondaryColor      // hijau gelap #309C4D
errorColor          // merah #E31A1A
warningColor        // oranye #FBA63C
blueMain            // biru #08A0F7
inActiveGray        // abu #C2C2C2

// Typography (default font: Jakarta Sans)
AppTypography.bold16
AppTypography.semiBold14 / semiBold16 / semiBold20
AppTypography.medium12 / medium14
AppTypography.regular10 / regular12 / regular14 / regular16
// Inter font
AppTypography.interRegular12 / interSemiBold14 / interSemiBold16
```

### Global Widgets — `lib/common/global/widgets/`

Widget siap pakai (jangan bikin duplikat):
- `custom_button.dart` — tombol utama (hijau)
- `custom_button_secondary.dart` — tombol sekunder
- `custom_outline_button.dart` / `custom_outline_button_primary.dart`
- `custom_text_field.dart` — input field
- `custom_password_field.dart` — input password dengan toggle
- `custom_drop_down.dart` — dropdown
- `custom_desc_field.dart` — textarea
- `custom_toast.dart` — toast notification
- `confirmation_dialog.dart` — dialog konfirmasi (Ya/Tidak)
- `debounce_button.dart` — tombol anti double-tap
- `tab_button.dart` — tab button
- `profile_avatar_custom.dart` — avatar profil

### Global Mixins — `lib/common/global/mixin/`

- `handling_error_page.dart` — mixin untuk handle error page
- `pop_up_pin_page.dart` — mixin untuk popup PIN

### SharedPref Keys — `lib/common/constants.dart`

```dart
USERANDTOKEN   = 'USER_AND_TOKEN'    // data login user (tanpa token)
PROFILEDATA    = 'DATA_PROFILE'      // cache profil
FCMTOKEN       = 'FCMTOKEN'          // FCM push token
DATATALENT     = 'DATA_TALENTS'      // talent list cache
TIME           = 'TIME'              // forget pin timer
REMOTEVERSION  = 'VERSION'           // remote config version
```

Kalau butuh key baru → tambah di file ini (additive, Level 2).
