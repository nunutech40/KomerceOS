import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/notification/view/notification_page.dart';
import 'package:komtim_partner/features/superapp/features/notification/widget/app_notification_card.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_chip_button.dart';

import '../helpers/helpers.dart';

void main() {
  group('NotificationPage Widget Tests', () {
    testWidgets('menampilkan title, tab, chip, dan list notifikasi default',
        (WidgetTester tester) async {
      // Set larger viewport to prevent lazy-loading of offscreen list items
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          const NotificationPage(),
        ),
      );

      // Verify page title is rendered
      expect(find.text('Notifikasi'), findsOneWidget);

      // Verify tabs are rendered
      expect(find.text('Semua'), findsAtLeast(1)); // Both tab and chip have 'Semua'
      expect(find.text('Belum Dibaca'), findsOneWidget);

      // Verify filter chips are rendered
      expect(find.text('Komship'), findsOneWidget);
      expect(find.text('Komtim'), findsOneWidget);
      expect(find.text('Komcards'), findsOneWidget);

      // Verify the list of notification cards is present
      expect(find.byType(AppNotificationCard), findsNWidgets(4));

      // Tap on the first notification card to mark it as read
      await tester.tap(find.byType(AppNotificationCard).first);
      await tester.pumpAndSettle();

      // Tap on the 'Belum Dibaca' tab to filter
      await tester.tap(find.text('Belum Dibaca'));
      await tester.pumpAndSettle();

      // After marking the first one read, 'Belum Dibaca' list should only show the remaining 2 unread notifications
      expect(find.byType(AppNotificationCard), findsNWidgets(2));
    });

    testWidgets('memfilter menggunakan chip kategori',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          const NotificationPage(),
        ),
      );

      // Tap the 'Komtim' chip
      await tester.tap(find.text('Komtim'));
      await tester.pumpAndSettle();

      // No notifications exist for 'Komtim' in dummy data, so empty state should show
      expect(find.text('Tidak ada notifikasi'), findsOneWidget);
      expect(find.text('Belum ada informasi apapun disini'), findsOneWidget);
      expect(find.byType(AppNotificationCard), findsNothing);
    });
  });
}
