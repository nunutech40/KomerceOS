import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/myapp/view/my_app_page.dart';
import 'package:komtim_partner/features/superapp/features/myapp/widget/app_service_card.dart';
import 'package:komtim_partner/features/superapp/features/myapp/widget/app_status_chip.dart';

import '../helpers/helpers.dart';

void main() {
  group('MyAppPage Widget Tests', () {
    testWidgets('renders MyAppPage successfully with header, featured card, and app list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          const MyAppPage(),
        ),
      );

      // Verify that the header back button and title is present
      expect(find.text('Aplikasiku'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Verify featured card is present
      expect(find.text('Komerce.id'), findsOneWidget);
      expect(find.text('Semua environmet yang kamu butuhkan ada di sini'), findsOneWidget);

      // Verify app list card headers are rendered
      expect(find.text('komship'), findsOneWidget);
      expect(find.text('kompack'), findsOneWidget);
      expect(find.text('komcards'), findsOneWidget);
      expect(find.text('komtim'), findsOneWidget);
      expect(find.text('komplace'), findsOneWidget);

      // Verify that 5 AppServiceCard widgets are rendered
      expect(find.byType(AppServiceCard), findsNWidgets(5));

      // Verify registration status chips are rendered with correct text
      expect(find.text('Terdaftar'), findsNWidgets(2)); // komship & kompack
      expect(find.text('Kirim ulang Verifikasi'), findsOneWidget); // komcards
      expect(find.byType(AppStatusChip), findsNWidgets(3));
    });
  });
}
