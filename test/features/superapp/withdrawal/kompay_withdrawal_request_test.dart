import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/data/datasources/kompay_withdrawal_remote_datasource.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/data/withdrawal_nominal_checker.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/entities/kompay_withdrawal.dart';

void main() {
  group('partner-withdrawal', () {
    test('respons sukses diterima', () {
      KompayWithdrawalRemoteDataSource.ensureSuccess({
        'meta': {'status': 'success', 'code': 200, 'message': 'ok'},
        'data': null,
      });
    });

    test('status gagal jadi penolakan dengan pesan BE', () {
      expect(
        () => KompayWithdrawalRemoteDataSource.ensureSuccess({
          'meta': {'status': 'failed', 'code': 422, 'message': 'Rekening tidak valid'},
        }),
        throwsA(isA<KompayWithdrawalRejected>()
            .having((e) => e.message, 'message', 'Rekening tidak valid')),
      );
    });
  });

  group('withdraw_possibilites', () {
    Map<String, dynamic> body(dynamic possible) => {
          'balance': 100000,
          'ideal_balance': 0,
          'maximum_withdraw_nominal': 100000,
          'withdraw_possibilites': possible,
        };

    test('0 berarti masih ada antrean penarikan', () {
      expect(WithdrawalNominalCheck.fromJson(body(0)).possible, isFalse);
    });

    test('selain 0 atau tidak dikirim berarti boleh mengajukan', () {
      expect(WithdrawalNominalCheck.fromJson(body(1)).possible, isTrue);
      expect(WithdrawalNominalCheck.fromJson(body(null)).possible, isTrue);
    });
  });
}
