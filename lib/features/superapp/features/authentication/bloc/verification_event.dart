part of 'verification_bloc.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

/// User memilih produk via radio button
class VerificationProductSelected extends VerificationEvent {
  final PartnerProductModel product;

  const VerificationProductSelected(this.product);

  @override
  List<Object?> get props => [product];
}

/// User menekan tombol Kirim Email Verifikasi (dari bottom sheet)
class VerificationEmailSent extends VerificationEvent {
  final String email;

  const VerificationEmailSent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// User menekan "Kirim Ulang" dari halaman EmailVerifSentPage
class VerificationResendEmail extends VerificationEvent {
  final String email;
  final String productName;

  const VerificationResendEmail({
    required this.email,
    required this.productName,
  });

  @override
  List<Object?> get props => [email, productName];
}

/// Reset status setelah handling error/success
class VerificationResetStatus extends VerificationEvent {
  const VerificationResetStatus();
}
