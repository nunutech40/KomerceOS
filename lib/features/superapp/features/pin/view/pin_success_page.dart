import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';

/// Halaman sukses ubah PIN (flow lupa PIN via OTP).
/// Setelah 3 detik otomatis kembali ke PaymentMethodPage.
class PinSuccessPage extends StatefulWidget {
  final String? xenditUrl;
  final String? invoiceId;

  const PinSuccessPage({Key? key, this.xenditUrl, this.invoiceId})
      : super(key: key);

  @override
  State<PinSuccessPage> createState() => _PinSuccessPageState();
}

class _PinSuccessPageState extends State<PinSuccessPage> {
  int _countdown = 3;
  Timer? _timer;
  bool _isRedirecting = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        _goToPaymentMethod();
      } else {
        setState(() => _countdown -= 1);
      }
    });
  }

  void _goToPaymentMethod() {
    if (!mounted || _isRedirecting) return;
    _isRedirecting = true;
    final xenditUrl = Uri.encodeComponent(widget.xenditUrl ?? '');
    final invoiceId = widget.invoiceId ?? '';
    AppRouter.router.go(
        '${PAGES.paymentmethod.screenPath}?id=$invoiceId&xenditUrl=$xenditUrl');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: SvgPicture.asset(
                      'assets/images/superapp/auth/success_reset_password.svg',
                      width: MediaQuery.of(context).size.width * 0.7),
                ),
                const SizedBox(height: 32.0),
                const Text(
                  Strings.label_pin_success_title,
                  style: AppTypography.semiBold20,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  '${Strings.label_pin_success_redirect} $_countdown ${Strings.label_seconds}',
                  style: AppTypography.regular14,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
