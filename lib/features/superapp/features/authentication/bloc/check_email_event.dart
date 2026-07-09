part of 'check_email_bloc.dart';

@immutable
abstract class CheckEmailEvent extends Equatable {
  const CheckEmailEvent();

  @override
  List<Object?> get props => [];
}

/// User menekan tombol "Lanjutkan" dengan email yang valid
class CheckEmailSubmitted extends CheckEmailEvent {
  final String email;

  const CheckEmailSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}

/// Reset state ke initial (misal: user edit email setelah hasil muncul)
class CheckEmailReset extends CheckEmailEvent {
  const CheckEmailReset();
}
