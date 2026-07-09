part of 'verification_bloc.dart';

enum VerificationStatus { idle, loading, success, failure, rateLimited }

@immutable
class VerificationState extends Equatable {
  final PartnerProductModel? selectedProduct;
  final VerificationStatus status;
  final String? errorMessage;
  final int countDown;

  const VerificationState({
    this.selectedProduct,
    this.status = VerificationStatus.idle,
    this.errorMessage,
    this.countDown = 0,
  });

  VerificationState copyWith({
    PartnerProductModel? selectedProduct,
    VerificationStatus? status,
    String? errorMessage,
    int? countDown,
  }) {
    return VerificationState(
      selectedProduct: selectedProduct ?? this.selectedProduct,
      status: status ?? this.status,
      errorMessage: errorMessage,
      countDown: countDown ?? this.countDown,
    );
  }

  @override
  List<Object?> get props => [selectedProduct, status, errorMessage, countDown];
}
