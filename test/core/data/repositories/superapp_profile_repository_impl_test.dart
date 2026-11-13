import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/datasources/remote/superapp_profile_remote_datasource.dart';
import 'package:komtim_partner/core/data/repositories/superapp_profile_repository_impl.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSuperappProfileRemoteDataSource extends Mock
    implements SuperappProfileRemoteDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSuperappProfileRemoteDataSource mockRemoteDataSource;
  late SuperappProfileRepositoryImpl repository;

  const tProfileModel = SuperappProfileModel(
    id: 10,
    fullName: 'Test User',
    username: 'testuser',
    email: 'test@example.com',
    saldo: 50000,
    kompoints: 100,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRemoteDataSource = MockSuperappProfileRemoteDataSource();
    repository = SuperappProfileRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      sharedPreferences: SharedPreferences.getInstance(),
    );
  });

  group('seedPendingProfile & consumePendingProfile (Preloaded Profile Handshake)', () {
    test('consumePendingProfile returns null initially when nothing is seeded', () {
      expect(repository.consumePendingProfile(), isNull);
    });

    test('seedPendingProfile stores profile and consumePendingProfile consumes it once', () {
      repository.seedPendingProfile(tProfileModel);

      // Konsumsi pertama harus mengembalikan profile yang di-seed
      final consumed = repository.consumePendingProfile();
      expect(consumed, equals(tProfileModel));

      // Konsumsi kedua harus mengembalikan null (consume-once guarantee)
      final secondConsume = repository.consumePendingProfile();
      expect(secondConsume, isNull);
    });

    test('clearCache also clears pendingFreshProfile in memory', () async {
      repository.seedPendingProfile(tProfileModel);
      await repository.clearCache();

      expect(repository.consumePendingProfile(), isNull);
    });
  });
}

