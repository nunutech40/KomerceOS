/// UI model untuk data talent di halaman Talent Pool.
///
/// Model ini murni untuk kebutuhan tampilan. Ketika endpoint tersedia,
/// mapping dari response API bisa ditambahkan lewat factory `fromJson`.
class TalentModel {
  final String name;
  final String role;
  final String avatarUrl;

  /// Conversion rate dalam persen, mis. 80 → "CR 80%".
  final int conversionRate;

  /// Rating 0–5, mis. 4.5 → "Rate 4.5".
  final double rating;

  /// Lama pengalaman, mis. "3 Tahun 2 Bulan".
  final String experience;

  /// Daftar industri/tag, mis. ["Fashion", "Kesehatan", "Otomotif"].
  final List<String> industries;

  /// Jumlah partner lain yang menandai talent ini.
  final int markedByPartner;

  /// Apakah talent ini sudah ditandai/favorit oleh user.
  final bool isFavorite;

  const TalentModel({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.conversionRate,
    required this.rating,
    required this.experience,
    required this.industries,
    required this.markedByPartner,
    this.isFavorite = false,
  });

  TalentModel copyWith({bool? isFavorite}) {
    return TalentModel(
      name: name,
      role: role,
      avatarUrl: avatarUrl,
      conversionRate: conversionRate,
      rating: rating,
      experience: experience,
      industries: industries,
      markedByPartner: markedByPartner,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Industri utama (chip pertama) + sisa jumlah untuk badge "+N".
  String get primaryIndustry => industries.isNotEmpty ? industries.first : '';
  int get extraIndustryCount =>
      industries.length > 1 ? industries.length - 1 : 0;

  /// Total pengalaman dalam bulan, diambil dari string [experience]
  /// (mis. "3 Tahun 2 Bulan" → 38). Dipakai untuk pengurutan.
  int get experienceInMonths {
    final yearMatch = RegExp(r'(\d+)\s*Tahun').firstMatch(experience);
    final monthMatch = RegExp(r'(\d+)\s*Bulan').firstMatch(experience);
    final years = int.tryParse(yearMatch?.group(1) ?? '') ?? 0;
    final months = int.tryParse(monthMatch?.group(1) ?? '') ?? 0;
    return years * 12 + months;
  }
}
