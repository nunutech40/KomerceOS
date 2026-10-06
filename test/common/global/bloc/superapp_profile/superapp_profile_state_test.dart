import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';

void main() {
  SuperappProfileState stateFor({
    int? isKomship,
    List<ProductMailVerificationModel> verifications = const [],
  }) {
    return SuperappProfileState(
      status: SuperappProfileStatus.loaded,
      freshProfile: SuperappProfileModel(
        isKomship: isKomship,
        productMailVerifications: verifications,
      ),
    );
  }

  group('Komship display access', () {
    test('is visible when is_komship is enabled without email verification',
        () {
      final state = stateFor(isKomship: 1);

      expect(state.isKomshipVerified, isTrue);
    });

    test('is visible when is_komship is enabled with email verification', () {
      final state = stateFor(
        isKomship: 1,
        verifications: const [
          ProductMailVerificationModel(
            productName: 'komship',
            isVerified: true,
          ),
        ],
      );

      expect(state.isKomshipVerified, isTrue);
    });

    test('is hidden when is_komship is disabled', () {
      final state = stateFor(isKomship: 0);

      expect(state.isKomshipVerified, isFalse);
    });
  });
}
