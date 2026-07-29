import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_button_selected.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'Interactive',
  type: DsButtonSelected,
)
Widget buildDsButtonSelectedUseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Semua',
  );

  final isSelected = context.knobs.boolean(
    label: 'Selected',
    initialValue: false,
  );

  final borderRadius = context.knobs.double.slider(
    label: 'Border Radius',
    initialValue: 99,
    min: 0,
    max: 99,
  );

  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 38,
    min: 32,
    max: 56,
  );

  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: DsButtonSelected(
        label: label,
        isSelected: isSelected,
        borderRadius: borderRadius,
        height: height,
        onTap: () {},
      ),
    ),
  );
}