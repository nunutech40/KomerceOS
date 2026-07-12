import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/home/view/home_page_superapp.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_info_balance.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_menu_icon.dart';

import '../helpers/helpers.dart';

void main() {
  group('HomePageSuperApp Widget Tests', () {
    testWidgets('renders HomePageSuperApp successfully with header and menu items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          const HomePageSuperapp(),
        ),
      );

      // Verify that DsHomeHeader elements are present
      expect(find.text('Hemat Ongkir '), findsOneWidget);
      expect(find.text('Rp. 5.000.000'), findsOneWidget);

      // Verify that DsMenuItem widgets are present
      expect(find.text('Top Up'), findsOneWidget);
      expect(find.text('Penarikan'), findsOneWidget);

      // Verify that AppInfoCard is present with its contents
      expect(find.byType(AppInfoCard), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('Saldo Pending : '),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('Dari nilai tersebut, '),
        ),
        findsOneWidget,
      );

      // Verify that DsMenuIcon items are present
      expect(find.byType(DsMenuIcon), findsNWidgets(4));
      expect(find.text('Team'), findsOneWidget);
      expect(find.text('Order'), findsOneWidget);
      expect(find.text('Kendala'), findsOneWidget);
      expect(find.text('Kartu'), findsOneWidget);

      // Verify that Komship Component elements are present
      expect(find.text('Performa Omset & Orderan'), findsOneWidget);
      expect(find.text('Pantau semua pendapatan kamu disini'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });
  });
}
