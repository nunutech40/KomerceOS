/// Opsi filter untuk halaman Talent Pool.
///
/// Semua filter bersifat **multi-select**:
/// - [selectedRatings] → daftar bintang yang dipilih (1-5)
/// - [selectedExperiences] → daftar range pengalaman (mis. ["0-6", "7-12"])
/// - [selectedBusinessSectorIds] → daftar ID sektor bisnis dari API
/// - [selectedSkillName] → role yang dipilih dari quick-filter chip
///   (mis. "customer service", '' = Semua)
/// - [searchQuery] → kata kunci pencarian bebas dari search bar
class TalentFilter {
  final Set<int> selectedRatings;
  final Set<String> selectedExperiences;
  final Set<int> selectedBusinessSectorIds;

  /// Role yang dipilih dari quick-filter chip (single-select).
  /// '' = "Semua" → tidak mengirim skill_name ke API.
  final String selectedSkillName;

  /// Kata kunci pencarian bebas dari search bar.
  final String searchQuery;

  const TalentFilter({
    this.selectedRatings = const {},
    this.selectedExperiences = const {},
    this.selectedBusinessSectorIds = const {},
    this.selectedSkillName = '',
    this.searchQuery = '',
  });

  /// Filter kosong → tidak ada filter aktif.
  bool get isEmpty =>
      selectedRatings.isEmpty &&
      selectedExperiences.isEmpty &&
      selectedBusinessSectorIds.isEmpty &&
      selectedSkillName.isEmpty &&
      searchQuery.isEmpty;

  /// True jika ada filter dari bottom sheet yang aktif (bukan role chip / search).
  bool get hasSheetFilter =>
      selectedRatings.isNotEmpty ||
      selectedExperiences.isNotEmpty ||
      selectedBusinessSectorIds.isNotEmpty;

  int get sheetFilterCount =>
      selectedRatings.length +
      selectedExperiences.length +
      selectedBusinessSectorIds.length;

  /// Ratings dalam urutan canonical (5,4,3,2,1), apapun urutan klik user.
  List<int> get sortedRatings => TalentFilterOptions.ratings
      .where(selectedRatings.contains)
      .toList();

  /// Experiences dalam urutan canonical (0-6,7-12,12-24,25), apapun urutan klik user.
  List<String> get sortedExperiences => TalentFilterOptions.experiences
      .map((e) => e.value)
      .where(selectedExperiences.contains)
      .toList();

  TalentFilter copyWith({
    Set<int>? selectedRatings,
    Set<String>? selectedExperiences,
    Set<int>? selectedBusinessSectorIds,
    String? selectedSkillName,
    String? searchQuery,
  }) {
    return TalentFilter(
      selectedRatings: selectedRatings ?? this.selectedRatings,
      selectedExperiences: selectedExperiences ?? this.selectedExperiences,
      selectedBusinessSectorIds:
          selectedBusinessSectorIds ?? this.selectedBusinessSectorIds,
      selectedSkillName: selectedSkillName ?? this.selectedSkillName,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Reset semua filter ke keadaan kosong.
  static const TalentFilter empty = TalentFilter();
}

/// Konstanta pilihan filter yang tersedia.
abstract final class TalentFilterOptions {
  /// Rating bintang yang tersedia.
  static const List<int> ratings = [5, 4, 3, 2, 1];

  /// Range pengalaman (value dikirim ke API, label tampil ke user).
  static const List<TalentExperienceOption> experiences = [
    TalentExperienceOption(value: '0-6', label: '0-6 Bulan'),
    TalentExperienceOption(value: '7-12', label: '7-12 Bulan'),
    TalentExperienceOption(value: '12-24', label: '1-2 Tahun'),
    TalentExperienceOption(value: '25', label: '> 2 Tahun'),
  ];

  /// Daftar role hardcode untuk quick-filter chip.
  /// Value '' = "Semua" → API dipanggil tanpa skill_name.
  static const List<TalentRoleOption> roles = [
    TalentRoleOption(label: 'Semua', value: ''),
    TalentRoleOption(label: 'Customer Service', value: 'customer service'),
    TalentRoleOption(label: 'Admin Marketplace', value: 'admin marketplace'),
    TalentRoleOption(label: 'Advertiser', value: 'advertiser'),
    TalentRoleOption(label: 'Live Streamer', value: 'live streamer'),
  ];
}

/// Pasangan value–label untuk filter pengalaman.
class TalentExperienceOption {
  final String value;
  final String label;

  const TalentExperienceOption({required this.value, required this.label});
}

/// Pasangan value–label untuk filter role (quick-filter chip).
class TalentRoleOption {
  final String value;
  final String label;

  const TalentRoleOption({required this.value, required this.label});
}
