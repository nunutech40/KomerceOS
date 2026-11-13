import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/datasources/preferences/secure_storage_service.dart';
import 'package:komtim_partner/core/data/datasources/preferences/shared_pref.dart';
import 'package:komtim_partner/core/data/datasources/remote/auth_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/invoice_remote_datasource.dart';
import 'package:komtim_partner/core/data/repositories/superapp_profile_repository_impl.dart';
import 'package:komtim_partner/core/domain/managers/authentication_manager.dart';
import 'package:komtim_partner/core/domain/repositories/attendance_repository.dart';
import 'package:komtim_partner/core/domain/repositories/auth_repository.dart';
import 'package:komtim_partner/core/domain/repositories/invoice_repository.dart';
import 'package:komtim_partner/core/domain/repositories/report_performance_repository.dart';
import 'package:komtim_partner/core/domain/repositories/profile_repository.dart';
import 'package:komtim_partner/core/domain/usecases/change_password_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/check_email_login_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/do_login_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/do_logout_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_profile_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/partner_login_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/request_login_otp_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/send_forgot_password_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/recaptcha_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/verify_login_otp_use_case.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'mock_blocs.dart';
export 'mocks.mocks.dart';

@GenerateMocks([
  DioClient,
  DioResponseParser,
  SharedPreferences,
  FlutterSecureStorage,
  InvoiceRemoteDataSource,
  AuthRemoteDataSource,
  SecureStorageService,
  SharedPref,
  SuperappProfileRepository,
  InvoiceRepository,
  ReportPerformanceRepository,
  AuthRepository,
  ProfileRepository,
  AttendanceRepostiory,
  AuthenticationManager,
  DoLoginUseCase,
  CheckEmailLoginUseCase,
  PartnerLoginUseCase,
  RequestLoginOtpUseCase,
  VerifyLoginOtpUseCase,
  DoLogoutUseCase,
  SendForgotPasswordUseCase,
  ChangePasswordUseCase,
  GetProfileUseCase,
  RecaptchaUseCase,
])
void main() {}
