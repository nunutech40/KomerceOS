import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/domain/usecases/verify_pin_use_case.dart';
import 'package:komtim_partner/features/superapp/features/pin/bloc/account_pin_cubit.dart';

import '../widgets/fake_pin_repository.dart';

void main() {
  test('pintu rekening dan ubah PIN memakai kuota verifikasi yang sama',
      () async {
    final repository = FakePinRepository();
    final bankGate = VerifyPinUseCase(repository);
    final changePin = AccountPinCubit(repository);

    await bankGate.execute('000001');
    await changePin.verifyPin('000002');
    expect((await changePin.attemptLeft()).getOrElse(() => -1), 1);

    await bankGate.execute('000003');
    expect((await changePin.attemptLeft()).getOrElse(() => -1), 0);

    await changePin.close();
  });

  test('PIN benar mengembalikan kuota percobaan pada dua pintu', () async {
    final repository = FakePinRepository();
    final bankGate = VerifyPinUseCase(repository);
    final changePin = AccountPinCubit(repository);

    await changePin.verifyPin('000001');
    await bankGate.execute('123456');
    expect((await changePin.attemptLeft()).getOrElse(() => -1), 3);

    await changePin.close();
  });
}
