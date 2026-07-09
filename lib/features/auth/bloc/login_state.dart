part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.username = '',
      this.password = '',
      this.fcmToken = '',
      this.passwordErrorMessage = '',
      this.usernameErrorMessage = '',
      this.isVerificationRequired = false,
      this.isEmailChecked = false,
      this.isAccountBanned = false,
      this.unverifiedProducts = const []});

  final String message;
  final RequestStatus status;
  final String username;
  final String password;
  final String fcmToken;
  final String usernameErrorMessage;
  final String passwordErrorMessage;
  final bool isVerificationRequired;
  final bool isEmailChecked;
  final bool isAccountBanned;
  final List<PartnerProductModel> unverifiedProducts;

  LoginState copyWith({
    String? username,
    String? password,
    String? fcmToken,
    RequestStatus? status,
    String? message,
    String? usernameErrorMessage, // Add this
    String? passwordErrorMessage, // Add this
    bool? isVerificationRequired,
    bool? isEmailChecked,
    bool? isAccountBanned,
    List<PartnerProductModel>? unverifiedProducts,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      fcmToken: fcmToken ?? this.fcmToken,
      message: message ?? this.message,
      usernameErrorMessage:
          usernameErrorMessage ?? this.usernameErrorMessage, // And this
      passwordErrorMessage:
          passwordErrorMessage ?? this.passwordErrorMessage, // And this
      isVerificationRequired: isVerificationRequired ?? false, // Do not persist state to avoid infinite loops
      isEmailChecked: isEmailChecked ?? this.isEmailChecked,
      isAccountBanned: isAccountBanned ?? false, // Do not persist state to avoid infinite loops
      unverifiedProducts: unverifiedProducts ?? this.unverifiedProducts,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        username,
        password,
        fcmToken,
        usernameErrorMessage,
        passwordErrorMessage,
        isVerificationRequired,
        isEmailChecked,
        isAccountBanned,
        unverifiedProducts,
      ];
}
