import 'package:flutter_test/flutter_test.dart';
import 'package:insta_reader/post_card.dart';

void main() {
  final now = DateTime(2026, 10, 29, 22, 0);

  test('timeAgo uses short relative units, then a date', () {
    expect(timeAgo(now.subtract(const Duration(seconds: 30)), now), 'now');
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), now), '5m');
    expect(timeAgo(now.subtract(const Duration(hours: 3)), now), '3h');
    expect(timeAgo(now.subtract(const Duration(days: 2)), now), '2d');
    expect(timeAgo(DateTime(2026, 10, 16), now), '16 Oct');
    expect(timeAgo(DateTime(2025, 12, 31), now), '31 Dec 2025');
  });

  test('formatCount groups thousands', () {
    expect(formatCount(54), '54');
    expect(formatCount(2567), '2,567');
    expect(formatCount(1234567), '1,234,567');
  });
}
