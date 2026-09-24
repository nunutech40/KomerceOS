import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/loading/loading_overlay.dart';
import 'package:komtim_partner/features/pin/bloc/pin_bloc.dart';

/// Halaman pemilih metode OTP untuk flow lupa PIN.
/// Saat ini hanya email yang tersedia — kartu WA dinonaktifkan.
class ChooseOtpMethodPage extends StatefulWidget {
  final String? email;
  final String? invoiceId;
  final String? xenditUrl;

  const ChooseOtpMethodPage({
    Key? key,
    this.email,
    this.invoiceId,
    this.xenditUrl,
  }) : super(key: key);

  @override
  State<ChooseOtpMethodPage> createState() => _ChooseOtpMethodPageState();
}

class _ChooseOtpMethodPageState extends State<ChooseOtpMethodPage> {
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

  void _requestOtp() {
    context.read<PinBloc>().add(ForgetPinEvent());
  }

  @override
  void initState() {
    super.initState();
    // Jika email belum tersedia (dari query), ambil dari profil lokal (SharedPreferences)
    // tanpa memanggil API — konsisten dengan pola GetLocaleProfileUseCase.
    if (widget.email == null || widget.email!.isEmpty) {
      context.read<PinBloc>().add(GetProfileLocalEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PinBloc, PinState>(
      listener: (context, state) {
        if (state.status == RequestStatus.success &&
            state.operation == 'forgetPin') {
          final email = widget.email ?? state.profileData?.email ?? '';
          final queryParams = <String, String>{
            'email': email,
            'time': state.expiredAt?.expiredAt ?? '',
          };

          if (widget.invoiceId != null && widget.invoiceId!.isNotEmpty) {
            queryParams['invoiceId'] = widget.invoiceId!;
          }
          if (widget.xenditUrl != null && widget.xenditUrl!.isNotEmpty) {
            queryParams['xenditUrl'] = widget.xenditUrl!;
          }

          final query = Uri(queryParameters: queryParams).query;
          AppRouter.router
              .push('${PAGES.pinOtpVerification.screenPath}?$query');
        }
      },
      builder: (context, state) {
        final bool isLoading = state.status == RequestStatus.loading &&
            state.operation == 'forgetPin';
        final email = widget.email ?? state.profileData?.email ?? '';

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text(Strings.label_forgot_pin,
                    style: AppTypography.interSemiBold16),
              ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                      child: SvgPicture.asset(
                        'assets/images/superapp/auth/verify_code_email.svg',
                        height: 120,
                        width: 120,
                      ),
                    ),
                    const Text(
                      Strings.label_choose_otp_method,
                      style: AppTypography.semiBold20,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      Strings.label_otp_sent_to,
                      style: AppTypography.regular14grey73,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24.0),
                    InkWell(onTap: _requestOtp, child: _buildEmailCard(email)),
                  ],
                ),
              ),
            ),
            if (isLoading) const LoadingOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildEmailCard(String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.borderColorEAEA, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.email_outlined,
            size: 22,
            color: gray737373,
            weight: 0.5,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(Strings.label_via_email,
                    style: AppTypography.semiBold14),
                const SizedBox(height: 4.0),
                Text("${Strings.label_otp_via_email_desc} ${maskEmail(email)}",
                    style: AppTypography.regular12Grey737373),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsappCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.chat_bubble_outline, color: inActiveGray),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Strings.label_via_whatsapp,
                    style:
                        AppTypography.semiBold14.copyWith(color: inActiveGray)),
                const SizedBox(height: 4.0),
                const Text(Strings.label_otp_via_wa_desc,
                    style: AppTypography.regular12Grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
