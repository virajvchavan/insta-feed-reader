import 'feed_parser.dart';

/// Counts unread, unmuted conversations the way Instagram's own badge does,
/// from its `IGDBadgeCountOffMsysQuery` response.
///
/// A conversation is unread when it is marked unread, or when the viewer's
/// read receipt is older than its last activity. The response does not say
/// which receipt is the viewer's; the viewer is the only participant present
/// in every conversation. Returns null when that cannot be told apart.
int? unreadConversationCount(String body) {
  final threads = [
    for (final document in decodeResponseBody(body))
      for (final folder in findValuesByKey(document, 'threads_by_folder').whereType<Map>())
        for (final edge in (folder['edges'] as List? ?? []).whereType<Map>())
          if (edge['node'] case {'as_ig_direct_thread': final Map thread}) thread,
  ];
  if (threads.isEmpty) return null;

  Map<String, int> receipts(Map thread) => {
        for (final receipt in (thread['slide_read_receipts'] as List? ?? []).whereType<Map>())
          '${receipt['participant_fbid']}': int.tryParse('${receipt['watermark_timestamp_ms']}') ?? 0,
      };

  final everyone = threads.map((thread) => receipts(thread).keys.toSet()).reduce((a, b) => a.intersection(b));
  if (everyone.length != 1) return null;
  final viewer = everyone.single;

  return threads.where((thread) {
    if (thread['is_muted'] == true) return false;
    if (thread['marked_as_unread'] == true) return true;
    final lastActivity = int.tryParse('${thread['last_activity_timestamp_ms']}') ?? 0;
    return (receipts(thread)[viewer] ?? 0) < lastActivity;
  }).length;
}
