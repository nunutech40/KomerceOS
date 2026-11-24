/// A submitted withdrawal, shown on the success page. Komship web builds this
/// message from the form (nominal, account owner and bank), not the response.
class KompayWithdrawal {
  const KompayWithdrawal({
    required this.nominal,
    required this.bankName,
    required this.bankOwnerName,
  });

  final int nominal;
  final String bankName;
  final String bankOwnerName;
}

/// HTTP 400 from `partner-withdrawal`. Komship web treats it as a pending
/// withdrawal that is not approved yet (queue) and blocks the request.
class KompayWithdrawalQueued implements Exception {
  const KompayWithdrawalQueued();
}

/// Any other rejection; the message comes from BE when available.
class KompayWithdrawalRejected implements Exception {
  const KompayWithdrawalRejected(this.message);
  final String message;

  @override
  String toString() => message;
}
