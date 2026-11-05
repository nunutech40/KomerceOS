/// Candidate values read from a KTP photo. OCR is not identity verification;
/// the user must review and correct these values before submission.
class KtpOcrData {
  const KtpOcrData({
    this.nik,
    this.name,
    this.birthPlace,
    this.birthDate,
    this.province,
    this.city,
    this.district,
    this.village,
    this.address,
    this.rtRw,
    this.postalCode,
  });

  final String? nik;
  final String? name;
  final String? birthPlace;
  final String? birthDate;
  final String? province;
  final String? city;
  final String? district;
  final String? village;
  final String? address;
  final String? rtRw;
  final String? postalCode;

  bool get hasRecognizedFields => [
        nik,
        name,
        birthPlace,
        birthDate,
        province,
        city,
        district,
        village,
        address,
        rtRw,
        postalCode,
      ].any((value) => value != null && value.isNotEmpty);
}
