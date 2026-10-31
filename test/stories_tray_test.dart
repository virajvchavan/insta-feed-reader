import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/database.dart';
import 'package:insta_reader/stories_parser.dart';
import 'package:insta_reader/stories_tray.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());
    tempDir = Directory.systemTemp.createTempSync('stories_test');
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });
  });

  testWidgets('StoriesTray renders Your story even when no stories stored', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesTray(
            db: db,
            mediaDirectory: tempDir,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your story'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('StoriesTray renders Your story and story usernames', (tester) async {
    await db.saveStories([
      const StoryItem(id: '1', username: 'captain.okami', hasUnseen: true),
      const StoryItem(id: '2', username: 'homi_aabha', hasUnseen: false),
    ]);

    String? tappedUser;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoriesTray(
            db: db,
            mediaDirectory: tempDir,
            onStoryTap: (username) => tappedUser = username,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your story'), findsOneWidget);
    expect(find.text('captain.okami'), findsOneWidget);
    expect(find.text('homi_aabha'), findsOneWidget);

    await tester.tap(find.text('captain.okami'));
    await tester.pumpAndSettle();

    expect(tappedUser, 'captain.okami');

    // Tapping also marks story seen
    final updated = await db.select(db.stories).get();
    expect(updated.firstWhere((s) => s.username == 'captain.okami').hasUnseen, false);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
