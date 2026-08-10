/// UI model untuk satu anggota tim pada halaman Daftar Tim.
///
/// Model ini murni untuk kebutuhan tampilan. Ketika endpoint tersedia,
/// mapping dari response API bisa ditambahkan lewat factory `fromJson`.
class TeamMemberModel {
  final String name;
  final String email;
  final String avatarUrl;

  /// Peran/role anggota, mis. "Talent Acquisition".
  /// Jika `null`, kartu menampilkan tombol menu (…) alih-alih tag peran.
  final String? role;

  /// Apakah anggota sudah terverifikasi (badge centang biru).
  final bool isVerified;

  /// Daftar hak akses, mis. ["DASHBOARD", "PRODUK", "GUDANG", ...].
  final List<String> accessList;

  const TeamMemberModel({
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.role,
    this.isVerified = false,
    this.accessList = const [],
  });

  /// Hak akses digabung menjadi satu baris, mis. "DASHBOARD, PRODUK, GUDANG".
  String get accessLabel => accessList.join(', ');
}
