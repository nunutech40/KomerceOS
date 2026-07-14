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

  const AplikasikuLoaded(
    this.data, {
    this.isResending = false,
    this.resendMessage,
    this.resendCountDown,
  });

  AplikasikuLoaded copyWith({
    List<AplikasiItemEntity>? data,
    bool? isResending,
    String? resendMessage,
    int? resendCountDown,
  }) {
    return AplikasikuLoaded(
      data ?? this.data,
      isResending: isResending ?? this.isResending,
      resendMessage: resendMessage,
      resendCountDown: resendCountDown,
    );
  }

  @override
  List<Object?> get props => [data, isResending, resendMessage, resendCountDown];
}

class AplikasikuError extends AplikasikuState {
  final String message;

  const AplikasikuError(this.message);

  @override
  List<Object?> get props => [message];
}
