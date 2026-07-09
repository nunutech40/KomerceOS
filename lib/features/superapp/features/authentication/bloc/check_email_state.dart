part of 'check_email_bloc.dart';

@immutable
abstract class CheckEmailState extends Equatable {
  const CheckEmailState();

  @override
  List<Object?> get props => [];
}

/// State awal — belum ada aksi
class CheckEmailInitial extends CheckEmailState {}

/// Sedang memanggil API
class CheckEmailLoading extends CheckEmailState {}

/// Email terdaftar dan allowed_login == true → lanjut ke LoginPage
class CheckEmailFound extends CheckEmailState {
  final String email;

  const CheckEmailFound({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Email terdaftar tapi allowed_login == false → tampilkan VerificationRequiredPage
class CheckEmailNotAllowed extends CheckEmailState {
  final String email;
  final List<PartnerProductModel> partnerProducts;

  const CheckEmailNotAllowed({
    required this.email,
    required this.partnerProducts,
  });

  @override
  List<Object?> get props => [email, partnerProducts];
}

/// Email belum terdaftar → tampilkan tombol daftar
class CheckEmailUnregistered extends CheckEmailState {
  const CheckEmailUnregistered();
}

/// Akun di-banned oleh admin → tampilkan Bottom Sheet "Akun Tidak Aktif"
class CheckEmailBanned extends CheckEmailState {
  const CheckEmailBanned();
}

/// Error dari API atau jaringan
class CheckEmailFailure extends CheckEmailState {
  final String message;

  const CheckEmailFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
