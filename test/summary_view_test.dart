import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/database.dart';
import 'package:insta_reader/feed_kind.dart';
import 'package:insta_reader/feed_parser.dart';
import 'package:insta_reader/summary_view.dart';

void main() {
  final now = DateTime(2026, 10, 29, 22, 0);

  Post post(String id, String username, Duration age, {String productType = 'feed'}) => Post.fromMedia({
        'pk': id,
        'user': {'username': username},
        'taken_at': now.subtract(age).millisecondsSinceEpoch ~/ 1000,
        'media_type': productType == 'clips' ? 2 : 1,
        'product_type': productType,
        'caption': {'text': 'caption $id'},
      })!;

  test('groups the last 24 hours by person, most recent poster first', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    for (final p in [
      post('a1', 'alice', const Duration(hours: 5)),
      post('b1', 'bob', const Duration(hours: 1), productType: 'clips'),
      post('a2', 'alice', const Duration(hours: 2)),
      post('a3', 'alice', const Duration(hours: 30)),
    ]) {
      await db.savePost(p, FeedKind.favorites);
    }

    final people = summarize(await db.watchFeed(FeedKind.favorites).first, now);

    expect(people.map((person) => person.username), ['bob', 'alice']);
    expect(people.last.posts.map((p) => p.caption), ['caption a2', 'caption a1']);
    expect(postKind(people.first.posts.single), 'Reel');
  });
}
