import 'dart:convert';

class StoryItem {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool hasUnseen;
  final int? latestReelMedia;
  final int? seen;

  const StoryItem({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.hasUnseen = true,
    this.latestReelMedia,
    this.seen,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          hasUnseen == other.hasUnseen;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ hasUnseen.hashCode;

  @override
  String toString() => 'StoryItem($username, unseen: $hasUnseen)';
}

/// Parses stories from either a reels_tray JSON response or DOM-extracted JSON.
List<StoryItem> parseStories(String raw) {
  var clean = raw.trim();
  if (clean.startsWith('for (;;);')) {
    clean = clean.substring(9).trim();
  }
  if (clean.isEmpty) return const [];

  try {
    final decoded = jsonDecode(clean);
    final tray = _findTrayList(decoded);
    if (tray != null) {
      return _parseTrayItems(tray);
    }
    if (decoded is List) {
      return _parseDomStories(decoded);
    }
  } catch (_) {
    // Return empty on parse error
  }
  return const [];
}

List<StoryItem> _parseDomStories(List items) {
  final result = <StoryItem>[];
  for (final item in items) {
    if (item is! Map) continue;
    final username = item['username']?.toString().trim();
    if (username == null || username.isEmpty) continue;
    final avatarUrl = item['avatarUrl']?.toString();
    final hasUnseen = item['hasUnseen'] == true;
    result.add(StoryItem(
      id: username,
      username: username,
      avatarUrl: avatarUrl,
      hasUnseen: hasUnseen,
    ));
  }
  return result;
}

List<StoryItem> _parseTrayItems(List trayList) {
  final result = <StoryItem>[];
  for (final item in trayList) {
    if (item is! Map) continue;
    final map = item as Map<String, dynamic>;
    final user = map['user'] ?? map['owner'];
    if (user is! Map) continue;

    final userMap = user as Map<String, dynamic>;
    final username = userMap['username']?.toString().trim();
    if (username == null || username.isEmpty) continue;

    final id = map['id']?.toString() ?? username;
    final avatarUrl = (userMap['profile_pic_url'] ?? userMap['profile_picture'])?.toString();
    final latest = map['latest_reel_media'] is int ? map['latest_reel_media'] as int : null;
    final seen = map['seen'] is int ? map['seen'] as int : null;

    final bool hasUnseen;
    if (latest != null && seen != null) {
      hasUnseen = seen < latest;
    } else if (map['has_unseen'] is bool) {
      hasUnseen = map['has_unseen'] as bool;
    } else if (map['seen'] == 0) {
      hasUnseen = true;
    } else {
      hasUnseen = true;
    }

    result.add(StoryItem(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      hasUnseen: hasUnseen,
      latestReelMedia: latest,
      seen: seen,
    ));
  }
  return result;
}

List? _findTrayList(dynamic node) {
  if (node is Map<String, dynamic>) {
    if (node['tray'] is List) return node['tray'] as List;

    for (final value in node.values) {
      final found = _findTrayList(value);
      if (found != null) return found;
    }
  } else if (node is List) {
    for (final item in node) {
      final found = _findTrayList(item);
      if (found != null) return found;
    }
  }
  return null;
}
