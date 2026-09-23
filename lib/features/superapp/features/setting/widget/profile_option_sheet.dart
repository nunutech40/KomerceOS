import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../domain/entities/setting_profile.dart';

/// Selection stays local until Terapkan; closing never mutates the form.
class ProfileOptionSheet extends StatefulWidget {
  final String title;
  final List<ProfileOption> options;
  final String? selectedId;
  final bool searchable;
  final bool showSelectionIndicator;
  final bool loading;
  final ValueChanged<String>? onSearchChanged;
  const ProfileOptionSheet(
      {super.key,
      required this.title,
      required this.options,
      this.selectedId,
      this.searchable = false,
      this.showSelectionIndicator = false,
      this.loading = false,
      this.onSearchChanged});
  @override
  State<ProfileOptionSheet> createState() => _ProfileOptionSheetState();
}

class _ProfileOptionSheetState extends State<ProfileOptionSheet> {
  ProfileOption? selected;
  @override
  void initState() {
    super.initState();
    for (final option in widget.options) {
      if (option.id == widget.selectedId) selected = option;
    }
  }

  @override
  void didUpdateWidget(covariant ProfileOptionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selected != null || widget.selectedId == null) return;
    for (final option in widget.options) {
      if (option.id == widget.selectedId) {
        selected = option;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final fixedContentHeight = widget.searchable ? 244.0 : 180.0;
    final maxListHeight =
        (availableHeight - fixedContentHeight).clamp(88.0, 220.0).toDouble();
    final bottomGap = mediaQuery.viewPadding.bottom > AppSpacing.md
        ? mediaQuery.viewPadding.bottom
        : AppSpacing.md;
    final contentHeight = widget.searchable
        ? 220.0
        : (widget.options.length * 44.0).clamp(88.0, 220.0).toDouble();
    final listHeight = contentHeight.clamp(88.0, maxListHeight).toDouble();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        margin: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          bottomGap,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgPopup,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl2),
            topRight: Radius.circular(AppRadius.xl2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md3,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.headingXs.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.bgLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 22,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (widget.searchable) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: widget.onSearchChanged,
                    style: AppTypography.bodyMdRegular.copyWith(
                      color: AppColors.grey900,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari atau Masukkan Lokasi',
                      hintStyle: AppTypography.bodyMdRegular.copyWith(
                        color: AppColors.grey600,
                      ),
                      filled: true,
                      fillColor: AppColors.alwaysWhite,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 12,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Container(
                height: listHeight,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.alwaysWhite,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildOptions(),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 36,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBase,
                    textStyle: AppTypography.bodyMdRegular,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Kembali'),
                ),
              ),
              if (selected != null && !widget.loading) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, selected),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primaryBase,
                      foregroundColor: AppColors.alwaysWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(
                      'Terapkan',
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.alwaysWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    if (widget.loading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: AppColors.primaryBase,
            strokeWidth: 3,
          ),
        ),
      );
    }
    if (widget.options.isEmpty) {
      return Center(
        child: Text(
          'Belum ada pilihan yang tersedia.',
          style: AppTypography.bodySmRegular.copyWith(color: AppColors.grey600),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.options.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.grey200),
      itemBuilder: (_, index) {
        final option = widget.options[index];
        return InkWell(
          onTap: () => setState(() => selected = option),
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmRegular.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                  if (widget.showSelectionIndicator) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _SelectionIndicator(selected: selected == option),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;

  const _SelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.alwaysWhite,
          border: Border.all(
            color: selected ? AppColors.primaryBase : AppColors.grey350,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBase,
                ),
              )
            : null,
      );
}
