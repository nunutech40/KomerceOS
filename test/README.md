# 🧪 Testing Guide - Komtim Partner

Panduan lengkap untuk menulis dan menjalankan test di project Komtim Partner.

---

## 📁 Struktur Folder Test

```
test/
├── helpers/                          # 🛠️ Test utilities & helpers
│   ├── mocks/                        # Mock objects (BLoC, Repository, Datasource)
│   │   ├── mock_blocs.dart
│   │   ├── mocks.dart               # Definisi Mockito @GenerateMocks
│   │   └── mocks.mocks.dart         # Generated Mockito classes
│   ├── fixtures/                     # Mock data & test fixtures
│   │   └── fixtures.dart            # Factory untuk mock data
│   ├── utils/                        # Test helper utilities
│   │   ├── test_helper.dart
│   │   ├── widget_test_helper.dart
│   │   └── bloc_test_helper.dart
│   ├── pump_app.dart                # Helper untuk wrap widget dengan MaterialApp
│   └── helpers.dart                 # 🎯 IMPORT INI untuk semua helpers
├── core/                            # Test untuk core layer (mirror app structure)
│   ├── data/
│   │   ├── datasources/
│   │   ├── repositories/
│   │   └── models/
│   └── domain/
│       └── usecases/
├── features/                        # Test untuk features (mirror app structure)
│   ├── invoice/
│   │   ├── bloc/
│   │   └── widgets/
│   ├── auth/
│   └── attendance/
└── widgets/                         # Widget tests (cross-feature)
```

---

## 🚀 Quick Start

### 1. Import Test Helpers

**SELALU gunakan centralized import:**

```dart
import '../helpers/helpers.dart';  // ✅ Semua helper tersedia
```

**JANGAN import satu-satu:**
```dart
import '../helpers/pump_app.dart';           // ❌ Tidak perlu
import '../helpers/fixtures/fixtures.dart';  // ❌ Tidak perlu
import '../helpers/mocks/mocks.dart';        // ❌ Tidak perlu
```

### 2. Template Widget Test

```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/helpers.dart';

void main() {
  group('MyWidget Tests', () {
    testWidgets('should display text correctly', (tester) async {
      // Arrange
      final mockData = MockDataFactory.createPaidInvoice();
      
      // Act
      await tester.pumpWidget(
        pumpApp(MyWidget(data: mockData)),
      );
      
      // Assert
      expect(find.text('Expected Text'), findsOneWidget);
    });
  });
}
```

### 3. Template Widget Test dengan BLoC

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import '../helpers/helpers.dart';

