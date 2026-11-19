/// One part of a KYC submission that the admin can reject.
enum KycRejectedItem { liveness, ktp, selfieKtp, partnerData }

class KycHistory {
  const KycHistory({
    this.status,
    this.livenessStatus,
    this.livenessUrl,
    this.livenessNotes,
    this.ktpStatus,
    this.ktpUrl,
    this.ktpNotes,
    this.selfieKtpStatus,
    this.selfieKtpUrl,
    this.selfieKtpNotes,
    this.partnerData = const {},
  });

  final String? status;
  final String? livenessStatus;
  final String? livenessUrl;
  final String? livenessNotes;
  final String? ktpStatus;
  final String? ktpUrl;
  final String? ktpNotes;
  final String? selfieKtpStatus;
  final String? selfieKtpUrl;
  final String? selfieKtpNotes;
  final Map<String, String> partnerData;

  bool get isRequested => status?.toLowerCase() == 'requested';
  bool get isRejected => status?.toLowerCase() == 'rejected';

  /// Liveness cannot be taken again once the server has a recorded result.
  bool get hasUploadedLiveness =>
      (livenessStatus != null && livenessStatus!.isNotEmpty) ||
      (livenessUrl != null && livenessUrl!.isNotEmpty);
  bool get hasLivenessUrl => livenessUrl != null && livenessUrl!.isNotEmpty;
  bool get hasKtp => ktpUrl != null && ktpUrl!.isNotEmpty;
  bool get hasSelfieKtp => selfieKtpUrl != null && selfieKtpUrl!.isNotEmpty;
  bool get hasCompleteImages =>
      (hasLivenessUrl || livenessStatus?.toLowerCase() == 'draft') &&
      hasKtp &&
      hasSelfieKtp;

  static bool _isRejectedStatus(String? value) =>
      value?.toLowerCase() == 'rejected';

  bool get isLivenessRejected => isRejected && _isRejectedStatus(livenessStatus);
  bool get isKtpRejected => isRejected && _isRejectedStatus(ktpStatus);
  bool get isSelfieKtpRejected =>
      isRejected && _isRejectedStatus(selfieKtpStatus);

  /// `latest-history` has no status for the partner data. A rejected
  /// submission whose photos were all accepted means the data was rejected.
  bool get isPartnerDataRejected =>
      isRejected &&
      !isLivenessRejected &&
      !isKtpRejected &&
      !isSelfieKtpRejected;

  /// Rejected parts in flow order (liveness → KTP → selfie → data).
  List<KycRejectedItem> get rejectedItems => [
        if (isLivenessRejected) KycRejectedItem.liveness,
        if (isKtpRejected) KycRejectedItem.ktp,
        if (isSelfieKtpRejected) KycRejectedItem.selfieKtp,
        if (isPartnerDataRejected) KycRejectedItem.partnerData,
      ];

  String? notesFor(KycRejectedItem item) => switch (item) {
        KycRejectedItem.liveness => livenessNotes,
        KycRejectedItem.ktp => ktpNotes,
        KycRejectedItem.selfieKtp => selfieKtpNotes,
        KycRejectedItem.partnerData => null,
      };

  // Retake hierarchy from the task AC (KMC-03190):
  // KTP rejected      → liveness + KTP + selfie
  // selfie rejected   → KTP + selfie (liveness kept)
  // liveness rejected → liveness + KTP (selfie kept)
  // data rejected     → form only, no camera
  bool get mustRetakeLiveness => isKtpRejected || isLivenessRejected;
  bool get mustRetakeKtp =>
      isKtpRejected || isSelfieKtpRejected || isLivenessRejected;
  bool get mustRetakeSelfieKtp => isKtpRejected || isSelfieKtpRejected;
}
