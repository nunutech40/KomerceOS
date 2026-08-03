import 'package:flutter/material.dart';

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
      onTap: () {
        _updateSelection(value); // ✅ Gunakan fungsi update
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Radio<String>(
              value: value,
              groupValue: selectedMethod,
              onChanged: (val) {
                if (val != null) {
                  _updateSelection(val); // ✅ Gunakan fungsi update
                }
              },
              activeColor: Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: showDetails
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          "Saldo tersedia: Rp ${_formatCurrency(balance)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (!isBalanceSufficient)
                          const Text(
                            "Saldo tidak mencukupi",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
