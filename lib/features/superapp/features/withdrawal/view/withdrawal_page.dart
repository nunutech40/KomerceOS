import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/bank_accounts_model.dart';
import 'package:komtim_partner/core/data/datasources/remote/komship_partner_id_resolver.dart';
import 'package:komtim_partner/core/domain/entities/ideal_balance_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_ideal_balance_use_case.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/repositories/bank_account_repository.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/bank_account_page.dart';
import '../data/withdrawal_nominal_checker.dart';
import '../data/datasources/kompay_withdrawal_remote_datasource.dart';
import '../domain/entities/kompay_withdrawal.dart';
import 'withdrawal_balance_sheet.dart';
import 'kompay_mutation_page.dart';
import 'withdrawal_no_bank_sheet.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});
  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  /// Minimal pengajuan penarikan (requirement sprint withdrawal).
  static const _minimum = 12000;
  static const _presets = [12000, 20000, 50000, 100000, 500000, 1000000];
  final _amount = TextEditingController();
  List<BankAccountsDataModel> _banks = [];
  BankAccountsDataModel? _bank;
  bool _loading = true;
  String? _loadError;
  int _ideal = 0;
  int _pending = 0;
  IdealBalanceModel? _idealData;
  int _value = 0;
  int? _preset;
  bool _openBanks = false;
  Timer? _nominalDebounce;
  int? _checkedNominal;
  WithdrawalNominalCheck? _nominalCheck;
  bool _checkingNominal = false;
  String? _nominalCheckError;
  int _nominalRequestVersion = 0;
  bool _submitting = false;
  String? _submitError;

  /// Set when `partner-withdrawal` answers HTTP 400 (queue, per Komship web).
  bool _queuedByServer = false;

  /// A previous withdrawal is still waiting for approval: amount in process
  /// from `balance_analytics`, `withdraw_possibilites == 0` from the nominal
  /// check, or a 400 from the request. Komship web blocks "Ajukan" then.
  bool get _queued =>
      _pending > 0 || _queuedByServer || _nominalCheck?.possible == false;

  int get _balance =>
      context.read<SuperappProfileBloc>().state.displaySaldo ?? 0;
  int get _maximum => (_balance - _ideal).clamp(0, _balance);
  bool get _valid =>
      !_loading &&
      _loadError == null &&
      _value >= _minimum &&
      !_checkingNominal &&
      _nominalCheckError == null &&
      _checkedNominal == _value &&
      _nominalCheck != null &&
      _value <= _nominalCheck!.maximum &&
      _bank != null;
  String _money(num value) =>
      CurrencyFormat.convertToIdrWithSpasi(value.toInt(), 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nominalDebounce?.cancel();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final bankResult = await di.locator<BankAccountRepository>().accounts();
      final banks = bankResult.fold<List<BankAccountsDataModel>>(
        (failure) => throw StateError(failure.message),
        (accounts) => accounts
            .map((account) => BankAccountsDataModel(
                  bankAccountsId: account.id,
                  bankName: account.bankName,
                  bankOwnerName: account.accountName,
                  bankOwnerNumber: account.accountNo,
                ))
            .toList(),
      );
      if (!mounted) return;
      setState(() {
        _banks = banks;
        if (_bank != null &&
            !_banks.any((e) => e.bankAccountsId == _bank!.bankAccountsId)) {
          _bank = null;
        }
      });
      await _loadIdealBalance();
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Withdrawal bank accounts load failed: $error');
      }
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = 'Data penarikan belum dapat dimuat. Silakan coba lagi.';
        });
      }
    }
  }

  /// Saldo ideal breakdown and withdrawal in process (`on_withdrawl`) from
  /// `kmpoin/balance_analytics`, so the notices show as soon as the form opens.
  Future<void> _loadIdealBalance() async {
    final int partnerId;
    try {
      partnerId = await di.locator<KomshipPartnerIdResolver>().resolve();
    } catch (error) {
      if (kDebugMode) debugPrint('Withdrawal partner id failed: $error');
      return;
    }
    final result =
        await di.locator<GetIdealBalanceUseCase>()(partnerId: partnerId);
    if (!mounted) return;
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('Withdrawal ideal balance load failed: ${failure.message}');
        }
      },
      (data) => setState(() {
        _idealData = data;
        _ideal = (data.idealBalance ?? 0).toInt();
        _pending = (data.onWithdrawl ?? 0).toInt();
      }),
    );
  }

  void _setAmount(int value) {
    setState(() {
      _submitError = null;
      _value = value;
      _preset = _presets.contains(value) ? value : null;
      final formatted = value == 0 ? '' : _money(value);
      _amount.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
    _scheduleNominalCheck();
  }

  void _scheduleNominalCheck() {
    _nominalDebounce?.cancel();
    final nominal = _value;
    final requestVersion = ++_nominalRequestVersion;
    setState(() {
      _checkedNominal = null;
      _nominalCheck = null;
      _nominalCheckError = null;
      _checkingNominal = nominal >= _minimum;
    });
    if (nominal < _minimum) return;
    _nominalDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final check =
            await WithdrawalNominalChecker(di.locator()).check(nominal);
        if (!mounted || requestVersion != _nominalRequestVersion) return;
        setState(() {
          _checkedNominal = nominal;
          _nominalCheck = check;
          _checkingNominal = false;
          _ideal = check.ideal;
        });
      } catch (_) {
        if (!mounted || requestVersion != _nominalRequestVersion) return;
        setState(() {
          _checkingNominal = false;
          _nominalCheckError = 'Validasi nominal gagal. Coba masukkan ulang.';
        });
      }
    });
  }

  void _showBalanceNotice({WithdrawalBalanceNotice? only}) {
    final notice = only ??
        (_ideal > 0 && _queued
            ? WithdrawalBalanceNotice.combined
            : _queued
                ? WithdrawalBalanceNotice.pending
                : WithdrawalBalanceNotice.ideal);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x73000000),
      builder: (_) => WithdrawalBalanceSheet(notice: notice, ideal: _idealData),
    );
  }

  Future<void> _submit() async {
    if (!_valid || _submitting) return;
    final requestedAmount = _value;
    final selectedBank = _bank;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      // Periksa kembali batas terbaru lewat endpoint partner yang juga dipakai
      // ketika nominal diisi. Endpoint saldo ideal admin menolak token user.
      final check =
          await WithdrawalNominalChecker(di.locator()).check(requestedAmount);
      if (!mounted) return;
      if (_value != requestedAmount || _bank != selectedBank) return;
      setState(() {
        _checkedNominal = requestedAmount;
        _nominalCheck = check;
        _ideal = check.ideal;
        _idealData ??= IdealBalanceModel(
          idealBalance: check.ideal,
          shippingReturPotential: check.potentialReturn,
          inComeOrderPotential: check.potentialIncome,
        );
      });
      if (requestedAmount > check.maximum || _queued) {
        _showBalanceNotice();
        return;
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Withdrawal ideal balance check failed: $error');
      }
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitError =
              'Saldo penarikan belum bisa diperiksa. Silakan coba lagi.';
        });
      }
      return;
    }
    // PIN sudah diverifikasi di Home sebelum form dibuka.
    final bank = selectedBank!;
    final userId = context.read<SuperappProfileBloc>().state.displayProfile?.id;
    if (userId == null || bank.bankAccountsId == null) {
      setState(() {
        _submitting = false;
        _submitError = 'Data akun belum dimuat. Silakan coba lagi.';
      });
      return;
    }
    try {
      await di.locator<KompayWithdrawalRemoteDataSource>().request(
            userId: userId,
            nominal: requestedAmount,
            bankAccountId: bank.bankAccountsId!,
          );
      if (!mounted) return;
      // Saldo dan antrean penarikan berubah setelah pengajuan.
      context.read<SuperappProfileBloc>().add(const FetchSuperappProfileEvent());
      // Sama seperti Komship web: pesan berhasil memakai data form.
      unawaited(Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => WithdrawalResultPage(
          withdrawal: KompayWithdrawal(
            nominal: requestedAmount,
            bankName: bank.bankName ?? '',
            bankOwnerName: bank.bankOwnerName ?? '',
          ),
        ),
      )));
    } on KompayWithdrawalQueued {
      if (!mounted) return;
      setState(() => _queuedByServer = true);
      _showBalanceNotice(only: WithdrawalBalanceNotice.pending);
    } on KompayWithdrawalRejected catch (error) {
      if (!mounted) return;
      unawaited(Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => WithdrawalResultPage(failedMessage: error.message),
      )));
    } catch (error) {
      if (kDebugMode) debugPrint('Withdrawal request failed: $error');
      if (mounted) {
        setState(() => _submitError =
            'Penarikan belum bisa diajukan. Periksa koneksi lalu coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _selectBank() async {
    if (_banks.isEmpty) {
      final add = await WithdrawalNoBankSheet.show(context);
      if (!mounted || add != true) return;
      await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BankAccountPage()));
      if (mounted) _load();
      return;
    }
    setState(() => _openBanks = !_openBanks);
  }

  /// Nominal is blocked only by the saldo ideal limit (AC20/AC22).
  bool get _blockedByIdeal {
    final check = _nominalCheck;
    return check != null &&
        _checkedNominal == _value &&
        _value <= check.balance &&
        _value > check.maximum;
  }

  String? get _amountError {
    if (_value == 0) return null;
    if (_value < _minimum) return 'Minimal nominal penarikan Rp 12.000';
    if (_checkingNominal) return null;
    if (_nominalCheckError != null) return _nominalCheckError;
    final check = _nominalCheck;
    if (check == null) return null;
    if (_value > check.balance) {
      return 'Saldo tidak mencukupi. Nominal penarikan melebihi saldo tersedia (${_money(check.balance)})';
    }
    if (_value > check.maximum) {
      return 'Nominal melebihi batas penarikan karena Saldo Ideal. Maksimal penarikan ${_money(check.maximum)}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            style: IconButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE3E3E3)),
                backgroundColor: AppColors.bgLight),
          ),
        ),
        title: const Text('Penarikan Saldo',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        titleSpacing: 12,
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
              child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                children: [
                  const Text('Saldo Kompay', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(_money(_balance),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  if (_loading) ...[
                    const SizedBox(height: 18),
                    const LinearProgressIndicator(color: AppColors.primaryBase)
                  ],
                  if (_loadError != null) ...[
                    const SizedBox(height: 16),
                    Text(_loadError!,
                        style: const TextStyle(color: AppColors.errorBase)),
                    TextButton(
                        onPressed: _load, child: const Text('Coba Lagi')),
                  ],
                  if (_pending > 0) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _showBalanceNotice,
                      child: _notice('Saldo Dalam Proses Penarikan',
                          'Masih ada penarikan sebesar ${_money(_pending)} yang sedang diproses. Ketuk untuk rincian.'),
                    ),
                  ],
                  if (_ideal > 0) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _showBalanceNotice,
                      child: _notice('Saldo Tertahan sebagai Saldo Ideal',
                          'Saldo yang bisa ditarik saat ini ${_money(_maximum)}. Ketuk untuk rincian.'),
                    ),
                  ],
                  const SizedBox(height: 28),
                  const Text('Pilih Nominal',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _presets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 3.35),
                    itemBuilder: (_, index) {
                      final value = _presets[index];
                      final selected = _preset == value;
                      return InkWell(
                        onTap: () => _setAmount(value),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryBase
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 3,
                                    offset: Offset(0, 1))
                              ]),
                          child: Text(_money(value),
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      selected ? Colors.white : Colors.black)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Masukkan Jumlah Penarikan',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amount,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Minimal Penarikan Rp 12.000',
                      hintStyle: const TextStyle(
                          fontSize: 12, color: AppColors.grey600),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (text) {
                      final value =
                          int.tryParse(text.replaceAll(RegExp(r'\D'), '')) ?? 0;
                      _setAmount(value);
                    },
                  ),
                  if (_amountError != null) ...[
                    const SizedBox(height: 6),
                    Text(_amountError!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.errorBase)),
                    if (_blockedByIdeal)
                      InkWell(
                        onTap: () => _showBalanceNotice(
                            only: WithdrawalBalanceNotice.ideal),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text('Lihat rincian Saldo Ideal',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.infoBase,
                                  decoration: TextDecoration.underline)),
                        ),
                      ),
                  ],
                  if (_checkingNominal) ...[
                    const SizedBox(height: 6),
                    const Text('Memeriksa nominal penarikan...',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.grey600)),
                  ],
                  const SizedBox(height: 8),
                  _notice('',
                      'Penarikan >Rp500.000 GRATIS biaya transfer, untuk nominal di bawahnya dikenakan biaya Rp2.000.'),
                  const SizedBox(height: 24),
                  const Text('Rekening Bank',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _loading || _loadError != null ? null : _selectBank,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(children: [
                        const Icon(Icons.account_balance_outlined,
                            size: 19, color: AppColors.grey600),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(
                                _bank == null
                                    ? 'Pilih Rekening Tujuan'
                                    : '${_bank!.bankName} - ${_bank!.bankOwnerNumber}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _bank == null
                                        ? AppColors.grey600
                                        : Colors.black))),
                        Icon(
                            _openBanks
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.grey600),
                      ]),
                    ),
                  ),
                  if (_openBanks)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                          children: _banks
                              .map((bank) => InkWell(
                                    onTap: () => setState(() {
                                      _bank = bank;
                                      _openBanks = false;
                                    }),
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 16),
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Color(0xFFEAEAEA)))),
                                      child: Text(
                                          '${bank.bankName} - ${bank.bankOwnerNumber}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey600)),
                                    ),
                                  ))
                              .toList()),
                    ),
                ]),
          )),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            color: AppColors.bgLight,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_submitError != null) ...[
                Text(_submitError!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.errorBase)),
                const SizedBox(height: 8),
              ],
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : _queued && !_loading
                          ? _showBalanceNotice
                          : _valid
                              ? _submit
                              : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBase,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.bgLight,
                    disabledForegroundColor: AppColors.grey600,
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFE3E3E3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Ajukan Penarikan',
                          style: TextStyle(fontSize: 14)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _notice(String title, String body) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFFFE9DB),
            borderRadius: BorderRadius.circular(8)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: title.isEmpty
                ? const Text.rich(
                    TextSpan(children: [
                      TextSpan(text: 'Penarikan >Rp500.000 '),
                      TextSpan(
                          text: 'GRATIS',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              ' biaya transfer, untuk nominal di bawahnya dikenakan biaya Rp2.000.'),
                    ]),
                    style: TextStyle(fontSize: 11, height: 1.4),
                  )
                : Text('$title\n$body',
                    style: const TextStyle(fontSize: 11, height: 1.4)),
          ),
        ]),
      );
}

