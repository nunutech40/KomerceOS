// File: lib/common/global/design_system/widgetbook/usecases/ds_bottom_sheet.usecase.dart

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook/widgetbook.dart';

// Import komponen dari folder components
import '../../components/ds_bottom_sheet.dart';
import '../../components/ds_button.dart';

@widgetbook.UseCase(name: 'Interactive Bottom Sheet', type: DsBottomSheet)
Widget buildInteractiveDsBottomSheet(BuildContext context) {
  // 1. Baca semua Knobs di luar callback onPressed agar nilainya terikat ke kanvas Widgetbook
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Hapus Transaksi',
  );
  
  final description = context.knobs.string(
    label: 'Description',
    initialValue: 'Apakah Anda yakin ingin menghapus data transaksi ini? Tindakan ini tidak dapat dibatalkan.',
  );
  
  final primaryButtonText = context.knobs.string(
    label: 'Primary Button Text',
    initialValue: 'Ya, Hapus',
  );
  
  final secondaryButtonText = context.knobs.stringOrNull(
    label: 'Secondary Button Text',
    initialValue: 'Batal',
  );
  
  final isDismissible = context.knobs.boolean(
    label: 'Is Dismissible',
    initialValue: true,
  );

  final showImage = context.knobs.boolean(
    label: 'Show Warning Image',
    initialValue: false,
  );

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DsButton(
          text: 'Tampilkan Bottom Sheet',
          onPressed: () {
            // 2. Panggil static helper yang sudah kamu buat dengan nilai dari Knobs
            DsBottomSheet.show(
              context: context,
              title: title,
              description: description,
              primaryButtonText: primaryButtonText,
              secondaryButtonText: secondaryButtonText,
              isDismissible: isDismissible,
              image: showImage
                  ? const Icon(
                      Icons.warning_amber_rounded,
                      size: 80,
                      color: Colors.orange,
                    )
                  : null,
              // Bisa tambahkan warna sekunder merah untuk simulasi hapus data
              secondaryButtonColor: Colors.red,
              onPrimaryPressed: () {
                debugPrint('Primary button ditekan dari Widgetbook');
                Navigator.pop(context); // Menutup dialog
              },
              onSecondaryPressed: () {
                debugPrint('Secondary button ditekan dari Widgetbook');
                Navigator.pop(context); // Menutup dialog
              },
              onClosePressed: () {
                debugPrint('Tombol silang (X) ditekan dari Widgetbook');
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    ),
  );
}