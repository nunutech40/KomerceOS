/// Opsi filter untuk halaman Talent Pool (Role, Industri, Urutkan).
///
/// Digunakan oleh [TalentFilterSheet] dan halaman utama untuk menyimpan
/// pilihan filter yang sedang aktif.
class TalentFilter {
  final String role;
  final String industry;
  final String sort;

  const TalentFilter({
    this.role = TalentFilterOptions.defaultRole,
    this.industry = TalentFilterOptions.defaultIndustry,
    this.sort = TalentFilterOptions.defaultSort,
  });

  TalentFilter copyWith({
    String? role,
    String? industry,
    String? sort,
  }) {
    return TalentFilter(
      role: role ?? this.role,
      industry: industry ?? this.industry,
      sort: sort ?? this.sort,
    );
  }

  /// True jika role membatasi hasil (bukan "Semua").
  bool get hasRole => role != TalentFilterOptions.defaultRole;

  /// True jika industri membatasi hasil (bukan "Semua").
  bool get hasIndustry => industry != TalentFilterOptions.defaultIndustry;

  /// True jika sebuah metode pengurutan sudah dipilih.
  bool get hasSort => TalentFilterOptions.sorts.contains(sort);
}

/// Kumpulan pilihan statis untuk dropdown filter.
abstract final class TalentFilterOptions {
  static const String defaultRole = 'Semua';
  static const String defaultIndustry = 'Semua';
  static const String defaultSort = 'Pilih filter sort';

  static const List<String> roles = [
    'Semua',
    'Customer Service',
    'Admin Marketplace',
    'Live Streamer',
    'Advertiser',
  ];

  static const List<String> industries = [
    'Semua',
    'Fashion',
    'FnB',
    'Otomotif',
    'Rumah Tangga',
    'Beauty',
    'Health',
  ];

  static const List<String> sorts = [
    sortTopRated,
    sortMostMarked,
    sortLongestExperience,
    sortTopConversion,
  ];

  static const String sortTopRated = 'Rate Tertinggi';
  static const String sortMostMarked = 'Paling Banyak Ditandai';
  static const String sortLongestExperience = 'Pengalaman Terlama';
  static const String sortTopConversion = 'CR Tertinggi';
}
