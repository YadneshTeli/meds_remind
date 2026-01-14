// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:meds_remind/main.dart';
import 'package:meds_remind/services/storage_service.dart';
import 'package:meds_remind/services/notification_service.dart';

void main() {
  testWidgets('App starts with empty medicine list', (WidgetTester tester) async {
    // Initialize services for testing
    final storageService = StorageService();
    await storageService.init();
    
    final notificationService = NotificationService();
    await notificationService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        storageService: storageService,
        notificationService: notificationService,
      ),
    );

    // Verify that the empty state is shown
    expect(find.text('No medicines added yet'), findsOneWidget);
  });
}

