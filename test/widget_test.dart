// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ez_queue/main.dart';

void main() {
  testWidgets('Landing page displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: EZQueueApp(),
      ),
    );

    // Verify that the landing page displays the app title.
    expect(find.text('EZQueue'), findsOneWidget);
    expect(find.text('Mobile Queue Management System'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
