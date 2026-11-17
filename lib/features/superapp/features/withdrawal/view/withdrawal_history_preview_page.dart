import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';

/// View-only destination for the result screen's history action.
/// The transaction list will be fed by the mutation API in the next stage.
class WithdrawalHistoryPreviewPage extends StatefulWidget {
  const WithdrawalHistoryPreviewPage(
      {super.key, required this.amount, required this.balance});

  final int amount;
  final int balance;

  @override
  State<WithdrawalHistoryPreviewPage> createState() =>
      _WithdrawalHistoryPreviewPageState();
}

class _WithdrawalHistoryPreviewPageState
    extends State<WithdrawalHistoryPreviewPage> {
  final _search = TextEditingController();
  String _category = 'Semua';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.arrow_back_ios_new, size: 17),
          ),
          title: const Text('Kembali ke Beranda',
              style: TextStyle(fontSize: 15, color: Colors.black)),
          titleSpacing: 0,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              const Text('PRATINJAU · BELUM ADA TRANSAKSI',
                  style: TextStyle(fontSize: 11, color: AppColors.grey600)),
              const SizedBox(height: 22),
              const Text('Kompay', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Text(CurrencyFormat.convertToIdrWithSpasi(widget.balance, 0),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 28),
              const Text('Mutasi Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintText: 'Cari...',
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 20)),
              ]),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final category in [
                    'Semua',
                    'Komship',
                    'Komtim',
                    'Komcards'
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _category == category,
                        selectedColor: AppColors.primaryBase,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: _category == category
                              ? Colors.white
                              : AppColors.grey600,
                        ),
                        onSelected: (_) => setState(() => _category = category),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 28),
              if (_category == 'Semua' &&
                  ('Penarikan Saldo Kompay'
                      .toLowerCase()
                      .contains(_search.text.toLowerCase()))) ...[
                const Text('Contoh tampilan riwayat',
                    style: TextStyle(fontSize: 12, color: AppColors.grey600)),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SvgPicture.asset(
                      'assets/images/superapp/home/ic_withdraw.svg',
                      width: 32,
                      height: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Penarikan Saldo Kompay',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(height: 5),
                      Text('Tanggal dan status akan mengikuti data transaksi',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.grey600)),
                      SizedBox(height: 8),
                      Text('Pratinjau',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.primaryBase)),
                    ],
                  )),
                  Text(
                      '-${CurrencyFormat.convertToIdrWithSpasi(widget.amount, 0)}',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.errorBase)),
                ]),
              ] else
                const Center(
                    child: Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Text('Tidak ada transaksi yang sesuai.',
                      style: TextStyle(color: AppColors.grey600)),
                )),
            ],
          ),
        ),
      );
}
