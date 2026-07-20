part of 'aplikasiku_bloc.dart';

abstract class AplikasikuState extends Equatable {
  const AplikasikuState();

  @override
  List<Object?> get props => [];
}

class AplikasikuInitial extends AplikasikuState {}

class AplikasikuLoading extends AplikasikuState {}

class AplikasikuLoaded extends AplikasikuState {
  final List<AplikasiItemEntity> data;
  final bool isResending;
  final String? resendMessage;
  final int? resendCountDown;
  final String? resendEmail;
  final String? resendProductName;

  const AplikasikuLoaded(
    this.data, {
    this.isResending = false,
    this.resendMessage,
    this.resendCountDown,
    this.resendEmail,
    this.resendProductName,
  });

  AplikasikuLoaded copyWith({
    List<AplikasiItemEntity>? data,
    bool? isResending,
    String? resendMessage,
    int? resendCountDown,
    String? resendEmail,
    String? resendProductName,
  }) {
    return AplikasikuLoaded(
      data ?? this.data,
      isResending: isResending ?? this.isResending,
      resendMessage: resendMessage,
      resendCountDown: resendCountDown,
      resendEmail: resendEmail,
      resendProductName: resendProductName,
    );
  }

  @override
  List<Object?> get props => [data, isResending, resendMessage, resendCountDown, resendEmail, resendProductName];
}

class AplikasikuError extends AplikasikuState {
  final String message;

  const AplikasikuError(this.message);

  @override
  List<Object?> get props => [message];
}
