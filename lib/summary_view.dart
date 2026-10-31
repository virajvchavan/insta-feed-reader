import 'dart:io';

import 'package:flutter/material.dart';

import 'database.dart';
import 'feed_kind.dart';
import 'post_card.dart';

const summaryWindow = Duration(hours: 24);

class PersonSummary {
  final String username;
  final String? avatarFile;
  final List<StoredPost> posts;

  PersonSummary(this.username, this.avatarFile, this.posts);
}

/// [entries] arrive newest first, so each person's first post is their latest
/// and people end up ordered by who posted most recently.
List<PersonSummary> summarize(List<FeedEntry> entries, DateTime now) {
  final cutoff = now.subtract(summaryWindow);
  final people = <String, PersonSummary>{};
  for (final entry in entries) {
    final post = entry.post;
    if (post.takenAt == null || post.takenAt!.isBefore(cutoff)) continue;
    final username = post.username ?? 'unknown';
    people.putIfAbsent(username, () => PersonSummary(username, post.avatarFile, [])).posts.add(post);
  }
  return people.values.toList();
}

String postKind(StoredPost post) => switch ((post.productType, post.mediaType)) {
      ('clips', _) => 'Reel',
      (_, 8) => 'Carousel',
      (_, 2) => 'Video',
      _ => 'Photo',
    };

class SummaryView extends StatelessWidget {
  const SummaryView({
    super.key,
    required this.entries,
    required this.feed,
    required this.mediaDirectory,
    required this.now,
  });

  final List<FeedEntry> entries;
  final FeedKind feed;
  final Directory mediaDirectory;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final people = summarize(entries, now);
    final postCount = people.fold(0, (sum, person) => sum + person.posts.length);
    final theme = Theme.of(context);

    if (people.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No posts in ${feed.label} in the last 24 hours.\nPull down to refresh.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          'Last 24 hours · $postCount ${postCount == 1 ? 'post' : 'posts'} from ${people.length} '
          '${people.length == 1 ? 'person' : 'people'}',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        for (final person in people) ...[
          _PersonSection(person: person, mediaDirectory: mediaDirectory, now: now),
          const Divider(height: 24),
        ],
      ],
    );
  }
}

class _PersonSection extends StatelessWidget {
  const _PersonSection({required this.person, required this.mediaDirectory, required this.now});

  final PersonSummary person;
  final Directory mediaDirectory;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = person.avatarFile == null ? null : File('${mediaDirectory.path}/${person.avatarFile}');
    final count = person.posts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: avatar == null ? null : FileImage(avatar),
              child: avatar == null ? Text(person.username.characters.first.toUpperCase()) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(person.username, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text('$count ${count == 1 ? 'post' : 'posts'}', style: theme.textTheme.labelMedium),
          ],
        ),
        for (final post in person.posts)
          Padding(
            padding: const EdgeInsets.only(left: 38, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${timeAgo(post.takenAt!, now)} · ${postKind(post)}',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 2),
                (post.caption ?? '').trim().isEmpty
                    ? Text('No caption', style: TextStyle(color: theme.colorScheme.outline))
                    : ExpandableCaption(text: post.caption!.trim()),
              ],
            ),
          ),
      ],
    );
  }
}
