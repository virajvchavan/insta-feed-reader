import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/feed_parser.dart';

Map<String, dynamic> _connection() => {
      'edges': [
        {
          'node': {
            '__typename': 'XDTFeedItem',
            'media': {
              'pk': '111',
              'id': '111_9',
              'code': 'ABC',
              'user': {'username': 'alice', 'profile_pic_url': 'https://x.fbcdn.net/a.jpg'},
              'caption': {'text': 'hello'},
              'taken_at': 1761700000,
              'like_count': 5,
              'comment_count': 2,
              'media_type': 8,
              'product_type': 'carousel_container',
              'carousel_media': [
                {
                  'media_type': 1,
                  'image_versions2': {
                    'candidates': [
                      {'url': 'https://x.fbcdn.net/1.jpg'},
                    ],
                  },
                },
                {
                  'media_type': 2,
                  'video_versions': [
                    {'url': 'https://x.fbcdn.net/2.mp4'},
                  ],
                },
              ],
            },
            'ad': null,
          },
        },
        {
          'node': {'__typename': 'XDTFeedItem', 'media': null, 'ad': {'id': 'ad1'}},
        },
        {
          'node': {'__typename': 'XDTFeedItem', 'media': null, 'suggested_users': {}},
        },
        {
          'node': {'__typename': 'XDTEndOfFeed', 'media': null},
        },
      ],
      'page_info': {'end_cursor': 'cursor1', 'has_next_page': true},
    };

void main() {
  test('finds the connection at any depth and splits posts from other nodes', () {
    final body = jsonEncode({
      'require': [
        [
          'x',
          {
            'data': {feedConnectionKey: _connection()},
          },
        ],
      ],
    });

    final pages = parseFeedPages(body);

    expect(pages, hasLength(1));
    expect(pages.single.media, hasLength(1));
    expect(pages.single.skippedNodeTypes, {'ad': 1, 'suggested_users': 1, 'XDTEndOfFeed{}': 1});
    expect(pages.single.endCursor, 'cursor1');
    expect(pages.single.hasNextPage, isTrue);
  });

  test('handles the for(;;); prefix and newline-separated documents', () {
    final body = 'for (;;);${jsonEncode({'label': 'first'})}\n'
        '${jsonEncode({
      'data': {feedConnectionKey: _connection()},
    })}';

    expect(parseFeedPages(body), hasLength(1));
  });

  test('normalizes a carousel post', () {
    final post = Post.fromMedia(parseFeedPages(jsonEncode({feedConnectionKey: _connection()})).single.media.single)!;

    expect(post.id, '111');
    expect(post.username, 'alice');
    expect(post.caption, 'hello');
    expect(post.takenAt, DateTime.fromMillisecondsSinceEpoch(1761700000 * 1000));
    expect(post.permalink, 'https://www.instagram.com/p/ABC/');
    expect(post.carousel.map((item) => (item.imageUrl, item.videoUrl)), [
      ('https://x.fbcdn.net/1.jpg', null),
      (null, 'https://x.fbcdn.net/2.mp4'),
    ]);
  });

  test('picks the smallest same-shape photo at least 240 wide, skipping square crops', () {
    Map<String, dynamic> candidate(int width, int height) =>
        {'url': 'https://x.fbcdn.net/${width}x$height.jpg', 'width': width, 'height': height};
    Post postWith(List<Map<String, dynamic>> candidates) =>
        Post.fromMedia({'pk': '1', 'image_versions2': {'candidates': candidates}})!;

    final portrait = postWith([
      candidate(1440, 1920),
      candidate(1080, 1440),
      candidate(720, 960),
      candidate(240, 320),
      candidate(750, 750),
      candidate(240, 240),
    ]);
    final small = postWith([candidate(640, 1136), candidate(240, 426), candidate(640, 640)]);

    expect(portrait.imageUrl, 'https://x.fbcdn.net/240x320.jpg');
    expect(small.imageUrl, 'https://x.fbcdn.net/240x426.jpg');
  });
}
