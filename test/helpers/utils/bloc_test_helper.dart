import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';

/// Helper untuk testing BLoC dengan pattern yang konsisten
class BlocTestHelper {
  /// Test BLoC dengan struktur yang konsisten
  ///
  /// Usage:
  /// ```dart
  /// BlocTestHelper.testBloc<MyBloc, MyState>(
  ///   description: 'emits success state when data loaded',
  ///   build: () => MyBloc(mockRepository),
  ///   act: (bloc) => bloc.add(LoadDataEvent()),
  ///   expect: () => [LoadingState(), SuccessState(data)],
  /// );
  /// ```
  static void testBloc<B extends BlocBase<S>, S>({
    required String description,
    required B Function() build,
    required Function(B) act,
    required List<S> Function() expect,
    int? skip,
    Duration? wait,
    Function()? setUp,
    Function()? tearDown,
    Function(B)? verify,
  }) {
    blocTest<B, S>(
      description,
      build: build,
      act: act,
      expect: expect,
      skip: skip ?? 0,
      wait: wait,
      setUp: setUp,
      tearDown: tearDown,
      verify: verify,
    );
  }
}

/// Note: Saat ini sudah menggunakan Mockito (Centralized Code Generation), jadi tidak perlu deklarasi Mocktail lagi.
/// Lihat mocks.mocks.dart untuk contoh mock class yang terbuat otomatis.
