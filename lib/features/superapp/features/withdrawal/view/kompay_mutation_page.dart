import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/entities/kompay_mutation.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/repositories/kompay_mutation_repository.dart';

/// "Mutasi Transaksi" (Figma: Info Pemotongan Saldo Notif & Mutasi).
/// Data comes from Komship `order-transaction-balance`, the same history the
/// Komship app and partner web show.
class KompayMutationPage extends StatefulWidget {
  const KompayMutationPage(
      {super.key, this.backToHome = false, this.embedded = false});

  /// The withdrawal result screen returns to Home ("Kembali ke Beranda");
  /// other entry points (notification) simply pop.
  final bool backToHome;

  /// Shown as the "Mutasi" bottom-navigation tab (no back button).
  final bool embedded;

  @override
  State<KompayMutationPage> createState() => _KompayMutationPageState();
}

/// Product chips mapped to the API's transaction filters. Komcards has no
/// filter value in this API, so it is not offered.
enum _Category {
  all('Semua', null),
  komship('Komship', '1,2,3,6,7,8,9'),
  komtim('Komtim', '10,11');

  const _Category(this.label, this.filter);
  final String label;
  final String? filter;
}

class _KompayMutationPageState extends State<KompayMutationPage> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final List<KompayMutation> _items = [];
  Timer? _searchDebounce;
  _Category? _category = _Category.all;
  KompayMutationFilter? _filter;
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  String? get _activeFilter => _filter?.value ?? _category?.filter;

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    final version = ++_requestVersion;
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
      _loading = false;
    });
    await _loadMore(version: version);
  }

  Future<void> _loadMore({int? version}) async {
    final requestVersion = version ?? _requestVersion;
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    final result = await di.locator<KompayMutationRepository>().getMutations(
          page: _page + 1,
          filter: _activeFilter,
          search: _search.text.trim(),
        );
    if (!mounted || requestVersion != _requestVersion) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = 'Mutasi belum dapat dimuat. Silakan coba lagi.';
        debugPrint('[Mutasi] gagal: ${failure.message}');
      }),
      (page) => setState(() {
        _loading = false;
        _page++;
        _items.addAll(page.items);
        _hasMore = page.hasMore && page.items.isNotEmpty;
      }),
    );
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), _reload);
  }

  void _selectCategory(_Category category) {
    setState(() {
      _category = category;
      _filter = null;
    });
    _reload();
  }

  Future<void> _openFilter() async {
    final picked = await showModalBottomSheet<_FilterChoice>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(selected: _filter),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _filter = picked.filter;
      _category = picked.filter == null ? _Category.all : null;
    });
    _reload();
  }

  void _back() {
    if (widget.backToHome) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = context
        .select<SuperappProfileBloc, int>((b) => b.state.displaySaldo ?? 0);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_ios_new, size: 17),
              ),
              title: Text(widget.backToHome ? 'Kembali ke Beranda' : 'Kembali',
                  style: const TextStyle(fontSize: 15, color: Colors.black)),
              titleSpacing: 0,
            ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Kompay', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              Text(CurrencyFormat.convertToIdrWithSpasi(balance, 0),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              const Text('Mutasi Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintText: 'Cari nomor resi...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: AppColors.grey600),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Filter jenis transaksi',
                  onPressed: _openFilter,
                  style: IconButton.styleFrom(
                    side: BorderSide(
                        color: _filter == null
                            ? const Color(0xFFE3E3E3)
                            : AppColors.primaryBase),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(Icons.filter_list,
                      size: 20,
                      color: _filter == null
                          ? AppColors.grey600
                          : AppColors.primaryBase),
                ),
              ]),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final category in _Category.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category.label),
                        selected: _category == category,
                        showCheckmark: false,
                        selectedColor: AppColors.primaryBase,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                            color: _category == category
                                ? AppColors.primaryBase
                                : const Color(0xFFE3E3E3)),
                        shape: const StadiumBorder(),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: _category == category
                              ? Colors.white
                              : AppColors.grey600,
                        ),
                        onSelected: (_) => _selectCategory(category),
                      ),
                    ),
                ]),
              ),
              if (_filter != null) ...[
                const SizedBox(height: 8),
                Text('Filter: ${_filter!.label}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primaryBase)),
              ],
              const SizedBox(height: 16),
              ..._buildList(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildList() {
    if (_items.isEmpty) {
      if (_loading) {
        return const [
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryBase)),
          )
        ];
      }
      if (_error != null) return [_errorView()];
      return const [
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text('Belum ada transaksi.',
                style: TextStyle(color: AppColors.grey600)),
          ),
        )
      ];
    }

    final widgets = <Widget>[];
    String? lastGroup;
    for (final item in _items) {
      final group = KompayMutationDates.groupLabel(item.date, DateTime.now());
      if (group != lastGroup) {
        widgets.add(Padding(
          padding: EdgeInsets.only(top: lastGroup == null ? 0 : 12, bottom: 8),
          child: Text(group,
              style: const TextStyle(fontSize: 12, color: AppColors.grey600)),
        ));
        lastGroup = group;
      }
      widgets.add(_MutationRow(item: item));
    }
    if (_loading) {
      widgets.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
            child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2))),
      ));
    } else if (_error != null) {
      widgets.add(_errorView());
    }
    return widgets;
  }

  Widget _errorView() => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(children: [
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorBase)),
          TextButton(
            onPressed: () {
              setState(() => _error = null);
              _items.isEmpty ? _reload() : _loadMore();
            },
            child: const Text('Coba Lagi'),
          ),
        ]),
      );
}

