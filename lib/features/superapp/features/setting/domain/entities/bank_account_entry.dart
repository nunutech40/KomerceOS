class BankAccountEntry {
  const BankAccountEntry({
    this.id,
    required this.bankName,
    required this.accountName,
    required this.accountNo,
  });

  final int? id;
  final String bankName;
  final String accountName;
  final String accountNo;
}

class AvailableBank {
  const AvailableBank({required this.code, required this.name});
  final String code;
  final String name;
}

class BankOtpChallenge {
  const BankOtpChallenge({
    required this.token,
    required this.nextRequestAt,
    this.expiredAt,
  });
  final String token;
  final DateTime nextRequestAt;
  final DateTime? expiredAt;
}

class BankLiability {
  const BankLiability(
      {required this.email, required this.balance, this.userId});
  final String email;
  final int balance;
  final int? userId;
}

class BankAccountCheckResult {
  const BankAccountCheckResult.clear() : liabilities = const [];
  const BankAccountCheckResult.liabilities(this.liabilities);
  final List<BankLiability> liabilities;
  bool get hasLiabilities => liabilities.isNotEmpty;
}
