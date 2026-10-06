import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/core/domain/entities/bank_accounts_model.dart';
import '../bloc/bank_account_cubit.dart';
import '../domain/entities/bank_account_entry.dart';

import '../widget/profile_form_card.dart';
import '../widget/profile_option_sheet.dart';
import '../domain/entities/setting_profile.dart';
import 'sections/profile_section_fields.dart';
import 'setting_profile_page.dart';

enum _BankAccountStep { list, form, method, otp }

class BankAccountPage extends StatefulWidget {
  const BankAccountPage({
    super.key,
    this.loadAccounts,
    this.lookupOwner,
    this.controller,
  });

  final Future<List<BankAccountsDataModel>> Function()? loadAccounts;
  final Future<String?> Function(String bank, String number)? lookupOwner;
  final BankAccountCubit? controller;

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  static const _banks = ['Permata', 'BCA', 'BRI', 'BNI', 'Mandiri'];
  static const _maxAccounts = 6;
  BankAccountCubit? _ownedCubit;
  BankAccountCubit get _cubit =>
      widget.controller ?? (_ownedCubit ??= di.locator<BankAccountCubit>());

  String _accountNumber = '';
  final _otpController = TextEditingController();
  _BankAccountStep _step = _BankAccountStep.list;
  String? _bank;
  String? _bankCode;
  String? _ownerName;
  String? _otpMethod;
  String? _otpToken;
  DateTime? _otpNextRequestAt;
  DateTime? _otpExpiresAt;
  String? _error;
  bool _ownerNotFound = false;
  bool _checkingOwner = false;
  bool _loadingAccounts = true;
  bool _working = false;
  int _resendSeconds = 0;
  List<AvailableBank> _availableBanks = [];
  Timer? _resendTimer;
  List<BankAccountsDataModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAccounts());
  }

  Future<void> _loadAccounts() async {
    setState(() => _loadingAccounts = true);
    try {
      final accounts = widget.loadAccounts == null
          ? await _loadAccountsFromApi()
          : await widget.loadAccounts!();
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _loadingAccounts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAccounts = false);
      _showErrorSheet(_loadAccounts);
    }
  }

  Future<List<BankAccountsDataModel>> _loadAccountsFromApi() async {
    final result = await _cubit.accounts();
    return result.fold(
      (failure) => throw StateError(failure.message),
      (accounts) => accounts
          .map((account) => BankAccountsDataModel(
                bankAccountsId: account.id,
                bankCode: account.bankName,
                bankName: account.bankName,
                bankOwnerName: account.accountName,
                bankOwnerNumber: account.accountNo,
              ))
          .toList(),
    );
  }

  Future<void> _showErrorSheet(Future<void> Function() retry) async {
    await DsBottomSheet.show<void>(
      context: context,
      title: 'Oops, Terjadi Kesalahan',
      titleStyle: AppTypography.headingXs,
      description:
          'Terjadi kendala saat mengambil data.\nSilakan muat ulang halaman untuk\nmencoba kembali.',
      image: SvgPicture.asset('assets/images/superapp/setting/failed_img.svg',
          width: 240, height: 240),
      secondaryButtonText: 'Kembali',
      secondaryButtonColor: AppColors.primaryBase,
      onSecondaryPressed: () => Navigator.of(context).pop(),
      primaryButtonText: 'Coba Lagi',
      barrierColor: const Color(0x66000000),
      onPrimaryPressed: () {
        Navigator.of(context).pop();
        retry();
      },
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    _ownedCubit?.close();
    super.dispose();
  }

  String get _title => switch (_step) {
        _BankAccountStep.list => 'Rekening Bank',
        _BankAccountStep.form => 'Tambah Rekening Bank',
        _BankAccountStep.method => 'Pilih Metode Verifikasi',
        _BankAccountStep.otp => 'Verifikasi OTP',
      };

  bool get _canConfirm =>
      _bankCode != null &&
      _accountNumber.trim().length >= 5 &&
      _ownerName?.trim().isNotEmpty == true &&
      !_ownerNotFound && _error == null && !_working;

  void _back() {
    if (_step == _BankAccountStep.list) {
      Navigator.of(context).pop();
      return;
    }
    if (_step == _BankAccountStep.otp) {
      _resendTimer?.cancel();
      _resendSeconds = 0;
      _otpController.clear();
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

  Future<void> _lookupOwner() async {
    if (_checkingOwner) return;
    if (_bankCode == null || _accountNumber.trim().length < 5) {
      setState(
          () => _error = 'Pilih bank dan masukkan nomor rekening yang valid.');
      return;
    }
    final bank = _bankCode!;
    final number = _accountNumber.trim();
    setState(() {
      _checkingOwner = true;
      _ownerName = null;
      _ownerNotFound = false;
      _error = null;
    });
    try {
      final owner = widget.lookupOwner == null
          ? (await _cubit.owner(bank, number)).fold<String?>(
              (failure) => throw StateError(failure.message),
              (name) => name,
            )
          : await widget.lookupOwner!(bank, number);
      if (!mounted) return;
      if (_bankCode != bank || _accountNumber.trim() != number) return;
      if (owner != null && widget.lookupOwner == null) {
        final userId = context.read<SuperappProfileBloc>().state.displayProfile?.id;
        if (userId == null) throw StateError('ID pengguna belum tersedia');
        final duplicate = await _cubit.checkDuplicate(bank, owner, number, userId);
        duplicate.fold(
          (failure) => throw StateError(failure.message),
          (_) {},
        );
        if (!mounted || _bankCode != bank || _accountNumber.trim() != number) return;
      }
      setState(() {
        _ownerName = owner?.trim().isNotEmpty == true ? owner!.trim() : null;
        _ownerNotFound = owner == null || owner.isEmpty;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _ownerNotFound = false;
        _error = error.toString().replaceFirst('Bad state: ', '');
      });
    } finally {
      if (mounted) setState(() => _checkingOwner = false);
    }
  }

  void _startResendCountdown(DateTime deadline) {
    _resendTimer?.cancel();
    void tick() {
      if (!mounted) return;
      final remaining = deadline.difference(DateTime.now());
      setState(() => _resendSeconds = remaining.isNegative
          ? 0
          : (remaining.inMicroseconds / Duration.microsecondsPerSecond).ceil());
      if (_resendSeconds == 0) _resendTimer?.cancel();
    }
    tick();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      tick();
    });
  }

  Future<void> _selectBank() async {
    if (widget.lookupOwner == null && _availableBanks.isEmpty) {
      final result = await _cubit.banks();
      if (!mounted) return;
      result.fold(
        (failure) => setState(() => _error = failure.message),
        (banks) => setState(() => _availableBanks = banks),
      );
      if (_availableBanks.isEmpty) return;
    }
    final options = widget.lookupOwner == null
        ? _availableBanks.map((bank) => ProfileOption(id: bank.code, label: bank.name)).toList()
        : _banks.map((bank) => ProfileOption(id: bank, label: bank)).toList();
    final selected = await showModalBottomSheet<ProfileOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileOptionSheet(
        title: 'Pilih Bank',
        options: options,
        selectedId: _bankCode,
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _bank = selected.label;
      _bankCode = selected.id;
      _ownerName = null;
      _ownerNotFound = false;
      _error = null;
    });
  }

  Future<void> _requestOtp(String method) async {
    if (_working) return;
    if (widget.controller == null && _otpToken == null) {
      final restored = await _cubit.restorePendingOtp(method);
      if (!mounted) return;
      restored.fold(
        (_) {},
        (challenge) {
          if (challenge == null) return;
          _otpToken = challenge.token;
          _otpMethod = method;
          _otpNextRequestAt = challenge.nextRequestAt;
          _otpExpiresAt = challenge.expiredAt;
        },
      );
    }
    if (_otpMethod == method && _otpToken != null &&
        _otpNextRequestAt != null &&
        _otpNextRequestAt!.isAfter(DateTime.now())) {
      setState(() {
        _step = _BankAccountStep.otp;
        _error = _otpExpiresAt != null && _otpExpiresAt!.isBefore(DateTime.now())
            ? 'Kode OTP kedaluwarsa. Tunggu hingga Kirim Ulang tersedia.'
            : null;
      });
      _startResendCountdown(_otpNextRequestAt!);
      return;
    }
    setState(() { _working = true; _error = null; });
    final result = await _cubit.requestOtp(method);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (challenge) {
        _otpToken = challenge.token;
        _otpMethod = method;
        _otpNextRequestAt = challenge.nextRequestAt;
        _otpExpiresAt = challenge.expiredAt;
        _step = _BankAccountStep.otp;
        _startResendCountdown(challenge.nextRequestAt);
      },
    );
    if (mounted) setState(() => _working = false);
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6 || _working || _otpToken == null) return;
    if (_otpExpiresAt != null && _otpExpiresAt!.isBefore(DateTime.now())) {
      setState(() => _error = 'Kode OTP kedaluwarsa. Kirim ulang kode OTP.');
      return;
    }
    setState(() { _working = true; _error = null; });
    final verified = await _cubit.verifyOtp(_otpController.text, _otpToken!);
    if (!mounted) return;
    final valid = verified.fold<bool>(
      (failure) { setState(() => _error = failure.message); return false; },
      (value) => value,
    );
    if (!valid) { setState(() => _working = false); return; }
    final saved = await _cubit.addAccount(
        _otpToken!, _bankCode!, _accountNumber.trim(), _ownerName!);
    if (!mounted) return;
    saved.fold(
      (failure) => setState(() => _error = failure.message),
      (_) {
        _resendTimer?.cancel();
        _otpController.clear();
        _otpToken = null;
        _otpNextRequestAt = null;
        _otpExpiresAt = null;
        _otpMethod = null;
        _step = _BankAccountStep.list;
        _loadAccounts();
        _showSuccess();
      },
    );
    if (mounted) setState(() => _working = false);
  }

  Future<void> _showSuccess() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.bgPopup,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height:
                (MediaQuery.sizeOf(context).height * .72).clamp(420.0, 650.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.grey600),
                  ),
                ),
                const Text('Rekening Berhasil\nDitambahkan',
                    style: AppTypography.headingXs,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                    'Selamat! Nomor rekening berhasil\nditambahkan di akun kamu',
                    style: AppTypography.bodySmRegular
                        .copyWith(color: AppColors.grey600),
                    textAlign: TextAlign.center),
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                        'assets/images/ilustrated-success.svg',
                        height: 240),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DsButton(text: 'Oke', onPressed: () => Navigator.pop(context)),
              ],
            ),
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
                loadingText: _step == _BankAccountStep.otp
                    ? 'Memverifikasi OTP...'
                    : null,
                state: _working
                    ? DsButtonState.loading
                    : _step == _BankAccountStep.list &&
                            _accounts.length >= _maxAccounts ||
                        _step == _BankAccountStep.form && !_canConfirm ||
                        _step == _BankAccountStep.otp &&
                            _otpController.text.length != 6
                    ? DsButtonState.disabled
                    : DsButtonState.enabled,
                onPressed: () {
                  switch (_step) {
                    case _BankAccountStep.list:
                      if (widget.loadAccounts == null) {
                        final profile = context.read<SuperappProfileBloc>().state.displayProfile;
                        if (profile?.address?.trim().isNotEmpty != true ||
                            profile?.gender == null) {
                          DsBottomSheet.show<void>(
                            context: context,
                            title: 'Profil Belum Lengkap Nih',
                            description: 'Untuk melanjutkan, silakan lengkapi profil Anda.',
                            primaryButtonText: 'Lengkapi Profil',
                            onPrimaryPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute<void>(
                                builder: (_) => const SettingProfilePage(),
                              ));
                            },
                          );
                          return;
                        }
                      }
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
        if (_loadingAccounts) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(color: AppColors.primaryBase),
          ));
        }
        return _accounts.isEmpty ? _emptyState() : _accountList();
      case _BankAccountStep.form:
        return _form();
      case _BankAccountStep.method:
        return Column(children: [
          _methodPicker(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(_error!,
                  style: AppTypography.bodySmRegular
                      .copyWith(color: AppColors.errorBase)),
            ),
        ]);
      case _BankAccountStep.otp:
        return _otpPage();
    }
  }

  Widget _emptyState() => SizedBox(
        height: 620,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/ic_empty.svg',
                width: 235, height: 210),
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
              maxLength: 20,
              onChanged: (value) => setState(() {
                _accountNumber = value;
                _ownerName = null;
                _ownerNotFound = false;
                _error = null;
              }),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          ProfileFormCard(children: [
            ProfileFormRow(
              label: 'Nama Pemilik',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      _ownerName ?? 'Cek untuk tampilkan nama',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmRegular.copyWith(
                        color: _ownerName == null
                            ? AppColors.grey600
                            : AppColors.alwaysBlack,
                      ),
                    ),
                  ),
                  if (_ownerName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('✓ Ditemukan',
                          style: AppTypography.bodySmRegular.copyWith(
                              color: AppColors.successBase, fontSize: 10)),
                    ),
                  if (_ownerNotFound)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('× Tidak Ditemukan',
                          style: AppTypography.bodySmRegular.copyWith(
                              color: AppColors.errorBase, fontSize: 10)),
                    ),
                ]),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _checkingOwner ? null : _lookupOwner,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.primaryBase,
                ),
                child: _checkingOwner
                    ? const Row(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.5, color: AppColors.grey600)),
                        SizedBox(width: 8),
                        Text('Cek Nama Pemilik Bank'),
                      ])
                    : const Text('Cek Nama Pemilik Bank'),
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

  String get _maskedPhone {
    if (widget.loadAccounts != null) return '+62 *** ****899';
    final phone = context.read<SuperappProfileBloc>().state.displayProfile?.noHp ?? '';
    if (phone.length < 4) return 'nomor terdaftar';
    return '${phone.substring(0, phone.length > 6 ? 3 : 1)} *** ****${phone.substring(phone.length - 3)}';
  }

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
              'Kode OTP akan dikirim ke nomor WhatsApp\n$_maskedPhone',
              'whatsapp'),
          const SizedBox(height: AppSpacing.md),
          _methodTile(Icons.sms_outlined, 'SMS OTP',
              'Kode OTP akan dikirim via SMS ke nomor\n$_maskedPhone', 'sms'),
        ],
      );

  Widget _methodTile(
          IconData icon, String title, String subtitle, String method) =>
      Material(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _working ? null : () => _requestOtp(method),
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
              obscureText: true,
              centerInputGroups: true,
              showVisibilityToggle: false,
              enableOneTimeCodeAutofill: true,
              autoFocus: true,
              onChanged: (_) => setState(() {})),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(_error!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmRegular
                      .copyWith(color: AppColors.errorBase)),
            ),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
              onPressed: _resendSeconds == 0
                  ? () async {
                      _otpController.clear();
                      if (_otpMethod != null) await _requestOtp(_otpMethod!);
                    }
                  : null,
              child: Text(_resendSeconds == 0
                  ? 'Kirim Ulang'
                  : 'Kirim Ulang ($_resendSeconds detik)')),
        ],
      );

  Widget _accountList() => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: ProfileFormCard(children: [
          for (final account in _accounts) _accountCard(account),
        ]),
      );

  Widget _accountCard(BankAccountsDataModel account) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.account_balance_outlined)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(account.bankOwnerName ?? 'Nama tidak tersedia',
                    style: AppTypography.bodyMdMedium),
                Text(
                    '${account.bankName ?? '-'}  •  ${account.bankOwnerNumber ?? '-'}',
                    style: const TextStyle(color: AppColors.grey600))
              ])),
          const Icon(Icons.chevron_right_rounded)
        ]),
      );
}
