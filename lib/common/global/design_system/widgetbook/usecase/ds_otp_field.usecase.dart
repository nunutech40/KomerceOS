// File: lib/common/global/design_system/widgetbook/usecases/ds_otp_field.usecase.dart

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Import komponen dari folder components
import '../../components/ds_otp_field.dart';

@widgetbook.UseCase(name: 'Interactive OTP Field', type: DsOtpField)
Widget buildInteractiveDsOtpField(BuildContext context) {
  // Controller dummy untuk kebutuhan Widgetbook
  final controller = TextEditingController();

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DsOtpField(
          controller: controller,
          // Knob boolean untuk mengaktifkan/mematikan input
          isEnabled: context.knobs.boolean(
            label: 'Is Enabled',
            initialValue: true,
          ),
          // Knob boolean untuk mengaktifkan/mematikan masking PIN + icon mata
          obscureText: context.knobs.boolean(
            label: 'Obscure Text',
            initialValue: true,
          ),
          // Knob stringOrNull untuk mensimulasikan state error
          errorText: context.knobs.stringOrNull(
            label: 'Error Text',
            initialValue: null,
          ),
          onChanged: (value) {
            debugPrint('OTP mengetik: $value');
          },
          onCompleted: (value) {
            // Cek di console saat ke-6 digit sudah terisi penuh
            debugPrint('OTP SELESAI: $value');
          },
        ),
      ),
    ),
  );
}
