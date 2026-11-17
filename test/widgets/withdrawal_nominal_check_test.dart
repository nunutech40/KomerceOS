import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/data/withdrawal_nominal_checker.dart';

void main() {
  test('membaca batas nominal dari respons Komship', () {
    final result = WithdrawalNominalCheck.fromJson({
      'balance': 100000,
      'ideal_balance': 25000,
      'maximum_withdraw_nominal': 75000,
      'potency_retur': 12000,
      'potency_income': 9000,
    });

    expect(result.balance, 100000);
    expect(result.maximum, 75000);
    expect(result.ideal, 25000);
    expect(result.potentialReturn, 12000);
    expect(result.potentialIncome, 9000);
  });

  test('menghitung maksimum bila API tidak menyertakannya', () {
    final result = WithdrawalNominalCheck.fromJson({
      'balance': 100000,
      'ideal_balance': 25000.0,
    });
    expect(result.maximum, 75000);
  });

  test('menolak respons tanpa saldo', () {
    expect(() => WithdrawalNominalCheck.fromJson({}), throwsFormatException);
  });
}
