import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';

class PaymentMethodRadio extends StatefulWidget {
  final int kompayBalance;
  final bool isKompayBalanceSufficient;
  final ValueChanged<String> onChanged;

  const PaymentMethodRadio({
    super.key,
    required this.kompayBalance,
    required this.isKompayBalanceSufficient,
    required this.onChanged,
  });

  @override
  State<PaymentMethodRadio> createState() => _PaymentMethodRadioState();
}

class _PaymentMethodRadioState extends State<PaymentMethodRadio> {
  String? selectedMethod;

  void _updateSelection(String value) {
    setState(() {
      selectedMethod = value;
    });
    widget.onChanged(value); // ✅ Panggil callback saat berubah
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOption(
          value: 'bank',
          label: 'Transfer Bank',
          showDetails: false,
        ),
        const SizedBox(height: 16),
        _buildOption(
          value: 'kompoint',
          label: 'KomPay',
          showDetails: true,
          balance: widget.kompayBalance,
          isBalanceSufficient: widget.isKompayBalanceSufficient,
        ),
      ],
    );
  }

  Widget _buildOption({
    required String value,
    required String label,
    bool showDetails = false,
    int balance = 0,
    bool isBalanceSufficient = true,
  }) {
    return InkWell(
      onTap: () => _updateSelection(value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            // sesuaikan angka ini biar pas sejajar sama baris pertama teks
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 20,
              height: 20,
              child: Radio<String>(
                value: value,
                groupValue: selectedMethod,
                onChanged: (val) {
                  if (val != null) _updateSelection(val);
                },
                side: const BorderSide(
                  width: 1,
                ),
                activeColor: primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: showDetails
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Saldo tersedia:",
                              style: TextStyle(color: gray737373),
                            ),
                            TextSpan(
                              text: "Rp ${_formatCurrency(balance)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: black0A,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isBalanceSufficient)
                        const Text(
                          "Saldo tidak mencukupi",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(label, style: const TextStyle(fontSize: 16)),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
