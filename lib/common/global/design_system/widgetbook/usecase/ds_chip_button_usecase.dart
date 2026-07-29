import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_chip_button.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: DsChipButton,
)
Widget dsChipButtonUseCase(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: DsChipButton(
        // Knob untuk mengubah teks secara dinamis di sidebar Widgetbook
        label: context.knobs.string(
          label: 'Label',
          initialValue: 'Semua',
        ),
        // Knob untuk toggle state aktif/non-aktif
        isSelected: context.knobs.boolean(
          label: 'Is Selected',
          initialValue: false,
        ),
        // Callback action untuk melihat feedback interaksi
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chip Button Di-klik!'),
              duration: Duration(milliseconds: 500),
            ),
          );
        },
      ),
    ),
  );
}