import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';
import 'ds_button.dart';

/// Hasil seleksi dari [DsDateFilterSheet]: indeks bulan (1–12) + tahun.
class DsMonthYear {
  /// Bulan 1–12.
  final int month;

  /// Tahun penuh, mis. 2023.
  final int year;

  const DsMonthYear({required this.month, required this.year});

  @override
  bool operator ==(Object other) =>
      other is DsMonthYear && other.month == month && other.year == year;

  @override
  int get hashCode => Object.hash(month, year);
}

/// Bottom sheet filter tanggal global bergaya Cupertino wheel picker.
///
/// Menampilkan dua roda pilih — Bulan dan Tahun — dengan baris tengah
/// aktif (bold), tombol close bulat, "Reset Filter", dan "Terapkan Filter".
///
/// Mengembalikan [DsMonthYear] lewat `Navigator.pop`, atau `null` bila
/// ditutup / direset tanpa menerapkan.
///
/// Contoh:
/// ```dart
/// final result = await DsDateFilterSheet.show(
///   context,
///   initial: const DsMonthYear(month: 3, year: 2023),
///   minYear: 2020,
///   maxYear: 2025,
/// );
/// ```
class DsDateFilterSheet extends StatefulWidget {
  /// Judul header sheet.
  final String title;

  /// Seleksi awal. Bila null, memakai [minYear] + bulan pertama.
  final DsMonthYear? initial;

  /// Tahun paling awal yang dapat dipilih.
  final int minYear;

  /// Tahun paling akhir yang dapat dipilih.
  final int maxYear;

  /// Nama-nama bulan (indeks 0 = Januari). Default: nama bulan Indonesia.
  final List<String> monthNames;

  /// Teks tombol terapkan.
  final String applyText;

  /// Teks tombol reset.
  final String resetText;

  const DsDateFilterSheet({
    super.key,
    this.title = 'Pilih Tanggal',
    this.initial,
    required this.minYear,
    required this.maxYear,
    this.monthNames = defaultMonthNames,
    this.applyText = 'Terapkan Filter',
    this.resetText = 'Reset Filter',
  }) : assert(minYear <= maxYear, 'minYear harus <= maxYear');

  /// Nama bulan Indonesia (Januari–Desember).
  static const List<String> defaultMonthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Menampilkan sheet dan mengembalikan [DsMonthYear] terpilih.
  static Future<DsMonthYear?> show(
    BuildContext context, {
    String title = 'Pilih Tanggal',
    DsMonthYear? initial,
    required int minYear,
    required int maxYear,
    List<String> monthNames = defaultMonthNames,
    String applyText = 'Terapkan Filter',
    String resetText = 'Reset Filter',
  }) {
    return showModalBottomSheet<DsMonthYear>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgPopup,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (_) => DsDateFilterSheet(
        title: title,
        initial: initial,
        minYear: minYear,
        maxYear: maxYear,
        monthNames: monthNames,
        applyText: applyText,
        resetText: resetText,
      ),
    );
  }

  @override
  State<DsDateFilterSheet> createState() => _DsDateFilterSheetState();
}

class _DsDateFilterSheetState extends State<DsDateFilterSheet> {
  static const double _itemExtent = 40;

  late int _monthIndex; // 0–11
  late int _yearIndex; // 0 .. (maxYear - minYear)

  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _yearController;

  List<int> get _years =>
      List.generate(widget.maxYear - widget.minYear + 1, (i) => widget.minYear + i);

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _monthIndex = ((initial?.month ?? 1) - 1).clamp(0, 11);
    _yearIndex = initial != null
        ? (initial.year - widget.minYear)
            .clamp(0, widget.maxYear - widget.minYear)
        : 0;
    _monthController = FixedExtentScrollController(initialItem: _monthIndex);
    _yearController = FixedExtentScrollController(initialItem: _yearIndex);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _monthIndex = 0;
      _yearIndex = 0;
    });
    _monthController.animateToItem(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    _yearController.animateToItem(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _apply() {
    Navigator.pop(
      context,
      DsMonthYear(
        month: _monthIndex + 1,
        year: widget.minYear + _yearIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header: judul + tombol close ──
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.title,
                    style: AppTypography.headingXs
                        .copyWith(color: AppColors.grey800),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: const BoxDecoration(
                        color: AppColors.bgLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: AppSpacing.iconMd,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Kartu wheel picker ──
            Container(
              decoration: BoxDecoration(
                color: AppColors.alwaysWhite,
                borderRadius: BorderRadius.circular(AppRadius.lg2),
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: SizedBox(
                height: _itemExtent * 5,
                child: Row(
                  children: [
                    Expanded(
                      child: _WheelPicker(
                        controller: _monthController,
                        itemExtent: _itemExtent,
                        childCount: widget.monthNames.length,
                        selectedIndex: _monthIndex,
                        onChanged: (i) => setState(() => _monthIndex = i),
                        labelBuilder: (i) => widget.monthNames[i],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                      ),
                    ),
                    Expanded(
                      child: _WheelPicker(
                        controller: _yearController,
                        itemExtent: _itemExtent,
                        childCount: _years.length,
                        selectedIndex: _yearIndex,
                        onChanged: (i) => setState(() => _yearIndex = i),
                        labelBuilder: (i) => '${_years[i]}',
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: AppSpacing.lg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Reset Filter ──
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: _reset,
              child: Text(
                widget.resetText,
                style: AppTypography.bodyMdSemiBold
                    .copyWith(color: AppColors.primaryBase),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Terapkan Filter ──
            DsButton(text: widget.applyText, onPressed: _apply),
          ],
        ),
      ),
    );
  }
}

/// Satu roda Cupertino dengan baris tengah aktif (bold hitam).
class _WheelPicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final double itemExtent;
  final int childCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String Function(int index) labelBuilder;
  final Alignment alignment;
  final EdgeInsets padding;

  const _WheelPicker({
    required this.controller,
    required this.itemExtent,
    required this.childCount,
    required this.selectedIndex,
    required this.onChanged,
    required this.labelBuilder,
    required this.alignment,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: itemExtent,
      childCount: childCount,
      onSelectedItemChanged: onChanged,
      selectionOverlay: const SizedBox.shrink(),
      squeeze: 1.1,
      diameterRatio: 1.6,
      itemBuilder: (context, index) {
        final isSelected = index == selectedIndex;
        return Container(
          alignment: alignment,
          padding: padding,
          child: Text(
            labelBuilder(index),
            style: isSelected
                ? AppTypography.headingXs.copyWith(color: AppColors.grey900)
                : AppTypography.bodyMdRegular
                    .copyWith(color: AppColors.grey350),
          ),
        );
      },
    );
  }
}
