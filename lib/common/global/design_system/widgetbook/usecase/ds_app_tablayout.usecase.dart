import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';


@UseCase(
  name: 'Default',
  type: AppTabLayout,
)
Widget buildAppTabLayoutUseCase(BuildContext context) {
  final firstTab = context.knobs.string(
    label: 'Tab 1',
    initialValue: 'Semua',
  );

  final secondTab = context.knobs.string(
    label: 'Tab 2',
    initialValue: 'Pending',
  );

  final thirdTab = context.knobs.string(
    label: 'Tab 3',
    initialValue: 'Selesai',
  );

  return DefaultTabController(
    length: 3,
    child: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTabLayout(
              tabs: [
                Tab(text: firstTab),
                Tab(text: secondTab),
                Tab(text: thirdTab),
              ],
            ),
            const SizedBox(height: 24),
            const Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('Semua')),
                  Center(child: Text('Pending')),
                  Center(child: Text('Selesai')),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}