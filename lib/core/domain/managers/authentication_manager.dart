import 'package:flutter/foundation.dart';

import '../../data/datasources/preferences/shared_pref.dart';
import '../entities/auth_state.dart';
import '../entities/login_model.dart';

/// Manajer untuk mengelola status otentikasi aplikasi secara terpusat.
///
/// Kelas ini bertanggung jawab untuk memantau perubahan status login pengguna
/// (seperti initial, checking, authenticated, unauthenticated) dan memberitahukannya
/// ke bagian lain aplikasi (seperti UI) melalui mekanisme [ValueNotifier].
class AuthenticationManager extends ValueNotifier<AuthState> {
  final SharedPref sharedPref;

  AuthenticationManager({required this.sharedPref})
      : super(AuthState.initial());

  /// Helper untuk mendapatkan status otentikasi saat ini dengan mudah.
  AuthStatus get status => value.status;

  /// Helper untuk mendapatkan data user yang sedang login saat ini.
  UserLoginModel? get user => value.user;

  /// Memeriksa status login awal dari [SharedPref] saat aplikasi dimulai.
  ///
  /// Fungsi ini biasanya dipanggil pada saat splash screen atau inisialisasi aplikasi
  /// untuk menentukan apakah pengguna harus diarahkan ke halaman Login atau Halaman Utama.
  Future<void> checkLoginStatus() async {
    // Set status menjadi sedang memeriksa
    value = AuthState.checking();

    // Penundaan buatan untuk interaksi splash screen jika diperlukan
    // await Future.delayed(const Duration(seconds: 2));

    try {
      final isLoggedIn = await sharedPref.isLoggedIn();

      if (isLoggedIn) {
        // Jika token ada, kita anggap user terotentikasi.
        // TODO: Idealnya kita memuat data user lengkap dari local storage jika ada.
        // Saat ini kita menggunakan user placeholder untuk memenuhi kontrak AuthState.authenticated.
        // Data user yang sebenarnya akan diambil oleh HomePageBloc ('getProfile').

        // Asumsi: Jika token ada, maka status Authenticated.
        // Halaman Utama yang akan memicu pengambilan profil ("Get Profile").
        value = AuthState.authenticated(const UserLoginModel(
            id: 0,
            username: '',
            fullName: '',
            email: ''));
      } else {
        // Jika tidak ada token, user belum login
        value = AuthState.unauthenticated();
      }
    } catch (e) {
      // Jika terjadi error saat membaca pref, anggap belum login demi keamanan
      value = AuthState.unauthenticated();
    }
  }

  /// Memperbarui state menjadi terotentikasi setelah login berhasil.
  ///
  /// [newUser] adalah data pengguna yang didapatkan dari respons login API.
  Future<void> login(UserLoginModel newUser) async {
    // Penyimpanan token ke SharedPref ditangani oleh LoginBloc/AuthRepository.
    // Fungsi ini hanya bertujuan untuk memperbarui state aplikasi global.
    value = AuthState.authenticated(newUser);
  }

  /// Melakukan logout sistem.
  ///
  /// Menghapus data sesi dari [SharedPref] dan memperbarui state menjadi unauthenticated.
  Future<void> logout() async {
    // Hapus data preferensi (token, dll)
    await sharedPref.removeDataPref();
    // Perbarui state menjadi belum terotentikasi
    value = AuthState.unauthenticated();
  }
}
