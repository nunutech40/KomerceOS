// File: lib/common/global/design_system/widgetbook/usecases/ds_email_input.usecase.dart

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook/widgetbook.dart';

// Import komponen dari folder components
import '../../components/ds_email_field.dart';

@widgetbook.UseCase(name: 'Interactive Email Input', type: DsEmailInput)
Widget buildInteractiveDsEmailInput(BuildContext context) {
  // Controller dummy untuk kebutuhan Widgetbook
  final controller = TextEditingController();

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DsEmailInput(
          // Knob string biasa untuk label
          label: context.knobs.string(
            label: 'Label',
            initialValue: 'Alamat Email',
          ),
          // Knob string biasa untuk hint text
          hintText: context.knobs.string(
            label: 'Hint Text',
            initialValue: 'Masukkan email...',
          ),
          // Knob stringOrNull untuk mensimulasikan state error/normal
          errorText: context.knobs.stringOrNull(
            label: 'Error Text',
            initialValue: null, 
          ),
          controller: controller,
          onChanged: (value) {
            debugPrint('Email diketik di Widgetbook: $value');
          },
        ),
      ),
    ),
  );
}