import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class BankPinVerificationResult {
  const BankPinVerificationResult({
    required this.isValid,
    this.attemptsLeft,
    this.locked = false,
  });

  final bool isValid;
  final int? attemptsLeft;
  final bool locked;
}

class BankAccountPinSheet extends StatefulWidget {
  const BankAccountPinSheet({
    super.key,
    required this.onVerify,
    required this.onForgotPin,
    required this.onLocked,
  });

  final Future<BankPinVerificationResult> Function(String pin) onVerify;
  final VoidCallback onForgotPin;
  final VoidCallback onLocked;

  @override
  State<BankAccountPinSheet> createState() => _BankAccountPinSheetState();
}

class _BankAccountPinSheetState extends State<BankAccountPinSheet> {
  final _controller = TextEditingController();
  bool _verifying = false;
  String? _error;
  int? _attemptsLeft;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_controller.text.length != 6 || _verifying) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final result = await widget.onVerify(_controller.text);
      if (!mounted) return;
      if (result.isValid) {
        Navigator.of(context).pop(true);
      } else if (result.locked || result.attemptsLeft == 0) {
        Navigator.of(context).pop(false);
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onLocked());
      } else {
        setState(() {
          _attemptsLeft = result.attemptsLeft;
          _error = _attemptsLeft == null
              ? 'PIN yang kamu masukkan salah.'
              : 'PIN yang kamu masukkan salah.\nTersisa $_attemptsLeft kali percobaan';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(
          () => _error = 'Terjadi kendala saat memverifikasi PIN. Coba lagi.');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height -
        media.viewInsets.bottom -
        media.viewPadding.top -
        AppSpacing.md;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: availableHeight.clamp(0, double.infinity)),
        child: Container(
          margin:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin2xs),
          decoration: const BoxDecoration(
            color: AppColors.bgPopup,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.insetLg,
                  AppSpacing.xl,
                  AppSpacing.insetLg,
                  AppSpacing.insetLg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Masukkan 6 Digit PIN Kamu',
                            textAlign: TextAlign.center,
                            style: AppTypography.headingMd
                                .copyWith(color: AppColors.grey900),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppRadius.circular),
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: const BoxDecoration(
                                color: AppColors.bgLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 30, color: AppColors.grey700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    DsOtpField(
                      controller: _controller,
                      obscureText: true,
                      centerInputGroups: true,
                      showVisibilityToggle: false,
                      grouped: false,
                      boxSize: 44,
                      isEnabled: !_verifying,
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmRegular
                              .copyWith(color: AppColors.errorBase)),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: _verifying ? null : widget.onForgotPin,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBase,
                        textStyle: AppTypography.bodyMdMedium,
                        minimumSize:
                            const Size(double.infinity, AppSpacing.touchSm),
                      ),
                      child: const Text('Lupa PIN?'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    DsButton(
                      text: 'Konfirmasi',
                      loadingText: 'Memverifikasi PIN...',
                      state: _verifying
                          ? DsButtonState.loading
                          : _controller.text.length == 6
                              ? DsButtonState.enabled
                              : DsButtonState.disabled,
                      onPressed: _verify,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
