import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_button_selected.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/barcode_qris_page.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  int? _selectedNominal;
  String? _selectedPaymentMethod; // 'bank' or 'qris'

  final List<int> _nominalList = [
    10000,
    20000,
    50000,
    100000,
    500000,
    1000000,
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  int _getCleanedAmount() {
    final text = _amountController.text;
    return int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  void _onAmountChanged() {
    final cleaned = _getCleanedAmount();

    // Check if the current value matches any of the nominal buttons
    int? matchedNominal;
    for (final nominal in _nominalList) {
      if (cleaned == nominal) {
        matchedNominal = nominal;
        break;
      }
    }

    if (_selectedNominal != matchedNominal) {
      setState(() {
        _selectedNominal = matchedNominal;
      });
    }
  }

  void _selectNominal(int nominal) {
    // Unfocus textfield when choosing predefined nominal
    _amountFocusNode.unfocus();

    setState(() {
      _selectedNominal = nominal;
      _amountController.text = CurrencyFormat.convertToIdrWithSpasi(nominal, 0);
    });
  }

  bool _isInputValid() {
    final amount = _getCleanedAmount();
    return amount >= 10000;
  }

  bool _isSubmitEnabled() {
    return _isInputValid() && _selectedPaymentMethod != null;
  }

  Widget _buildConfirmationDetails(String paymentMethod, int amount) {
    final amountText = CurrencyFormat.convertToIdrWithSpasi(amount, 0);
    final paymentLabel = paymentMethod == 'qris' ? 'QRIS' : 'Transfer Bank';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      paymentLabel,
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.grey200),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nominal Top Up',
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      amountText,
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.grey200),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Biaya Layanan',
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      'Gratis',
                      style: AppTypography.bodyMdSemiBold.copyWith(
                        color: AppColors.primaryBase,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Tagihan',
                style: AppTypography.bodyMdMedium.copyWith(
                  color: AppColors.grey800,
                ),
              ),
              Text(
                amountText,
                style: AppTypography.bodyLgSemiBold.copyWith(
                  color: AppColors.alwaysBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _getCleanedAmount();
    final bool showValidationError =
        _amountController.text.isNotEmpty && amount < 10000;

    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
      appBar: AppBar(
        backgroundColor: AppColors.alwaysWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Topup Kompay',
          style: AppTypography.headingXs.copyWith(
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),

              // --- MASUKKAN JUMLAH TOPUP ---
              Text(
                'Masukkan Jumlah Topup',
                style: AppTypography.labelMdSemiBold.copyWith(
                  color: AppColors.grey800,
                ),
              ),
              const SizedBox(height: AppSpacing.md3),
              TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: TextInputType.number,
                style: AppTypography.bodyLgMedium.copyWith(
                  color: AppColors.grey800,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'Minimal Topup Rp 10.000',
                  hintStyle: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.grey400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: showValidationError
                          ? AppColors.errorBase
                          : AppColors.grey300,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: showValidationError
                          ? AppColors.errorBase
                          : AppColors.primaryBase,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
              if (showValidationError) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Minimal Topup Rp 10.000',
                  style: AppTypography.bodySmRegular.copyWith(
                    color: AppColors.errorBase,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // --- PILIH NOMINAL ---
              Text(
                'Pilih Nominal',
                style: AppTypography.labelMdSemiBold.copyWith(
                  color: AppColors.grey800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3x2 Grid of Chips using clean Row layouts
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DsButtonSelected(
                          label: 'Rp 10.000',
                          borderRadius: AppRadius.lg,
                          height: 52,
                          isSelected: _selectedNominal == 10000,
                          onTap: () => _selectNominal(10000),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: DsButtonSelected(
                          label: 'Rp 20.000',
                          height: 52,
                          borderRadius: AppRadius.lg,
                          isSelected: _selectedNominal == 20000,
                          onTap: () => _selectNominal(20000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md3),
                  Row(
                    children: [
                      Expanded(
                        child: DsButtonSelected(
                          label: 'Rp 50.000',
                          height: 52,
                          borderRadius: AppRadius.lg,
                          isSelected: _selectedNominal == 50000,
                          onTap: () => _selectNominal(50000),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: DsButtonSelected(
                          label: 'Rp 100.000',
                          height: 52,
                          borderRadius: AppRadius.lg,
                          isSelected: _selectedNominal == 100000,
                          onTap: () => _selectNominal(100000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md3),
                  Row(
                    children: [
                      Expanded(
                        child: DsButtonSelected(
                          label: 'Rp 500.000',
                          height: 52,
                          borderRadius: AppRadius.lg,
                          isSelected: _selectedNominal == 500000,
                          onTap: () => _selectNominal(500000),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: DsButtonSelected(
                          label: 'Rp 1.000.000',
                          height: 52,
                          borderRadius: AppRadius.lg,
                          isSelected: _selectedNominal == 1000000,
                          onTap: () => _selectNominal(1000000),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // --- METODE PEMBAYARAN ---
              Text(
                'Metode Pembayaran',
                style: AppTypography.labelMdSemiBold.copyWith(
                  color: AppColors.grey800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              DsRadioButton(
                title: 'Transfer Bank',
                icon: SvgPicture.asset('assets/images/superapp/ic_bank.svg'),
                selected: _selectedPaymentMethod == 'bank',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'bank';
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md3),
              DsRadioButton(
                title: 'QRIS',
                icon: Image.asset('assets/images/superapp/ic_qr_code.png'),
                selected: _selectedPaymentMethod == 'qris',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'qris';
                  });
                },
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: DsButton(
            text: 'Top Up',
            state: _isSubmitEnabled()
                ? DsButtonState.enabled
                : DsButtonState.disabled,
            onPressed: () {
              final finalAmount = _getCleanedAmount();
              final finalMethod = _selectedPaymentMethod ?? '';

              DsBottomSheet.show(
                context: context,
                title: 'Konfirmasi Pembayaran',
                description: '',
                primaryButtonText: 'Bayar',
                onPrimaryPressed: () {
                  Navigator.pop(context); // Close bottom sheet

                  if (finalMethod == 'qris') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BarcodeQrisPage(amount: finalAmount),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Top up sejumlah ${CurrencyFormat.convertToIdrWithSpasi(finalAmount, 0)} menggunakan $finalMethod berhasil diajukan!',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                image: _buildConfirmationDetails(finalMethod, finalAmount),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final double value = double.parse(cleanText);
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
