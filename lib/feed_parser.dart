import 'dart:convert';

const feedConnectionKey = 'xdt_api__v1__feed__timeline__connection';

const _nonPostNodeKeys = [
  'ad',
  'explore_story',
  'suggested_users',
  'end_of_feed_demarcator',
  'stories_netego',
  'bloks_netego',
];

class FeedPage {
  final List<Map<String, dynamic>> media;
  final Map<String, int> skippedNodeTypes;
  final Map<String, int> mediaNodesWithExtras;
  final String? endCursor;
  final bool? hasNextPage;

  FeedPage({
    required this.media,
    required this.skippedNodeTypes,
    required this.mediaNodesWithExtras,
    required this.endCursor,
    required this.hasNextPage,
  });
}

class MediaItem {
  final int? mediaType;
  final String? imageUrl;
  final String? videoUrl;

  MediaItem({this.mediaType, this.imageUrl, this.videoUrl});
}

class Post {
  final String id;
  final String? code;
  final String? username;
  final String? profilePicUrl;
  final String? caption;
  final DateTime? takenAt;
  final int? likeCount;
  final int? commentCount;
  final int? mediaType;
  final String? productType;
  final String? imageUrl;
  final String? videoUrl;
  final List<MediaItem> carousel;
  final String? accessibilityCaption;
  final double? aspectRatio;
  final Map<String, dynamic> raw;

  Post({
    required this.id,
    required this.code,
    required this.username,
    required this.profilePicUrl,
    required this.caption,
    required this.takenAt,
    required this.likeCount,
    required this.commentCount,
    required this.mediaType,
    required this.productType,
    required this.imageUrl,
    required this.videoUrl,
    required this.carousel,
    required this.accessibilityCaption,
    required this.aspectRatio,
    required this.raw,
  });

  String? get permalink => code == null ? null : 'https://www.instagram.com/p/$code/';

  List<MediaItem> get mediaItems => carousel.isNotEmpty
      ? carousel
      : [MediaItem(mediaType: mediaType, imageUrl: imageUrl, videoUrl: videoUrl)];

  static Post? fromMedia(Map<String, dynamic> media) {
    final id = (media['pk'] ?? media['id'])?.toString();
    if (id == null) return null;
    final user = _map(media['user']);
    final takenAt = _int(media['taken_at']);
    final width = _int(media['original_width']);
    final height = _int(media['original_height']);
    return Post(
      id: id,
      code: media['code'] as String?,
      username: user?['username'] as String?,
      profilePicUrl: user?['profile_pic_url'] as String?,
      caption: _map(media['caption'])?['text'] as String?,
      takenAt: takenAt == null ? null : DateTime.fromMillisecondsSinceEpoch(takenAt * 1000),
      likeCount: _int(media['like_count']),
      commentCount: _int(media['comment_count']),
      mediaType: _int(media['media_type']),
      productType: media['product_type'] as String?,
      imageUrl: _imageUrl(media),
      videoUrl: _videoUrl(media),
      carousel: [
        for (final item in (media['carousel_media'] as List? ?? []).whereType<Map<String, dynamic>>())
          MediaItem(
            mediaType: _int(item['media_type']),
            imageUrl: _imageUrl(item),
            videoUrl: _videoUrl(item),
          ),
      ],
      accessibilityCaption: media['accessibility_caption'] as String?,
      aspectRatio: width != null && height != null && height > 0 ? width / height : null,
      raw: media,
    );
  }
}

/// Instagram responses may carry a `for (;;);` guard prefix or several
/// newline-separated JSON documents (streamed GraphQL), so each line is tried
/// on its own when the whole body is not one document.
List<dynamic> decodeResponseBody(String body) {
  final text = body.trimLeft().replaceFirst(RegExp(r'^for\s*\(;;\);'), '');
  try {
    return [jsonDecode(text)];
  } on FormatException {
    final documents = <dynamic>[];
    for (final line in const LineSplitter().convert(text)) {
      if (line.trim().isEmpty) continue;
      try {
        documents.add(jsonDecode(line));
      } on FormatException {
        continue;
      }
    }
    return documents;
  }
}

Iterable<dynamic> findValuesByKey(dynamic json, String key) sync* {
  if (json is Map) {
    for (final entry in json.entries) {
      if (entry.key == key) {
        yield entry.value;
      } else {
        yield* findValuesByKey(entry.value, key);
      }
    }
  } else if (json is List) {
    for (final item in json) {
      yield* findValuesByKey(item, key);
    }
  }
}

List<FeedPage> parseFeedPages(String body) {
  final pages = <FeedPage>[];
  for (final document in decodeResponseBody(body)) {
    for (final connection in findValuesByKey(document, feedConnectionKey).whereType<Map>()) {
      pages.add(_parseConnection(connection));
    }
  }
  return pages;
}

FeedPage _parseConnection(Map connection) {
  final media = <Map<String, dynamic>>[];
  final skipped = <String, int>{};
  final withExtras = <String, int>{};

  for (final edge in (connection['edges'] as List? ?? []).whereType<Map>()) {
    final node = _map(edge['node']);
    if (node == null) continue;
    final otherKeys = _nonPostNodeKeys.where((key) => node[key] != null);
    final nodeMedia = _map(node['media']);
    if (nodeMedia != null) {
      media.add(nodeMedia);
      for (final key in otherKeys) {
        withExtras[key] = (withExtras[key] ?? 0) + 1;
      }
    } else {
      final type = otherKeys.firstOrNull ?? _describeUnknownNode(node);
      skipped[type] = (skipped[type] ?? 0) + 1;
    }
  }

  final pageInfo = _map(connection['page_info']);
  return FeedPage(
    media: media,
    skippedNodeTypes: skipped,
    mediaNodesWithExtras: withExtras,
    endCursor: pageInfo?['end_cursor'] as String?,
    hasNextPage: pageInfo?['has_next_page'] as bool?,
  );
}

String _describeUnknownNode(Map<String, dynamic> node) {
  final keys = node.keys.where((key) => key != '__typename' && node[key] != null).toList()..sort();
  return '${node['__typename'] ?? 'unknown'}{${keys.join(',')}}';
}

Map<String, dynamic>? _map(dynamic value) => value is Map ? value.cast<String, dynamic>() : null;

int? _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value');

const preferredImageWidth = 1080;

/// Picks the smallest size at least [preferredImageWidth] wide. The candidate
/// list also carries square crops for profile grids, so only sizes with the
/// same shape as the first (full-size) candidate are considered.
String? _imageUrl(Map<String, dynamic> media) {
  final candidates = _map(media['image_versions2'])?['candidates'];
  final sized = [
    for (final candidate in (candidates is List ? candidates : const []).whereType<Map>())
      if ((candidate['url'], _int(candidate['width']), _int(candidate['height']))
          case (final String url, final int width, final int height) when width > 0 && height > 0)
        (url: url, width: width, ratio: width / height),
  ];
  if (sized.isEmpty) return _firstUrl(candidates);

  final ratio = sized.first.ratio;
  final sameShape = sized.where((candidate) => (candidate.ratio - ratio).abs() < 0.02).toList()
    ..sort((a, b) => a.width.compareTo(b.width));
  return (sameShape.where((candidate) => candidate.width >= preferredImageWidth).firstOrNull ?? sameShape.last).url;
}

String? _videoUrl(Map<String, dynamic> media) => _firstUrl(media['video_versions']);

String? _firstUrl(dynamic list) =>
    list is List && list.isNotEmpty ? (_map(list.first)?['url'] as String?) : null;
