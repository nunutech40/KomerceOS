import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook/widgetbook.dart';

// Import komponen aslinya
import '../../components/ds_button.dart'; 

@widgetbook.UseCase(name: 'Interactive Button', type: DsButton)
Widget buildInteractiveDsButton(BuildContext context) {
  final showLeftIcon = context.knobs.boolean(
    label: 'Show Left Icon',
    initialValue: false,
  );

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DsButton(
          text: context.knobs.string(
            label: 'Button Text', 
            initialValue: 'Simpan Data',
          ),
          state: context.knobs.list<DsButtonState>(
            label: 'Button State',
            options: DsButtonState.values,
            initialOption: DsButtonState.enabled,
          ),
          loadingText: context.knobs.stringOrNull(
            label: 'Loading Text',
            initialValue: 'Sedang memproses...',
          ),
          leftIcon: showLeftIcon
              ? const Icon(Icons.save_outlined, color: Colors.white)
              : null,
          colorIcon: context.knobs.boolean(
            label: 'Color Icon',
            initialValue: true,
          ),
          onPressed: () {
            debugPrint('Button diklik dari Widgetbook!');
          },
        ),
      ),
    ),
  );
}