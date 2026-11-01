import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/database.dart';
import 'package:insta_reader/story_viewer_screen.dart';

void main() {
  testWidgets('StoryViewerScreen displays header and advances pages', (tester) async {
    final stories = [
      StoredStory(
        id: '1',
        username: 'alice',
        hasUnseen: true,
        position: 0,
        updatedAt: DateTime.now(),
      ),
      StoredStory(
        id: '2',
        username: 'bob',
        hasUnseen: true,
        position: 1,
        updatedAt: DateTime.now(),
      ),
      StoredStory(
        id: '3',
        username: 'charlie',
        hasUnseen: true,
        position: 2,
        updatedAt: DateTime.now(),
      ),
    ];

    final seenUsers = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoryViewerScreen(
            stories: stories,
            initialIndex: 0,
            db: _MockDb(onMarkSeen: seenUsers.add),
            mediaDirectory: Directory('/tmp'),
          ),
        ),
      ),
    );
    await tester.pump();

    // Initial story is alice, counter 1/3
    expect(find.text('@alice'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(seenUsers, contains('alice'));

    // Tap next chevron
    await tester.tap(find.byTooltip('Next story'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Now showing bob, counter 2/3
    expect(find.text('@bob'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(seenUsers, contains('bob'));

    // Tap next chevron again
    await tester.tap(find.byTooltip('Next story'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Now showing charlie, counter 3/3
    expect(find.text('@charlie'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(seenUsers, contains('charlie'));
  });

  testWidgets('StoryViewerScreen navigates via horizontal drag gestures', (tester) async {
    final stories = [
      StoredStory(
        id: '1',
        username: 'alice',
        hasUnseen: true,
        position: 0,
        updatedAt: DateTime.now(),
      ),
      StoredStory(
        id: '2',
        username: 'bob',
        hasUnseen: true,
        position: 1,
        updatedAt: DateTime.now(),
      ),
    ];

    final seenUsers = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoryViewerScreen(
            stories: stories,
            initialIndex: 0,
            db: _MockDb(onMarkSeen: seenUsers.add),
            mediaDirectory: Directory('/tmp'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('@alice'), findsOneWidget);

    // Swipe left (drag from right to left, dx < -40)
    await tester.drag(find.byType(StoryViewerScreen), const Offset(-100, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('@bob'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
    expect(seenUsers, contains('bob'));

    // Swipe right (drag from left to right, dx > 40)
    await tester.drag(find.byType(StoryViewerScreen), const Offset(100, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('@alice'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
  });
}

class _MockDb extends AppDatabase {
  _MockDb({required this.onMarkSeen});

  final void Function(String username) onMarkSeen;

  @override
  Future<void> markStorySeen(String username) async {
    onMarkSeen(username);
  }
}