/// Result of a withdrawal request (Figma success/failed states).
class WithdrawalResultPage extends StatelessWidget {
  const WithdrawalResultPage({super.key, this.withdrawal, this.failedMessage})
      : assert(withdrawal != null || failedMessage != null);

  final KompayWithdrawal? withdrawal;
  final String? failedMessage;

  bool get failed => withdrawal == null;

  @override
  Widget build(BuildContext context) {
    final result = withdrawal;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                  failed
                      ? 'Penarikan Gagal Diproses'
                      : 'Penarikan Saldo Berhasil',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              if (result == null)
                Text(
                    'Oops, penarikan belum dapat diproses. $failedMessage',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 16, color: AppColors.grey600))
              else
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Penarikan sebesar '),
                    TextSpan(
                        text: CurrencyFormat.convertToIdrWithSpasi(
                            result.nominal, 0),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    const TextSpan(text: ' akan segera diproses ke rekening '),
                    TextSpan(
                        text: '${result.bankName} ${result.bankOwnerName}'
                            .trim(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    const TextSpan(text: ' dalam 1x24 jam'),
                  ]),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.grey600, height: 1.45),
                ),
              const SizedBox(height: 30),
              SvgPicture.asset(
                  failed
                      ? 'assets/images/superapp/setting/failed_img.svg'
                      : 'assets/images/team/success_payment.svg',
                  width: failed ? 240 : 184,
                  height: failed ? 226 : 248),
              const SizedBox(height: 24),
              DsButton(
                  text: 'Lihat Riwayat Penarikan',
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) =>
                            const KompayMutationPage(backToHome: true),
                      ))),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () => failed
                      ? Navigator.of(context).pop()
                      : Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                  child: const Text('Kembali')),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
