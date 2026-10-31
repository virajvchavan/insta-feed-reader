import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'feed_kind.dart';
import 'feed_parser.dart';

part 'database.g.dart';

/// File columns hold names relative to the media folder: iOS moves the app
/// container on every update, so absolute paths would go stale.
@DataClassName('StoredPost')
class Posts extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get profilePicUrl => text().nullable()();
  TextColumn get avatarFile => text().nullable()();
  TextColumn get caption => text().nullable()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  IntColumn get likeCount => integer().nullable()();
  IntColumn get commentCount => integer().nullable()();
  IntColumn get mediaType => integer().nullable()();
  TextColumn get productType => text().nullable()();
  TextColumn get accessibilityCaption => text().nullable()();
  RealColumn get aspectRatio => real().nullable()();
  BoolColumn get inFavorites => boolean().withDefault(const Constant(false))();
  BoolColumn get inFollowing => boolean().withDefault(const Constant(false))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get rawJson => text()();
  DateTimeColumn get capturedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StoredMedia')
class PostMedia extends Table {
  TextColumn get postId => text().references(Posts, #id)();
  IntColumn get position => integer()();
  IntColumn get mediaType => integer().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  TextColumn get imageFile => text().nullable()();
  TextColumn get videoFile => text().nullable()();

  @override
  Set<Column> get primaryKey => {postId, position};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

enum SaveResult { newPost, addedToFeed, alreadyInFeed }

class FeedEntry {
  final StoredPost post;
  final List<StoredMedia> media;

  FeedEntry(this.post, this.media);
}

class StoreStats {
  final int posts;
  final int avatars;
  final int mediaRows;
  final int imageUrls;
  final int imageFiles;
  final int videoUrls;
  final int videoFiles;

  StoreStats({
    required this.posts,
    required this.avatars,
    required this.mediaRows,
    required this.imageUrls,
    required this.imageFiles,
    required this.videoUrls,
    required this.videoFiles,
  });

  @override
  String toString() => '$posts posts ($avatars avatars), $mediaRows media items, '
      'images $imageFiles/$imageUrls downloaded, videos $videoFiles/$videoUrls downloaded';
}

@DriftDatabase(tables: [Posts, PostMedia, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(
              name: 'insta_reader',
              native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
            ));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(posts, posts.aspectRatio);
            await customStatement(
              "UPDATE posts SET aspect_ratio = "
              "CAST(json_extract(raw_json, '\$.original_width') AS REAL) / json_extract(raw_json, '\$.original_height') "
              "WHERE json_extract(raw_json, '\$.original_height') > 0",
            );
          }
          if (from < 3) {
            await m.addColumn(posts, posts.inFavorites);
            await m.addColumn(posts, posts.inFollowing);
            await m.createTable(appSettings);
            // Every post stored before version 3 came from a Favorites refresh.
            await customStatement('UPDATE posts SET in_favorites = 1');
          }
          if (from < 4) {
            await m.addColumn(posts, posts.isRead);
          }
        },
      );

  /// Favorites are accounts the user follows, so the Following view shows
  /// every stored post.
  Stream<List<FeedEntry>> watchFeed(FeedKind feed, {bool unreadOnly = true}) {
    final query = select(posts).join([leftOuterJoin(postMedia, postMedia.postId.equalsExp(posts.id))]);
    if (feed == FeedKind.favorites) query.where(posts.inFavorites.equals(true));
    if (unreadOnly) query.where(posts.isRead.equals(false));
    query.orderBy([
      OrderingTerm.desc(posts.takenAt),
      OrderingTerm.asc(postMedia.position),
    ]);
    return query.watch().map((rows) {
      final entries = <String, FeedEntry>{};
      for (final row in rows) {
        final post = row.readTable(posts);
        final entry = entries.putIfAbsent(post.id, () => FeedEntry(post, []));
        if (row.readTableOrNull(postMedia) case final media?) entry.media.add(media);
      }
      return entries.values.toList();
    });
  }

  Future<void> markPostAsRead(String postId, {bool isRead = true}) {
    return (update(posts)..where((row) => row.id.equals(postId))).write(PostsCompanion(isRead: Value(isRead)));
  }

  Future<List<String>> markAllPostsAsRead(FeedKind feed) async {
    return transaction(() async {
      final selectQuery = select(posts);
      if (feed == FeedKind.favorites) {
        selectQuery.where((row) => row.inFavorites.equals(true) & row.isRead.equals(false));
      } else {
        selectQuery.where((row) => row.isRead.equals(false));
      }
      final unread = await selectQuery.get();
      final ids = unread.map((p) => p.id).toList();
      if (ids.isNotEmpty) {
        await (update(posts)..where((row) => row.id.isIn(ids))).write(const PostsCompanion(isRead: Value(true)));
      }
      return ids;
    });
  }

  Future<void> markPostsAsUnread(List<String> postIds) {
    if (postIds.isEmpty) return Future.value();
    return (update(posts)..where((row) => row.id.isIn(postIds))).write(const PostsCompanion(isRead: Value(false)));
  }

  Future<SaveResult> savePost(Post post, FeedKind feed) {
    return transaction(() async {
      final existing = await (select(posts)..where((row) => row.id.equals(post.id))).getSingleOrNull();
      if (existing != null) {
        final alreadyInFeed = switch (feed) {
          FeedKind.favorites => existing.inFavorites,
          FeedKind.following => existing.inFollowing,
        };
        if (alreadyInFeed) return SaveResult.alreadyInFeed;
        await (update(posts)..where((row) => row.id.equals(post.id))).write(switch (feed) {
          FeedKind.favorites => const PostsCompanion(inFavorites: Value(true)),
          FeedKind.following => const PostsCompanion(inFollowing: Value(true)),
        });
        return SaveResult.addedToFeed;
      }

      await into(posts).insert(PostsCompanion.insert(
        id: post.id,
        code: Value(post.code),
        username: Value(post.username),
        profilePicUrl: Value(post.profilePicUrl),
        caption: Value(post.caption),
        takenAt: Value(post.takenAt),
        likeCount: Value(post.likeCount),
        commentCount: Value(post.commentCount),
        mediaType: Value(post.mediaType),
        productType: Value(post.productType),
        accessibilityCaption: Value(post.accessibilityCaption),
        aspectRatio: Value(post.aspectRatio),
        inFavorites: Value(feed == FeedKind.favorites),
        inFollowing: Value(feed == FeedKind.following),
        rawJson: jsonEncode(post.raw),
        capturedAt: DateTime.now(),
      ));
      for (final (position, item) in post.mediaItems.indexed) {
        await into(postMedia).insert(PostMediaCompanion.insert(
          postId: post.id,
          position: position,
          mediaType: Value(item.mediaType),
          imageUrl: Value(item.imageUrl),
          videoUrl: Value(item.videoUrl),
        ));
      }
      return SaveResult.newPost;
    });
  }

  Future<String?> _setting(String key) async {
    final row = await (select(appSettings)..where((row) => row.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _saveSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
  }

  Future<FeedKind> selectedFeed() async => FeedKind.values.asNameMap()[await _setting('feed')] ?? FeedKind.favorites;

  Future<void> saveSelectedFeed(FeedKind feed) => _saveSetting('feed', feed.name);

  Future<int> unreadConversations() async => int.tryParse(await _setting('unread_conversations') ?? '') ?? 0;

  Future<void> saveUnreadConversations(int count) => _saveSetting('unread_conversations', '$count');

  Future<String?> ownUsername() => _setting('own_username');

  Future<void> saveOwnUsername(String username) => _saveSetting('own_username', username);

  Future<void> setAvatarFile(String postId, String file) {
    return (update(posts)..where((row) => row.id.equals(postId))).write(PostsCompanion(avatarFile: Value(file)));
  }

  Future<void> setMediaFiles(String postId, int position, {String? imageFile, String? videoFile}) {
    return (update(postMedia)..where((row) => row.postId.equals(postId) & row.position.equals(position)))
        .write(PostMediaCompanion(
      imageFile: Value.absentIfNull(imageFile),
      videoFile: Value.absentIfNull(videoFile),
    ));
  }

  Future<List<StoredPost>> postsMissingAvatar() {
    return (select(posts)..where((row) => row.avatarFile.isNull() & row.profilePicUrl.isNotNull())).get();
  }

  Future<List<StoredMedia>> mediaMissingImage({bool coverOnly = true}) {
    final query = select(postMedia)..where((row) => row.imageFile.isNull() & row.imageUrl.isNotNull());
    if (coverOnly) query.where((row) => row.position.equals(0));
    return query.get();
  }

  Future<List<StoredMedia>> mediaMissingVideo(Iterable<String> postIds) {
    return (select(postMedia)
          ..where((row) => row.videoFile.isNull() & row.videoUrl.isNotNull() & row.postId.isIn(postIds)))
        .get();
  }

  Future<void> deleteEverything() {
    return transaction(() async {
      await delete(postMedia).go();
      await delete(posts).go();
    });
  }

  Future<void> clearVideoFiles() {
    return (update(postMedia)..where((row) => row.videoFile.isNotNull()))
        .write(const PostMediaCompanion(videoFile: Value(null)));
  }

  Future<StoreStats> stats() async {
    return StoreStats(
      posts: await posts.count().getSingle(),
      avatars: await posts.count(where: (row) => row.avatarFile.isNotNull()).getSingle(),
      mediaRows: await postMedia.count().getSingle(),
      imageUrls: await postMedia.count(where: (row) => row.imageUrl.isNotNull()).getSingle(),
      imageFiles: await postMedia.count(where: (row) => row.imageFile.isNotNull()).getSingle(),
      videoUrls: await postMedia.count(where: (row) => row.videoUrl.isNotNull()).getSingle(),
      videoFiles: await postMedia.count(where: (row) => row.videoFile.isNotNull()).getSingle(),
    );
  }
}
