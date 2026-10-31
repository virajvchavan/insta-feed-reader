import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/inbox_parser.dart';

Map<String, dynamic> _thread({
  required int lastActivity,
  required int myWatermark,
  bool muted = false,
  bool markedUnread = false,
  String other = 'other',
}) =>
    {
      'node': {
        'as_ig_direct_thread': {
          'marked_as_unread': markedUnread,
          'last_activity_timestamp_ms': '$lastActivity',
          'is_muted': muted,
          'slide_read_receipts': [
            {'participant_fbid': 'me', 'watermark_timestamp_ms': '$myWatermark'},
            {'participant_fbid': other, 'watermark_timestamp_ms': '$lastActivity'},
          ],
        },
      },
    };

String _response(List<Map<String, dynamic>> edges) => jsonEncode({
      'data': {
        'get_slide_mailbox_for_iris_subscription': {
          'threads_by_folder': {'edges': edges},
        },
      },
    });

void main() {
  test('counts unread, unmuted conversations using the viewer found in every thread', () {
    final body = _response([
      _thread(lastActivity: 200, myWatermark: 100, other: 'a'),
      _thread(lastActivity: 200, myWatermark: 200, other: 'b'),
      _thread(lastActivity: 200, myWatermark: 100, other: 'c', muted: true),
      _thread(lastActivity: 200, myWatermark: 200, other: 'd', markedUnread: true),
    ]);

    expect(unreadConversationCount(body), 2);
  });

  test('returns null when the viewer cannot be told apart', () {
    expect(unreadConversationCount(_response([_thread(lastActivity: 200, myWatermark: 100)])), isNull);
    expect(unreadConversationCount(_response([])), isNull);
  });
}
