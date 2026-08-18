/// Opsi filter untuk halaman Talent Pool.
///
/// Semua filter bersifat **multi-select**:
/// - [selectedRatings] → daftar bintang yang dipilih (1-5)
/// - [selectedExperiences] → daftar range pengalaman (mis. ["0-6", "7-12"])
/// - [selectedBusinessSectorIds] → daftar ID sektor bisnis dari API
/// - [skillName] → kata kunci role/skill (string pencarian)
class TalentFilter {
  final Set<int> selectedRatings;
  final Set<String> selectedExperiences;
  final Set<int> selectedBusinessSectorIds;
  final String skillName;

  const TalentFilter({
    this.selectedRatings = const {},
    this.selectedExperiences = const {},
    this.selectedBusinessSectorIds = const {},
    this.skillName = '',
  });

  /// Filter kosong → tidak ada filter aktif.
  bool get isEmpty =>
      selectedRatings.isEmpty &&
      selectedExperiences.isEmpty &&
      selectedBusinessSectorIds.isEmpty &&
      skillName.isEmpty;

  TalentFilter copyWith({
    Set<int>? selectedRatings,
    Set<String>? selectedExperiences,
    Set<int>? selectedBusinessSectorIds,
    String? skillName,
  }) {
    return TalentFilter(
      selectedRatings: selectedRatings ?? this.selectedRatings,
      selectedExperiences: selectedExperiences ?? this.selectedExperiences,
      selectedBusinessSectorIds:
          selectedBusinessSectorIds ?? this.selectedBusinessSectorIds,
      skillName: skillName ?? this.skillName,
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
}

/// Pasangan value–label untuk filter pengalaman.
class TalentExperienceOption {
  final String value;
  final String label;

  const TalentExperienceOption({required this.value, required this.label});
}
