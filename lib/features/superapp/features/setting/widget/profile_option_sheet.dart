import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../domain/entities/setting_profile.dart';
import 'profile_form_card.dart';

/// Selection stays local until Terapkan; closing never mutates the form.
class ProfileOptionSheet extends StatefulWidget {
  final String title;
  final List<ProfileOption> options;
  final String? selectedId;
  final bool searchable;
  final bool loading;
  final ValueChanged<String>? onSearchChanged;
  const ProfileOptionSheet(
      {super.key,
      required this.title,
      required this.options,
      this.selectedId,
      this.searchable = false,
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
  Widget build(BuildContext context) => DsBottomSheet(
        title: widget.title,
        description: '',
        image: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .4),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (widget.searchable) ...[
              TextField(
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari atau Masukkan Lokasi',
                  filled: true,
                  fillColor: AppColors.alwaysWhite,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Flexible(
              child: ProfileFormCard(children: [
                if (widget.loading)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (widget.options.isEmpty)
                  const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text('Belum ada pilihan yang tersedia.'))
                else
                  ...widget.options.map((option) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.label,
                            style: AppTypography.bodySmRegular),
                        trailing: Icon(
                            selected == option
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected == option
                                ? AppColors.primaryBase
                                : AppColors.grey300),
                        selected: selected == option,
                        onTap: () => setState(() => selected = option),
                      )),
              ]),
            ),
          ]),
        ),
        primaryButtonText: 'Terapkan',
        primaryButtonState: selected == null || widget.loading
            ? DsButtonState.disabled
            : DsButtonState.enabled,
        onPrimaryPressed: () => Navigator.pop(context, selected),
        secondaryButtonText: 'Kembali',
        secondaryButtonColor: AppColors.primaryBase,
        onSecondaryPressed: () => Navigator.pop(context),
        onClosePressed: () => Navigator.pop(context),
      );
}