void main() {
  group('MyWidget with BLoC Tests', () {
    late MockMyBloc mockBloc;
    
    setUp(() {
      mockBloc = MockMyBloc();
    });
    
    testWidgets('should display data when loaded', (tester) async {
      // Arrange
      whenListen(
        mockBloc,
        Stream.fromIterable([LoadingState(), SuccessState(data)]),
        initialState: InitialState(),
      );
      
      // Act
      await tester.pumpWidget(
        pumpAppWithBloc<MyBloc>(
          bloc: mockBloc,
          child: MyWidget(),
        ),
      );
      await tester.pump(); // Trigger state change
      
      // Assert
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
```

### 4. Template BLoC Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../helpers/helpers.dart';

void main() {
  group('MyBloc Tests', () {
    late MockMyRepository mockRepository;
    late MyBloc bloc;
    
    setUp(() {
      mockRepository = MockMyRepository();
      bloc = MyBloc(mockRepository);
    });
    
    blocTest<MyBloc, MyState>(
      'emits [Loading, Success] when data loaded successfully',
      build: () {
        when(mockRepository.getData())
            .thenAnswer((_) async => Right(mockData));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDataEvent()),
      expect: () => [
        LoadingState(),
        SuccessState(mockData),
      ],
    );
  });
}
```

---

## 🏭 Mock Data Factory

Gunakan **MockDataFactory** untuk membuat test data yang konsisten.

### Invoice Fixtures

```dart
// Invoice PAID
final invoice = MockDataFactory.createPaidInvoice(
  invoiceCode: 'INV-001',
  customerName: 'John Doe',
  totalAmount: 150000.0,
);

// Invoice UNPAID
final invoice = MockDataFactory.createUnpaidInvoice();

// Invoice TOPUP
final invoice = MockDataFactory.createTopupInvoice(totalAmount: 500000);

// Invoice WITHDRAWAL
final invoice = MockDataFactory.createWithdrawalInvoice();

// List invoice (5 items dengan berbagai status)
final invoices = MockDataFactory.createInvoiceList(count: 5);
```

### Profile & Attendance Fixtures

```dart
// Profile
final profile = MockDataFactory.createProfile();

// Attendance
final attendance = MockDataFactory.createAttendance();
final lateAttendance = MockDataFactory.createLateAttendance();
```

---

## 🎨 Test Helpers

### pumpApp() - Wrap Widget dengan MaterialApp

```dart
// Basic usage
await tester.pumpWidget(
  pumpApp(MyWidget()),
);

// Dengan custom theme
await tester.pumpWidget(
  pumpApp(
    MyWidget(),
    theme: ThemeData.dark(),
  ),
);

// Dengan BLoC (single)
await tester.pumpWidget(
  pumpAppWithBloc<MyBloc>(
    bloc: mockBloc,
    child: MyWidget(),
  ),
);

// Dengan multiple BLoCs
await tester.pumpWidget(
  pumpApp(
    MyWidget(),
    providers: [
      BlocProvider<Bloc1>.value(value: mockBloc1),
      BlocProvider<Bloc2>.value(value: mockBloc2),
    ],
  ),
);
```

### TestHelper - Interaction Helpers

```dart
// Tap dan tunggu animasi
await TestHelper.tapAndSettle(tester, find.byType(MyButton));

// Scroll sampai widget terlihat
await TestHelper.scrollUntilVisible(
  tester,
  find.text('My Widget'),
  find.byType(ListView),
);

// Enter text
await TestHelper.enterTextAndSettle(
  tester,
  find.byType(TextField),
  'test@example.com',
);

// Verifikasi
TestHelper.verifyTextExists('Hello');
TestHelper.verifyWidgetExists<CircularProgressIndicator>();
```

### WidgetTestHelper - Readable Assertions

```dart
// Setup global tester (sekali di awal test)
testWidgets('my test', (tester) async {
  setGlobalTester(tester);
  
  // Finding widgets
  WidgetTestHelper.expectExists(find.text('Hello'));
  WidgetTestHelper.expectNotExists(find.text('Error'));
  WidgetTestHelper.expectTextContains('Welcome');
  
  // Loading states
  WidgetTestHelper.expectLoadingExists();
  WidgetTestHelper.expectLoadingNotExists();
  
  // Interactions
  await WidgetTestHelper.tapButton(tester, 'Submit');
  await WidgetTestHelper.enterText(tester, find.byType(TextField), 'text');
  
  // Scrolling
  await WidgetTestHelper.scrollToBottom(tester, find.byType(ListView));
  await WidgetTestHelper.pullToRefresh(tester, find.byType(ListView));
});
```

---

## 🧩 Mock Objects

### Mock BLoC

```dart
// Setup mock bloc
final mockBloc = MockInvoiceListBloc();

// Define state stream
whenListen(
  mockBloc,
  Stream.fromIterable([
    InvoiceListLoadingState(),
    InvoiceListSuccessState(invoices: mockInvoices),
  ]),
  initialState: InvoiceListInitialState(),
);

// Use in test
await tester.pumpWidget(
  pumpAppWithBloc<InvoiceListBloc>(
    bloc: mockBloc,
    child: InvoiceListPage(),
  ),
);
```

### Mock Repository

```dart
// Setup mock repository
final mockRepo = MockInvoiceRepository();

// Define behavior
when(mockRepo.getInvoices(limit: 10, offset: 0))
    .thenAnswer((_) async => Right(mockInvoices));

// Verify called
verify(mockRepo.getInvoices(limit: 10, offset: 0)).called(1);
```

### Mock Datasource

```dart
final mockDatasource = MockInvoiceRemoteDatasource();

when(mockDatasource.getInvoices(any, any))
    .thenAnswer((_) async => InvoicesResponse(data: mockData));
```

---

## ✅ Best Practices

### 1. **AAA Pattern**
Selalu gunakan Arrange-Act-Assert pattern:

```dart
testWidgets('example test', (tester) async {
  // Arrange - setup data & mocks
  final mockData = MockDataFactory.createPaidInvoice();
  
  // Act - perform action
  await tester.pumpWidget(pumpApp(MyWidget(data: mockData)));
  
  // Assert - verify result
  expect(find.text('Expected'), findsOneWidget);
});
```

### 2. **DRY - Don't Repeat Yourself**
Gunakan `setUp()` dan `tearDown()`:

```dart
group('MyWidget Tests', () {
  late MockBloc mockBloc;
  
  setUp(() {
    mockBloc = MockBloc();
  });
  
  tearDown(() {
    mockBloc.close();
  });
  
  testWidgets('test 1', (tester) async { /* ... */ });
  testWidgets('test 2', (tester) async { /* ... */ });
});
```

### 3. **Descriptive Test Names**
Gunakan nama test yang jelas:

```dart
// ✅ Good
testWidgets('should display error message when network fails', (tester) async {

// ❌ Bad
testWidgets('test error', (tester) async {
```

### 4. **Test One Thing**
Setiap test hanya test 1 behavior:

```dart
// ✅ Good
testWidgets('should display loading indicator', (tester) async { /* ... */ });
testWidgets('should display data when loaded', (tester) async { /* ... */ });

// ❌ Bad - test terlalu banyak hal
testWidgets('should handle all states', (tester) async { 
  // test loading, success, error dalam 1 test
});
```

### 5. **Gunakan MockDataFactory**
Jangan hardcode test data:

```dart
// ✅ Good
final invoice = MockDataFactory.createPaidInvoice();

// ❌ Bad
final invoice = InvoicesDataModel(
  invoiceId: 1,
  invoiceCode: 'INV-001',
  // ... banyak field
);
```

---

## 🎯 Testing Checklist

Saat membuat feature baru, pastikan ada test untuk:

- [ ] **Widget Test** - UI components
  - [ ] Rendering dengan berbagai states (loading, success, error, empty)
  - [ ] User interactions (tap, scroll, input)
  - [ ] Navigation
  
- [ ] **BLoC Test** - Business logic
  - [ ] Setiap event menghasilkan state yang benar
  - [ ] Error handling
  - [ ] Edge cases
  
- [ ] **Repository Test** - Data layer
  - [ ] Success scenarios
  - [ ] Error scenarios (network, parsing, etc)
  
- [ ] **Use Case Test** - Domain logic
  - [ ] Happy path
  - [ ] Error handling

---

## 🏃 Run Tests

```bash
# Run semua tests
flutter test

# Run code generator untuk Mockito (jika ada mock baru yang didaftarkan)
dart run build_runner build --delete-conflicting-outputs

# Run test spesifik
flutter test test/widgets/invoice_item_test.dart

# Run tests dengan coverage
flutter test --coverage

# Watch mode (auto-run saat file berubah)
flutter test --watch

# Run tests dengan output verbose
flutter test --reporter expanded
```

### View Coverage Report

```bash
# Generate coverage
flutter test --coverage

# Install genhtml (jika belum ada)
# Windows: Install Perl + lcov
# Mac: brew install lcov
# Linux: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
# Windows: start coverage/html/index.html
# Mac: open coverage/html/index.html
# Linux: xdg-open coverage/html/index.html
```

---

## 📚 Resources

### Dependencies yang Digunakan

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0      # Testing BLoC
  mockito: ^5.4.4        # Mocking dengan Code Generation
  build_runner: ^2.7.1   # Generator runner
```

### External Links

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [BLoC Testing](https://bloclibrary.dev/#/testing)
- [Mockito Package](https://pub.dev/packages/mockito)

---

## 🆘 Troubleshooting

### Error: "No MaterialLocalizations found"
**Solution:** Gunakan `pumpApp()` untuk wrap widget, bukan `pumpWidget()` langsung.

### Error: "Global tester not set"
**Solution:** Call `setGlobalTester(tester)` di awal test saat menggunakan `WidgetTestHelper`.

### Error: "MissingPluginException"
**Solution:** Beberapa plugin perlu mock. Contoh:
```dart
TestWidgetsFlutterBinding.ensureInitialized();
```

### Test Timeout
**Solution:** Increase timeout di test:
```dart
testWidgets('test', (tester) async { /* ... */ }, timeout: Timeout(Duration(seconds: 30)));
```

---

## 👥 Untuk Developer Baru

1. **Baca dokumentasi ini** sepenuhnya
2. **Lihat contoh test** di `test/widgets/invoice_item_test.dart`
3. **Copy template** di atas untuk test baru
4. **Import `helpers.dart`** untuk semua test utilities
5. **Tanya di grup** jika ada yang tidak jelas

**Happy Testing! 🎉**
