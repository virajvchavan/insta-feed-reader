import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/database.dart';
import 'package:insta_reader/feed_kind.dart';
import 'package:insta_reader/feed_parser.dart';
import 'package:insta_reader/stories_parser.dart';

Post _post(String id, {List<Map<String, dynamic>>? carousel, int takenAt = 0}) => Post.fromMedia({
      'pk': id,
      'code': 'C$id',
      'taken_at': takenAt,
      'original_width': 1080,
      'original_height': 1350,
      'user': {'username': 'alice', 'profile_pic_url': 'https://x.fbcdn.net/a.jpg'},
      'media_type': carousel == null ? 1 : 8,
      'image_versions2': {
        'candidates': [
          {'url': 'https://x.fbcdn.net/$id.jpg'},
        ],
      },
      'carousel_media': ?carousel,
    })!;

Map<String, dynamic> _photo(String name) => {
      'media_type': 1,
      'image_versions2': {
        'candidates': [
          {'url': 'https://x.fbcdn.net/$name.jpg'},
        ],
      },
    };

void main() {
  group('database', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    group('store', () {
      test('stores a post once and reports the second save as already in the feed', () async {
        expect(await db.savePost(_post('1'), FeedKind.favorites), SaveResult.newPost);
        expect(await db.savePost(_post('1'), FeedKind.favorites), SaveResult.alreadyInFeed);

        final stats = await db.stats();
        expect(stats.posts, 1);
        expect(stats.mediaRows, 1);
      });

      test('keeps one media row per carousel item and records downloaded files', () async {
        await db.savePost(
          _post('2', carousel: [
            _photo('2a'),
            {
              'media_type': 2,
              'video_versions': [
                {'url': 'https://x.fbcdn.net/2b.mp4'},
              ],
            },
          ]),
          FeedKind.favorites,
        );

        await db.setAvatarFile('2', 'a.jpg');
        await db.setMediaFiles('2', 1, videoFile: '2b.mp4');

        final stats = await db.stats();
        expect(stats.mediaRows, 2);
        expect(stats.avatars, 1);
        expect((stats.imageUrls, stats.imageFiles), (1, 0));
        expect((stats.videoUrls, stats.videoFiles), (1, 1));

        final stored = await (db.select(db.posts)..where((row) => row.id.equals('2'))).getSingle();
        expect(stored.rawJson, contains('"carousel_media"'));
      });

      test('finds media still to download, with videos only for the given posts', () async {
        await db.savePost(_post('1'), FeedKind.favorites);
        await db.savePost(
          _post('2', carousel: [
            {
              ..._photo('2a'),
              'media_type': 2,
              'video_versions': [
                {'url': 'https://x.fbcdn.net/2a.mp4'},
              ],
            },
          ]),
          FeedKind.favorites,
        );
        await db.setAvatarFile('1', 'a.jpg');
        await db.setMediaFiles('1', 0, imageFile: '1.jpg');

        expect((await db.postsMissingAvatar()).map((post) => post.id), ['2']);
        expect((await db.mediaMissingImage()).map((media) => media.imageUrl), ['https://x.fbcdn.net/2a.jpg']);
        expect(await db.mediaMissingVideo(['1']), isEmpty);
        expect((await db.mediaMissingVideo(['2'])).map((media) => media.videoUrl), ['https://x.fbcdn.net/2a.mp4']);
      });

      test('feed lists newest posts first with their media in order', () async {
        await db.savePost(_post('old', takenAt: 100), FeedKind.favorites);
        await db.savePost(
          _post('new', takenAt: 200, carousel: [for (final name in ['x', 'y', 'z']) _photo(name)]),
          FeedKind.favorites,
        );

        final feed = await db.watchFeed(FeedKind.favorites).first;

        expect(feed.map((entry) => entry.post.id), ['new', 'old']);
        expect(feed.first.media.map((media) => media.imageUrl), [
          'https://x.fbcdn.net/x.jpg',
          'https://x.fbcdn.net/y.jpg',
          'https://x.fbcdn.net/z.jpg',
        ]);
        expect(feed.first.post.aspectRatio, closeTo(0.8, 1e-9));
      });
    });

    group('feeds', () {
      test('a post seen in Following is added to Favorites instead of counting as stored there', () async {
        expect(await db.savePost(_post('1'), FeedKind.following), SaveResult.newPost);
        expect(await db.savePost(_post('1'), FeedKind.favorites), SaveResult.addedToFeed);
        expect(await db.savePost(_post('1'), FeedKind.favorites), SaveResult.alreadyInFeed);
      });

      test('Favorites shows only its posts while Following shows every post', () async {
        await db.savePost(_post('fav', takenAt: 200), FeedKind.favorites);
        await db.savePost(_post('fol', takenAt: 100), FeedKind.following);

        final favorites = await db.watchFeed(FeedKind.favorites).first;
        final following = await db.watchFeed(FeedKind.following).first;

        expect(favorites.map((entry) => entry.post.id), ['fav']);
        expect(following.map((entry) => entry.post.id), ['fav', 'fol']);
      });

      test('watchFeed filters by unreadOnly and supports marking posts as read', () async {
        await db.savePost(_post('p1'), FeedKind.following);
        await db.savePost(_post('p2'), FeedKind.following);

        expect((await db.watchFeed(FeedKind.following, unreadOnly: true).first).map((e) => e.post.id), ['p1', 'p2']);

        await db.markPostAsRead('p1');
        expect((await db.watchFeed(FeedKind.following, unreadOnly: true).first).map((e) => e.post.id), ['p2']);
        expect((await db.watchFeed(FeedKind.following, unreadOnly: false).first).map((e) => e.post.id), ['p1', 'p2']);

        await db.markPostAsRead('p1', isRead: false);
        expect((await db.watchFeed(FeedKind.following, unreadOnly: true).first).map((e) => e.post.id), ['p1', 'p2']);

        final cleared = await db.markAllPostsAsRead(FeedKind.following);
        expect(cleared, ['p1', 'p2']);
        expect((await db.watchFeed(FeedKind.following, unreadOnly: true).first), isEmpty);
        expect((await db.watchFeed(FeedKind.following, unreadOnly: false).first).map((e) => e.post.id), ['p1', 'p2']);

        await db.markPostsAsUnread(cleared);
        expect((await db.watchFeed(FeedKind.following, unreadOnly: true).first).map((e) => e.post.id), ['p1', 'p2']);
      });

      test('remembers the selected feed, defaulting to Favorites', () async {
        expect(await db.selectedFeed(), FeedKind.favorites);
        await db.saveSelectedFeed(FeedKind.following);
        expect(await db.selectedFeed(), FeedKind.following);
      });

      test('remembers the unread conversation count, defaulting to zero', () async {
        expect(await db.unreadConversations(), 0);
        await db.saveUnreadConversations(2);
        expect(await db.unreadConversations(), 2);
      });
    });

    group('stories', () {
      test('saves stories and watches them ordered by position', () async {
        final items = [
          const StoryItem(id: '1', username: 'alice', avatarUrl: 'http://a.jpg', hasUnseen: true),
          const StoryItem(id: '2', username: 'bob', avatarUrl: 'http://b.jpg', hasUnseen: false),
        ];
        await db.saveStories(items);

        final stored = await db.watchStories().first;
        expect(stored.map((s) => s.username), ['alice', 'bob']);
        expect(stored.map((s) => s.hasUnseen), [true, false]);

        await db.markStorySeen('alice');
        final updated = await db.watchStories().first;
        expect(updated.first.hasUnseen, false);
      });

      test('preserves avatarFile across saves and finds missing avatars', () async {
        await db.saveStories([
          const StoryItem(id: '1', username: 'alice', avatarUrl: 'http://a.jpg'),
        ]);

        final missing = await db.storiesMissingAvatar();
        expect(missing.map((s) => s.id), ['1']);

        await db.setStoryAvatarFile('1', 'alice.jpg');
        expect(await db.storiesMissingAvatar(), isEmpty);

        // Re-saving stories preserves the downloaded avatar file
        await db.saveStories([
          const StoryItem(id: '1', username: 'alice', avatarUrl: 'http://a.jpg'),
        ]);
        final stored = await db.watchStories().first;
        expect(stored.first.avatarFile, 'alice.jpg');
      });
    });
  });

  test('upgrading a version 1 database fills aspect ratio and marks posts as Favorites', () async {
    final upgraded = AppDatabase(NativeDatabase.memory(setup: (raw) {
      raw.execute('CREATE TABLE "posts" ("id" TEXT NOT NULL, "code" TEXT NULL, "username" TEXT NULL, '
          '"profile_pic_url" TEXT NULL, "avatar_file" TEXT NULL, "caption" TEXT NULL, "taken_at" INTEGER NULL, '
          '"like_count" INTEGER NULL, "comment_count" INTEGER NULL, "media_type" INTEGER NULL, '
          '"product_type" TEXT NULL, "accessibility_caption" TEXT NULL, "raw_json" TEXT NOT NULL, '
          '"captured_at" INTEGER NOT NULL, PRIMARY KEY ("id"))');
      raw.execute('CREATE TABLE "post_media" ("post_id" TEXT NOT NULL REFERENCES posts (id), '
          '"position" INTEGER NOT NULL, "media_type" INTEGER NULL, "image_url" TEXT NULL, "video_url" TEXT NULL, '
          '"image_file" TEXT NULL, "video_file" TEXT NULL, PRIMARY KEY ("post_id", "position"))');
      raw.execute('INSERT INTO posts (id, raw_json, captured_at) '
          'VALUES (\'1\', \'{"original_width":1080,"original_height":1350}\', 0)');
      raw.execute('PRAGMA user_version = 1');
    }));
    addTearDown(upgraded.close);

    final post = await upgraded.select(upgraded.posts).getSingle();

    expect(post.aspectRatio, closeTo(0.8, 1e-9));
    expect((post.inFavorites, post.inFollowing, post.isRead), (true, false, false));
    expect(await upgraded.selectedFeed(), FeedKind.favorites);
  });
}
