import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_menu_item.dart';

import '../helpers/helpers.dart';

void main() {
  group('DsMenuItem Widget Tests', () {
    testWidgets('menampilkan title dan icon dengan benar',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          Row(
            children: [
              Expanded(
                child: DsMenuItem(
                  title: 'Test Menu',
                  icon: const Icon(Icons.add),
                  onTap: () {
                    tapped = true;
                  },
                ),
              ),
            ],
          ),
        ),
      );

      // Verify title is rendered
      expect(find.text('Test Menu'), findsOneWidget);

      // Verify icon is rendered
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap the menu item
      await tester.tap(find.byType(DsMenuItem));
      await tester.pump();

      // Verify onTap callback is triggered
      expect(tapped, isTrue);
    });
  });
}