/// Date labels for the grouped list ("Hari ini", "Kemarin", "18 November 2025").
abstract final class KompayMutationDates {
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', //
    'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String full(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  static String groupLabel(DateTime? date, DateTime now) {
    if (date == null) return 'Lainnya';
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return full(date);
  }
}

class _MutationRow extends StatelessWidget {
  const _MutationRow({required this.item});

  final KompayMutation item;

  // Figma "Logo Product" variants (Kompay for balance movements, Komship
  // for order-related mutations).
  static const _kompayLogo = 'assets/images/superapp/home/ic_logo_kompay.svg';
  static const _iconAssets = {
    KompayMutationIcon.withdrawal: _kompayLogo,
    KompayMutationIcon.topup: _kompayLogo,
    KompayMutationIcon.subscription: _kompayLogo,
    KompayMutationIcon.order:
        'assets/images/superapp/home/ic_logo_product_komship.svg',
  };

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg) = switch (item.tone) {
      KompayMutationTone.success => (
          const Color(0xFF289568),
          const Color(0xFFE7F6EE)
        ),
      KompayMutationTone.danger => (
          AppColors.errorBase,
          const Color(0xFFFDECEC)
        ),
      KompayMutationTone.neutral => (
          AppColors.grey600,
          const Color(0xFFF1F1F1)
        ),
    };
    final amountText = item.amount > 0
        ? '+${CurrencyFormat.convertToIdr(item.amount, 0)}'
        : CurrencyFormat.convertToIdr(item.amount, 0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 32, height: 32, child: _icon()),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (item.date != null) ...[
              const SizedBox(height: 3),
              Text(KompayMutationDates.full(item.date!),
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.grey600)),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(6)),
              child: Text(item.status,
                  style: TextStyle(fontSize: 11, color: statusColor)),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (item.amount != 0)
            Text(amountText,
                style: TextStyle(
                    fontSize: 14,
                    color: item.amount > 0
                        ? const Color(0xFF289568)
                        : AppColors.errorBase)),
          const SizedBox(height: 3),
          Text(CurrencyFormat.convertToIdr(item.balanceAfter, 0),
              style: const TextStyle(fontSize: 11, color: AppColors.grey600)),
        ]),
      ]),
    );
  }

  Widget _icon() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEDEDED)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(_iconAssets[item.icon]!, fit: BoxFit.contain),
      );
}

class _FilterChoice {
  const _FilterChoice(this.filter);
  final KompayMutationFilter? filter;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.selected});

  final KompayMutationFilter? selected;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late KompayMutationFilter? _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    final options = <KompayMutationFilter?>[
      null,
      ...KompayMutationFilter.values
    ];
    return SafeArea(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Pilih Jenis Transaksi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Flexible(
            child: RadioGroup<KompayMutationFilter?>(
              groupValue: _selected,
              onChanged: (value) => setState(() => _selected = value),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    RadioListTile<KompayMutationFilter?>(
                      value: option,
                      activeColor: AppColors.primaryBase,
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(option?.label ?? 'Semua Jenis Transaksi',
                          style: const TextStyle(fontSize: 14)),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pop(context, const _FilterChoice(null)),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DsButton(
                  text: 'Terapkan',
                  onPressed: () =>
                      Navigator.pop(context, _FilterChoice(_selected)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
