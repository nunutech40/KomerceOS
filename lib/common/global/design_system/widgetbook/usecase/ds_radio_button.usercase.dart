import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'Default',
  type: DsRadioButton,
)
Widget buildDsRadioButtonUseCase(BuildContext context) {
  final selected = context.knobs.boolean(
    label: 'Selected',
    initialValue: false,
  );

  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Bank Transfer',
  );

  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (context, setState) {
            bool isSelected = selected;

            return DsRadioButton(
              title: title,
              icon: const Icon(
                Icons.account_balance,
                color: AppColors.primaryBase,
              ),
              selected: isSelected,
              onTap: () {
                setState(() {
                  isSelected = !isSelected;
                });
              },
            );
          },
        )
      ),
    ),
  );
}