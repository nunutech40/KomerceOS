class KycHistory {
  const KycHistory({
    this.livenessStatus,
    this.livenessUrl,
    this.ktpStatus,
    this.ktpUrl,
    this.selfieKtpStatus,
    this.selfieKtpUrl,
    this.partnerData = const {},
  });

  final String? livenessStatus;
  final String? livenessUrl;
  final String? ktpStatus;
  final String? ktpUrl;
  final String? selfieKtpStatus;
  final String? selfieKtpUrl;
  final Map<String, String> partnerData;

  /// Liveness cannot be taken again once the server has a recorded result.
  bool get hasUploadedLiveness =>
      (livenessStatus != null && livenessStatus!.isNotEmpty) ||
      (livenessUrl != null && livenessUrl!.isNotEmpty);
  bool get hasKtp => ktpUrl != null && ktpUrl!.isNotEmpty;
  bool get hasSelfieKtp => selfieKtpUrl != null && selfieKtpUrl!.isNotEmpty;
}
