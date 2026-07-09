# 🧪 Komtim Partner - Testing Architecture

> **Untuk Developer**: Baca panduan ini sebelum menulis test!

---

## 🎯 Quick Start (5 Menit)

### 1. Import Test Helpers

**✅ CARA YANG BENAR:**
```dart
import '../helpers/helpers.dart';  // Semua utilities tersedia
```

**❌ JANGAN:**
```dart
import '../helpers/pump_app.dart';
import '../helpers/fixtures/fixtures.dart';
import '../helpers/mocks/mocks.dart';
```

### 2. Copy Template & Mulai Test

**Widget Test:**
```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/helpers.dart';

void main() {
  testWidgets('should display data', (tester) async {
    // Arrange
    final mockData = MockDataFactory.createPaidInvoice();
    
    // Act
    await tester.pumpWidget(pumpApp(MyWidget(data: mockData)));
    
    // Assert
    expect(find.text('Expected'), findsOneWidget);
  });
}
```

**BLoC Test:**
```dart
import 'package:bloc_test/bloc_test.dart';
import '../helpers/helpers.dart';

void main() {
  late MockRepository mockRepo;
  
  setUp(() => mockRepo = MockRepository());
  
  blocTest<MyBloc, MyState>(
    'emits success when data loaded',
    build: () {
      when(() => mockRepo.getData()).thenAnswer((_) async => Right(data));
      return MyBloc(mockRepo);
    },
    act: (bloc) => bloc.add(LoadEvent()),
    expect: () => [LoadingState(), SuccessState(data)],
  );
}
```

---

## 📁 Struktur Folder

```
test/
├── helpers/
│   ├── mocks/              # Mock objects
│   │   ├── mock_blocs.dart
│   │   ├── mock_repositories.dart
│   │   ├── mock_datasources.dart
│   │   └── mocks.dart     # Export all
│   ├── fixtures/          # Test data
│   │   └── fixtures.dart
│   ├── utils/             # Test utilities
│   │   ├── test_helper.dart
│   │   ├── widget_test_helper.dart
│   │   └── bloc_test_helper.dart
│   ├── pump_app.dart      # Widget wrapper
│   └── helpers.dart       # 🎯 Import ini!
├── core/                  # Mirror app structure
├── features/              # Mirror app structure
└── widgets/               # Cross-feature widgets
```

---

## 🛠️ Cara Pakai

### Mock Data

```dart
// Invoice
final invoice = MockDataFactory.createPaidInvoice();
final unpaid = MockDataFactory.createUnpaidInvoice();
final topup = MockDataFactory.createTopupInvoice();
final list = MockDataFactory.createInvoiceList(count: 10);

// Profile
final profile = MockDataFactory.createProfile();

// Attendance
final attendance = MockDataFactory.createAttendance();
```

### Pump App

```dart
// Basic
await tester.pumpWidget(pumpApp(MyWidget()));

// Dengan BLoC
await tester.pumpWidget(
  pumpAppWithBloc<MyBloc>(
    bloc: mockBloc,
    child: MyWidget(),
  ),
);

// Multiple BLoCs
await tester.pumpWidget(
  pumpApp(
    MyWidget(),
    providers: [
      BlocProvider.value(value: mockBloc1),
      BlocProvider.value(value: mockBloc2),
    ],
  ),
);
```

### Mock Objects

```dart
// BLoC
final mockBloc = MockInvoiceListBloc();
whenListen(mockBloc, Stream.fromIterable([state1, state2]));

// Repository
final mockRepo = MockInvoiceRepository();
when(() => mockRepo.getInvoices()).thenAnswer((_) async => Right(data));

// Datasource
final mockDs = MockInvoiceRemoteDatasource();
when(() => mockDs.fetch()).thenAnswer((_) async => response);
```

---

## ✅ Best Practices

1. **Selalu pakai helpers**: Import `helpers.dart`
2. **AAA Pattern**: Arrange → Act → Assert
3. **DRY**: Gunakan `setUp()` dan `tearDown()`
4. **Descriptive names**: Nama test harus jelas
5. **Test one thing**: 1 test = 1 behavior
6. **MockDataFactory**: Jangan hardcode data

---

## 🏃 Run Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/widgets/invoice_item_test.dart

# With coverage
flutter test --coverage

# Watch mode
flutter test --watch
```

---

## 📚 Contoh Lengkap

Lihat [`test/widgets/invoice_item_test.dart`](widgets/invoice_item_test.dart) untuk contoh lengkap!

---

## 🆘 Help

- **Error "No MaterialLocalizations"**: Gunakan `pumpApp()`, bukan `pumpWidget()` langsung
- **Test timeout**: Tambah `timeout: Timeout(Duration(seconds: 30))`
- **Mock tidak work**: Pastikan sudah `import '../helpers/helpers.dart'`

**Ada pertanyaan? Tanya di grup team! 💬**
