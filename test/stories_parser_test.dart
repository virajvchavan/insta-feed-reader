import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/stories_parser.dart';

void main() {
  group('stories parser', () {
    test('parses reels_tray JSON with seen and unseen stories', () {
      const raw = '''
      {
        "data": {
          "xdt_api__v1__feed__reels_tray": {
            "tray": [
              {
                "id": "reel:12345",
                "latest_reel_media": 1730400000,
                "seen": 0,
                "user": {
                  "pk": "12345",
                  "username": "captain.okami",
                  "profile_pic_url": "https://cdn.instagram.com/avatar1.jpg"
                }
              },
              {
                "id": "reel:67890",
                "latest_reel_media": 1730300000,
                "seen": 1730300000,
                "user": {
                  "pk": "67890",
                  "username": "homi_aabha",
                  "profile_pic_url": "https://cdn.instagram.com/avatar2.jpg"
                }
              }
            ]
          }
        }
      }
      ''';

      final stories = parseStories(raw);
      expect(stories.length, 2);
      expect(stories[0].username, 'captain.okami');
      expect(stories[0].hasUnseen, true);
      expect(stories[0].avatarUrl, 'https://cdn.instagram.com/avatar1.jpg');

      expect(stories[1].username, 'homi_aabha');
      expect(stories[1].hasUnseen, false);
      expect(stories[1].avatarUrl, 'https://cdn.instagram.com/avatar2.jpg');
    });

    test('parses DOM extracted JSON', () {
      const raw = '''
      [
        {"username": "captain.okami", "avatarUrl": "https://cdn.instagram.com/1.jpg", "hasUnseen": true},
        {"username": "homi_aabha", "avatarUrl": "https://cdn.instagram.com/2.jpg", "hasUnseen": false}
      ]
      ''';

      final stories = parseStories(raw);
      expect(stories.length, 2);
      expect(stories[0].username, 'captain.okami');
      expect(stories[0].hasUnseen, true);
      expect(stories[1].username, 'homi_aabha');
      expect(stories[1].hasUnseen, false);
    });

    test('handles empty and malformed input gracefully', () {
      expect(parseStories(''), isEmpty);
      expect(parseStories('not json'), isEmpty);
      expect(parseStories('for (;;); {}'), isEmpty);
    });
  });
}
