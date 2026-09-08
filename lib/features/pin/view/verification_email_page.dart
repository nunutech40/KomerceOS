import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart'
    as ds;
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/features/pin/bloc/pin_bloc.dart';
import 'package:komtim_partner/features/pin/widget/count_down.dart';

import '../../../common/global/widgets/custom_button.dart';
import '../../../common/styles.dart';

class VerificationEmailPage extends StatefulWidget {
  final String? email;
  final String? time;
  final String? invoiceId;
  final String? xenditUrl;

  const VerificationEmailPage({
    Key? key,
    this.email,
    this.time,
    this.invoiceId,
    this.xenditUrl,
  }) : super(key: key);

  @override
  _verificationEmailPageState createState() => _verificationEmailPageState();
}

class _verificationEmailPageState extends State<VerificationEmailPage> {
  bool isButtonActive = false;
  bool isFailed = false;
  bool isCountdownFinished = false;
  String pinOtp = '';
  int attemptLeft = 0;

  void verifyOtp(String otp) {
    context.read<PinBloc>().add(VerifyOtpEvent(otp: otp));
  }

  @override
  void initState() {
    super.initState();
    // Jika email belum tersedia (dari query), ambil dari profil lokal
    // (SharedPreferences) tanpa memanggil API.
    if (widget.email == null || widget.email!.isEmpty) {
      context.read<PinBloc>().add(GetProfileLocalEvent());
    }
  }

  void resendOtp() {
    context.read<PinBloc>().add(ForgetPinEvent());
  }

  void _saveTime(String time) {
    context.read<PinBloc>().add(SaveTimeEvent(time: time));
  }

  String maskEmail(String email) {
    List<String> parts = email.split('@');

    if (parts.length < 2) {
      return email;
    }
    String username = parts.sublist(0, parts.length - 1).join('@');
    String domain = parts.last;
    String maskedUsername = maskString(username);

    return '$maskedUsername@$domain';
  }

  String maskString(String input) {
    if (input.length <= 3) return input;
    return input.substring(0, 2) +
        '*' * (input.length - 3) +
        input.substring(input.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PinBloc, PinState>(
      listener: (context, state) {
        if (state.status == RequestStatus.success) {
          switch (state.operation) {
            case 'verifyOtp':
              if (state.pinData?.isValid ?? false) {
                AppRouter.router.push(PAGES.pinPage.screenPath, extra: {
                  'pinType': 'updatePin',
                  'doJobFor': 'updateNewPin',
                  'invoiceId': widget.invoiceId,
                  'xenditUrl': widget.xenditUrl,
                });
              } else {
                setState(() {
                  isFailed = true;
                  attemptLeft = state.attemptLeft;
                });
              }
              break;
            case 'forgetPin':
              _saveTime(state.expiredAt?.expiredAt ?? '');
              final emailToUse = widget.email?.isNotEmpty == true
                  ? widget.email!
                  : state.profileData?.email ?? '';
              final invoiceId = widget.invoiceId ?? '';
              final xenditUrl = Uri.encodeComponent(widget.xenditUrl ?? '');
              AppRouter.router.pushReplacement(
                  '${PAGES.pinOtpVerification.screenPath}?email=$emailToUse&time=${state.expiredAt?.expiredAt}&invoiceId=$invoiceId&xenditUrl=$xenditUrl');
              break;
          }
        } else if (state.status == RequestStatus.failure) {
          switch (state.operation) {
            case 'verifyOtp':
              setState(() {
                isFailed = true;
              });
              break;
          }
        }
      },
      builder: (context, state) {
        final bool isLoading = state.status == RequestStatus.loading &&
            state.operation == 'verifyOtp';
        final String email = widget.email ?? state.profileData?.email ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text(Strings.label_verif_email,
                style: AppTypography.interSemiBold16),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: SvgPicture.asset(
                          'assets/images/superapp/auth/verify_code_email.svg',
                          height: 120,
                          width: 120,
                        ),
                      ),
                      const Text(
                        "Masukan Kode OTP",
                        style: AppTypography.semiBold20,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Kode OTP telah dikirimkan melalui email ke ${maskEmail(email)}',
                        style: AppTypography.regular14grey73,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      ds.DsOtpField(
                        obscureText: false,
                        onCompleted: (pin) {
                          setState(() {
                            pinOtp = pin;
                            isButtonActive = true;
                          });
                        },
                        onChanged: (pin) {
                          setState(() {
                            pinOtp = pin;
                            isFailed = false;
                            isButtonActive = pin.length == 6;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // Pesan error merah + ikon ✗ dan sisa percobaan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isFailed) ...[
                            const Icon(Icons.cancel,
                                color: errorColor, size: 16.0),
                            const SizedBox(width: 4.0),
                          ],
                          Text(
                            isFailed
                                ? (attemptLeft > 0
                                    ? '${Strings.label_otp_code_incorrect} • Sisa percobaan $attemptLeft'
                                    : Strings.label_otp_code_incorrect)
                                : '',
                            style: AppTypography.regular12Error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: resendOtp,
                        child: CountdownWidget(
                          targetDate: widget.time,
                          onCountdownFinish: (isFinished) {},
                          isTapped: (tap) {
                            if (isCountdownFinished) {
                              resendOtp();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tombol Verifikasi ter-pin di bawah
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    isActive: isButtonActive && !isLoading,
                    isLoading: isLoading,
                    text: Strings.label_confirm,
                    onPressed: () {
                      verifyOtp(pinOtp);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

