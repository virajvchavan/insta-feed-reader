import 'dart:io';

import 'package:flutter/material.dart';

import 'database.dart';
import 'profile_sheet.dart';

class StoriesTray extends StatelessWidget {
  const StoriesTray({
    super.key,
    required this.db,
    required this.mediaDirectory,
    this.onStoryTap,
  });

  final AppDatabase db;
  final Directory mediaDirectory;
  final void Function(String username)? onStoryTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: db.ownUsername(),
      builder: (context, ownUserSnapshot) {
        final ownUsername = ownUserSnapshot.data;
        return StreamBuilder<List<StoredStory>>(
          stream: db.watchStories(),
          builder: (context, snapshot) {
            final stories = snapshot.data ?? const [];

            final bool hasOwnStory = ownUsername != null &&
                stories.isNotEmpty &&
                stories.first.username.toLowerCase() == ownUsername.toLowerCase();

            final List<StoredStory> otherStories =
                hasOwnStory ? stories.sublist(1) : stories;

            final StoredStory? ownStory = hasOwnStory ? stories.first : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 106,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    itemCount: 1 + otherStories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _StoryItemView(
                          label: 'Your story',
                          avatarFile: ownStory?.avatarFile,
                          avatarUrl: ownStory?.avatarUrl,
                          mediaDirectory: mediaDirectory,
                          hasUnseen: ownStory?.hasUnseen ?? false,
                          isYourStory: true,
                          onTap: () {
                            if (ownStory != null) {
                              _onTap(context, ownStory.username);
                            } else if (ownUsername != null && ownUsername.isNotEmpty) {
                              openProfile(context, username: ownUsername, db: db);
                            } else {
                              openProfile(context, db: db);
                            }
                          },
                        );
                      }

                      final story = otherStories[index - 1];
                      return _StoryItemView(
                        label: story.username,
                        avatarFile: story.avatarFile,
                        avatarUrl: story.avatarUrl,
                        mediaDirectory: mediaDirectory,
                        hasUnseen: story.hasUnseen,
                        isYourStory: false,
                        onTap: () => _onTap(context, story.username),
                      );
                    },
                  ),
                ),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
              ],
            );
          },
        );
      },
    );
  }

  void _onTap(BuildContext context, String username) async {
    if (onStoryTap != null) {
      onStoryTap!(username);
    } else {
      await openStoryWeb(context, username);
    }
    await db.markStorySeen(username);
  }
}

class _StoryItemView extends StatelessWidget {
  const _StoryItemView({
    required this.label,
    required this.avatarFile,
    required this.avatarUrl,
    required this.mediaDirectory,
    required this.hasUnseen,
    required this.isYourStory,
    required this.onTap,
  });

  final String label;
  final String? avatarFile;
  final String? avatarUrl;
  final Directory mediaDirectory;
  final bool hasUnseen;
  final bool isYourStory;
  final VoidCallback onTap;

  static const _gradientColors = [
    Color(0xFFFBAA47),
    Color(0xFFD91A46),
    Color(0xFFA60F93),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringBgColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 74,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 74,
              height: 74,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (hasUnseen)
                    Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: _gradientColors,
                        ),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ringBgColor,
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: ClipOval(child: _buildAvatar()),
                      ),
                    )
                  else if (!isYourStory)
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF383838) : const Color(0xFFDBDBDB),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ringBgColor,
                        ),
                        padding: const EdgeInsets.all(1.5),
                        child: ClipOval(child: _buildAvatar()),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ClipOval(child: _buildAvatar()),
                    ),
                  if (isYourStory)
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 21,
                        height: 21,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF262626),
                          border: Border.all(
                            color: ringBgColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatarFile != null) {
      final file = File('${mediaDirectory.path}/$avatarFile');
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => _defaultPlaceholder(),
        );
      }
    }

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _defaultPlaceholder(),
      );
    }

    return _defaultPlaceholder();
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: const Color(0xFFE0E0E0),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person,
        size: 34,
        color: Color(0xFF8E8E93),
      ),
    );
  }
}
