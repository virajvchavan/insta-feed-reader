import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/pinch_zoom.dart';

void main() {
  testWidgets('PinchZoom does not block single pointer horizontal drag / dismiss', (tester) async {
    var dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Dismissible(
            key: const Key('dismissible_item'),
            onDismissed: (_) => dismissed = true,
            child: PinchZoom(
              child: Container(
                width: 300,
                height: 300,
                color: Colors.blue,
                child: const Text('Target Media'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Target Media'), findsOneWidget);

    // Fling with a single finger horizontally
    await tester.fling(find.text('Target Media'), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(dismissed, isTrue, reason: 'Single finger swipe should dismiss the item');
  });

  testWidgets('PinchZoom zooms with two pointers and snaps back on release', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PinchZoom(
              child: Container(
                width: 200,
                height: 200,
                color: Colors.red,
                child: const Text('Zoomable Photo'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Zoomable Photo'), findsOneWidget);

    // Start two touches in the center
    final center = tester.getCenter(find.text('Zoomable Photo'));
    final touch1 = await tester.startGesture(center + const Offset(-20, 0));
    final touch2 = await tester.startGesture(center + const Offset(20, 0));

    // Move fingers apart to pinch zoom
    await touch1.moveBy(const Offset(-60, 0));
    await touch2.moveBy(const Offset(60, 0));
    await tester.pump();

    // The overlay should be present with the scaled image
    // In overlay, find.text('Zoomable Photo') will find 2 widgets: the original (opacity 0) and the overlay one
    expect(find.text('Zoomable Photo'), findsNWidgets(2));

    // Release both touches
    await touch1.up();
    await touch2.up();

    // Pump through the reset animation
    await tester.pumpAndSettle();

    // Overlay removed, only the original widget remains visible
    expect(find.text('Zoomable Photo'), findsOneWidget);
  });

  testWidgets('PinchZoom inside PageView allows page switching on 1 finger, zooms on 2 fingers', (tester) async {
    final pageController = PageController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageView(
            controller: pageController,
            children: [
              PinchZoom(
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.green,
                  child: const Text('Page 1 Image'),
                ),
              ),
              PinchZoom(
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.yellow,
                  child: const Text('Page 2 Image'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Page 1 Image'), findsOneWidget);

    // 1-finger swipe switches to Page 2
    await tester.fling(find.text('Page 1 Image'), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Page 2 Image'), findsOneWidget);

    // 2-finger pinch on Page 2 Image zooms
    final center = tester.getCenter(find.text('Page 2 Image'));
    final touch1 = await tester.startGesture(center + const Offset(-20, 0));
    final touch2 = await tester.startGesture(center + const Offset(20, 0));

    await touch1.moveBy(const Offset(-50, 0));
    await touch2.moveBy(const Offset(50, 0));
    await tester.pump();

    // Zoomed in overlay exists
    expect(find.text('Page 2 Image'), findsNWidgets(2));

    await touch1.up();
    await touch2.up();
    await tester.pumpAndSettle();

    expect(find.text('Page 2 Image'), findsOneWidget);
  });
}
