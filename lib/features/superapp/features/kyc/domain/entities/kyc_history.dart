class KycHistory {
  const KycHistory({
    this.status,
    this.livenessStatus,
    this.livenessUrl,
    this.ktpStatus,
    this.ktpUrl,
    this.selfieKtpStatus,
    this.selfieKtpUrl,
    this.partnerData = const {},
  });

  final String? status;
  final String? livenessStatus;
  final String? livenessUrl;
  final String? ktpStatus;
  final String? ktpUrl;
  final String? selfieKtpStatus;
  final String? selfieKtpUrl;
  final Map<String, String> partnerData;

  bool get isRequested => status?.toLowerCase() == 'requested';

  /// Liveness cannot be taken again once the server has a recorded result.
  bool get hasUploadedLiveness =>
      (livenessStatus != null && livenessStatus!.isNotEmpty) ||
      (livenessUrl != null && livenessUrl!.isNotEmpty);
  bool get hasKtp => ktpUrl != null && ktpUrl!.isNotEmpty;
  bool get hasSelfieKtp => selfieKtpUrl != null && selfieKtpUrl!.isNotEmpty;
  bool get hasCompleteImages =>
      (livenessUrl != null && livenessUrl!.isNotEmpty ||
          livenessStatus?.toLowerCase() == 'draft') &&
      hasKtp &&
      hasSelfieKtp;
}
