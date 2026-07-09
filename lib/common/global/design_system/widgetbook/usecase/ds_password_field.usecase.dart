// File: lib/common/global/design_system/widgetbook/usecases/ds_password_field.usecase.dart

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook/widgetbook.dart';

// Import komponen dari folder components
import '../../components/ds_password_field.dart';

@widgetbook.UseCase(name: 'Interactive Password Field', type: DsPasswordField)
Widget buildInteractiveDsPasswordField(BuildContext context) {
  // Controller dummy untuk kebutuhan Widgetbook
  final controller = TextEditingController();
  
  final showTopTrailing = context.knobs.boolean(
    label: 'Show Top Trailing Link',
    initialValue: false,
  );

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DsPasswordField(
          // Knob string biasa untuk label dan hint
          label: context.knobs.string(
            label: 'Label',
            initialValue: 'Kata Sandi',
          ),
          hintText: context.knobs.string(
            label: 'Hint Text',
            initialValue: 'Masukkan kata sandi rahasia...',
          ),
          // Knob stringOrNull untuk mensimulasikan state error/normal
          errorText: context.knobs.stringOrNull(
            label: 'Error Text',
            initialValue: null, 
          ),
          topTrailing: showTopTrailing
              ? GestureDetector(
                  onTap: () => debugPrint('Lupa password diklik!'),
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                )
              : null,
          controller: controller,
          onChanged: (value) {
            debugPrint('Password diketik di Widgetbook: $value');
          },
        ),
      ),
    ),
  );
}