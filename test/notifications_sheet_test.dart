import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/notifications_sheet.dart';

void main() {
  testWidgets('NotificationsSheet renders AppBar with title and actions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NotificationsSheet(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsOneWidget);
  });
}
