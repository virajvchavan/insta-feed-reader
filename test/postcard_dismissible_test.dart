import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/database.dart';
import 'package:insta_reader/post_card.dart';

void main() {
  testWidgets('Dismissible wraps PostCard: single media dismisses on swipe, carousel swipes pages', (tester) async {
    final post1 = StoredPost(
      id: '1',
      code: 'code1',
      username: 'user1',
      rawJson: '{}',
      capturedAt: DateTime.now(),
      inFavorites: false,
      inFollowing: true,
      isRead: false,
    );
    final media1 = StoredMedia(postId: '1', position: 0);

    var dismissed1 = false;

    // 1. Single media post
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              Dismissible(
                key: const Key('post1'),
                onDismissed: (_) => dismissed1 = true,
                child: PostCard(
                  entry: FeedEntry(post1, [media1]),
                  mediaDirectory: Directory('/tmp'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Fling on the photo of post1
    await tester.fling(find.byType(AspectRatio), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(dismissed1, isTrue, reason: 'Single photo post should dismiss on swipe');

    // 2. Carousel post (multiple media)
    final post2 = StoredPost(
      id: '2',
      code: 'code2',
      username: 'user2',
      rawJson: '{}',
      capturedAt: DateTime.now(),
      inFavorites: false,
      inFollowing: true,
      isRead: false,
    );
    final media2a = StoredMedia(postId: '2', position: 0);
    final media2b = StoredMedia(postId: '2', position: 1);

    var dismissed2 = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              Dismissible(
                key: const Key('post2'),
                onDismissed: (_) => dismissed2 = true,
                child: PostCard(
                  entry: FeedEntry(post2, [media2a, media2b]),
                  mediaDirectory: Directory('/tmp'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Initial state: page indicator shows 1/2
    expect(find.text('1/2'), findsOneWidget);

    // Fling on the carousel photo
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();

    expect(dismissed2, isFalse, reason: 'Carousel swipe should NOT dismiss the post');
    expect(find.text('2/2'), findsOneWidget, reason: 'Carousel should advance to page 2');

    // Fling on the carousel photo at the last page does not dismiss
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(dismissed2, isFalse);

    // Fling on the header (username) of the carousel post dismisses it
    await tester.fling(find.text('user2'), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(dismissed2, isTrue);
  });
}
