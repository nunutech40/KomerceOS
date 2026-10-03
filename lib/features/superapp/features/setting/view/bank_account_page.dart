import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

import '../widget/profile_form_card.dart';
import '../widget/profile_option_sheet.dart';
import '../domain/entities/setting_profile.dart';
import 'sections/profile_section_fields.dart';

enum _BankAccountStep { list, form, method, otp }

class BankAccountPage extends StatefulWidget {
  const BankAccountPage({super.key});

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  static const _banks = ['Permata', 'BCA', 'BRI', 'BNI', 'Mandiri'];

  String _accountNumber = '';
  final _otpController = TextEditingController();
  _BankAccountStep _step = _BankAccountStep.list;
  String? _bank;
  String? _ownerName;
  String? _otpMethod;
  String? _error;
  bool _hasAccount = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String get _title => switch (_step) {
        _BankAccountStep.list => 'Rekening Bank',
        _BankAccountStep.form => 'Tambah Rekening Bank',
        _BankAccountStep.method => 'Pilih Metode Verifikasi',
        _BankAccountStep.otp => 'Verifikasi OTP',
      };

  bool get _canConfirm =>
      _bank != null && _accountNumber.trim().length >= 8 && _ownerName != null;

  void _back() {
    if (_step == _BankAccountStep.list) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _error = null;
      _step = switch (_step) {
        _BankAccountStep.form => _BankAccountStep.list,
        _BankAccountStep.method => _BankAccountStep.form,
        _BankAccountStep.otp => _BankAccountStep.method,
        _BankAccountStep.list => _BankAccountStep.list,
      };
    });
  }

  void _lookupOwner() {
    if (_bank == null || _accountNumber.trim().length < 8) {
      setState(
          () => _error = 'Pilih bank dan masukkan nomor rekening yang valid.');
      return;
    }
    setState(() {
      _ownerName = 'Jhon Doe Assqaf';
      _error = null;
    });
  }

  Future<void> _selectBank() async {
    final selected = await showModalBottomSheet<ProfileOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileOptionSheet(
        title: 'Pilih Bank',
        options:
            _banks.map((bank) => ProfileOption(id: bank, label: bank)).toList(),
        selectedId: _bank,
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _bank = selected.id;
      _ownerName = null;
      _error = null;
    });
  }

  void _verifyOtp() {
    if (_otpController.text.length != 6) return;
    setState(() {
      _hasAccount = true;
      _step = _BankAccountStep.list;
      _otpMethod = null;
      _otpController.clear();
    });
    _showSuccess();
  }

  Future<void> _showSuccess() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon:
                      const Icon(Icons.close_rounded, color: AppColors.grey600),
                ),
              ),
              const Text('Rekening Berhasil\nDitambahkan',
                  style: AppTypography.headingXs, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text('Selamat! Nomor rekening berhasil\nditambahkan di akun kamu',
                  style: AppTypography.bodySmRegular
                      .copyWith(color: AppColors.grey600),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              SvgPicture.asset('assets/images/ilustrated-success.svg',
                  height: 240),
              const SizedBox(height: AppSpacing.sm),
              DsButton(text: 'Oke', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DsAppBar(
          title: _title,
          onBackPressed: _back,
          backgroundColor: AppColors.alwaysWhite),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _buildBody())),
          if (_step != _BankAccountStep.method)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
              child: DsButton(
                text: switch (_step) {
                  _BankAccountStep.list => 'Tambah Rekening',
                  _BankAccountStep.form => 'Konfirmasi',
                  _BankAccountStep.otp => 'Verifikasi',
                  _BankAccountStep.method => '',
                },
                state: _step == _BankAccountStep.form && !_canConfirm ||
                        _step == _BankAccountStep.otp &&
                            _otpController.text.length != 6
                    ? DsButtonState.disabled
                    : DsButtonState.enabled,
                onPressed: () {
                  switch (_step) {
                    case _BankAccountStep.list:
                      setState(() => _step = _BankAccountStep.form);
                    case _BankAccountStep.form:
                      setState(() => _step = _BankAccountStep.method);
                    case _BankAccountStep.otp:
                      _verifyOtp();
                    case _BankAccountStep.method:
                      break;
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _BankAccountStep.list:
        return _hasAccount ? _accountCard() : _emptyState();
      case _BankAccountStep.form:
        return _form();
      case _BankAccountStep.method:
        return _methodPicker();
      case _BankAccountStep.otp:
        return _otpPage();
    }
  }

  Widget _emptyState() => SizedBox(
        height: 620,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/bank.svg', width: 235, height: 190),
            const SizedBox(height: AppSpacing.lg),
            const Text('Tidak Ada Rekening Bank',
                style: AppTypography.headingXs),
            const SizedBox(height: AppSpacing.xs),
            Text(
                'Belum ada data rekening bank yang ditampilkan.\nYuk tambahkan rekening kamu di sini',
                style: AppTypography.bodySmRegular
                    .copyWith(color: AppColors.grey600),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _form() => Column(
        children: [
          ProfileFormCard(children: [
            ProfilePickerField(
              label: 'Nama Bank',
              value: _bank,
              hint: 'Pilih Bank',
              onTap: _selectBank,
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          ProfileFormCard(children: [
            ProfileTextField(
              label: 'No. Rekening',
              value: _accountNumber,
              hint: 'Masukkan nomor rekening',
              numeric: true,
              onChanged: (value) => setState(() {
                _accountNumber = value;
                _ownerName = null;
                _error = null;
              }),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          ProfileFormCard(children: [
            ProfileReadonlyField(
              label: 'Nama Pemilik',
              value: _ownerName ?? 'Cek untuk tampilkan nama',
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _lookupOwner,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.primaryBase,
                ),
                child: const Text('Cek Nama Pemilik Bank'),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_error!,
                      style: AppTypography.bodySmRegular
                          .copyWith(color: AppColors.errorBase)),
                ),
              ),
          ]),
        ],
      );

  Widget _methodPicker() => Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          SvgPicture.asset('assets/images/superapp/auth/verify_code_email.svg',
              width: 150, height: 150),
          const SizedBox(height: AppSpacing.md),
          Text(
              'Pilih metode pengiriman kode OTP untuk\nmemverifikasi penambahan rekening bank kamu',
              style: AppTypography.bodySmRegular
                  .copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          _methodTile(
              Icons.chat_bubble_outline_rounded,
              'WhatsApp OTP',
              'Kode OTP akan dikirim ke nomor WhatsApp\n+62 *** ****899',
              'whatsapp'),
          const SizedBox(height: AppSpacing.md),
          _methodTile(Icons.mail_outline_rounded, 'SMS OTP',
              'Kode OTP akan dikirim via SMS ke nomor\n+62 *** ****899', 'sms'),
        ],
      );

  Widget _methodTile(
          IconData icon, String title, String subtitle, String method) =>
      Material(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => setState(() {
            _otpMethod = method;
            _step = _BankAccountStep.otp;
          }),
          child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(children: [
                Icon(icon, color: AppColors.grey600),
                const SizedBox(width: AppSpacing.md),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: AppTypography.bodyMdMedium),
                  Text(subtitle,
                      style: AppTypography.bodySmRegular
                          .copyWith(color: AppColors.grey600))
                ])
              ])),
        ),
      );

  Widget _otpPage() => Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          SvgPicture.asset('assets/images/superapp/auth/verify_code_email.svg',
              width: 150, height: 150),
          const SizedBox(height: AppSpacing.md),
          const Text('Masukkan Kode OTP', style: AppTypography.headingXs),
          const SizedBox(height: AppSpacing.sm),
          Text(
              'Kode OTP dikirim melalui ${_otpMethod == 'whatsapp' ? 'WhatsApp' : 'SMS'} ke nomor terdaftar.',
              style: AppTypography.bodySmRegular
                  .copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          DsOtpField(
              controller: _otpController,
              obscureText: false,
              centerInputGroups: true,
              autoFocus: true,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
              onPressed: () {}, child: const Text('Kirim Ulang (30 detik)')),
        ],
      );

  Widget _accountCard() => Container(
        margin: const EdgeInsets.only(top: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x12000000), blurRadius: 5, offset: Offset(0, 2))
            ]),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.account_balance_outlined)),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Jhon Doe Assqaf', style: AppTypography.bodyMdMedium),
                Text('BCA  •  0028911987',
                    style: TextStyle(color: AppColors.grey600))
              ])),
          const Icon(Icons.chevron_right_rounded)
        ]),
      );
}
