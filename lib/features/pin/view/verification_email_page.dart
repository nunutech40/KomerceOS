import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/features/pin/bloc/pin_bloc.dart';
import 'package:komtim_partner/features/pin/widget/CountDown.dart';
import 'package:komtim_partner/features/pin/widget/otp_input.dart';

import '../../../common/global/widgets/custom_button.dart';
import '../../../common/styles.dart';

class VerificationEmailPage extends StatefulWidget {
  final String? email;
  final String? time;
  const VerificationEmailPage({Key? key, this.email, this.time})
      : super(key: key);

  @override
  _verificationEmailPageState createState() => _verificationEmailPageState();
}

class _verificationEmailPageState extends State<VerificationEmailPage> {
  bool isButtonActive = false;
  bool isFailed = false;
  String pinOtp = '';
  bool isCountdownFinished = false;

  @override
  void initState() {
    super.initState();
  }

  void verifyOtp(BuildContext localContext, state, String otp) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(VerifyOtpEvent(otp: otp));
  }

  void resendOtp(BuildContext localContext, state) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(ForgetPinEvent());
  }

  void _saveTime(BuildContext localContext, state, String time) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(SaveTimeEvent(time: time));
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
                  'doJobFor': 'updateNewPin'
                });
              } else {
                isFailed = true;
              }
            case 'forgetPin':
              _saveTime(context, state, state.expiredAt?.expiredAt ?? '');
              AppRouter.router.pushReplacement(
                  '${PAGES.pinOtpVerification.screenPath}?email=${widget.email}&time=${state.expiredAt?.expiredAt}');
              break;
          }
        } else if (state.status == RequestStatus.failure) {
          switch (state.operation) {
            case 'verifyOtp':
              isFailed = true;
              break;
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(Strings.label_verif_email,
                style: AppTypography.interSemiBold16),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
                    child: SvgPicture.asset('assets/images/ic_email_otp.svg'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Masukkan Kode OTP email yang telah dikirimkan ke ${maskEmail(widget.email ?? '')}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(
                    child: OtpInput(
                      isFailed: isFailed,
                      onCompleted: (pin) {
                        setState(() {
                          isButtonActive = true;
                        });
                      },
                      onChanged: (pin) {
                        setState(() {
                          pinOtp = pin;
                          isFailed = false;
                          isButtonActive = pin.length == 4;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      isFailed ? Strings.label_otp_code_incorrect : '',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: CountdownWidget(
                        targetDate: widget.time,
                        onCountdownFinish: (isFinished) {
                          if (isFinished) {
                            isCountdownFinished = isFinished;
                          }
                        },
                        isTapped: (tap) {
                          if (isCountdownFinished) {
                            resendOtp(context, state);
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        isActive: isButtonActive,
                        text: Strings.label_confirm,
                        onPressed: () {
                          verifyOtp(context, state, pinOtp);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
