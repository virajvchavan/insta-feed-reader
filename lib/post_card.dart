import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'database.dart';
import 'profile_sheet.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String timeAgo(DateTime time, DateTime now) {
  final age = now.difference(time);
  if (age.inMinutes < 1) return 'now';
  if (age.inHours < 1) return '${age.inMinutes}m';
  if (age.inDays < 1) return '${age.inHours}h';
  if (age.inDays < 7) return '${age.inDays}d';
  final date = '${time.day} ${_months[time.month - 1]}';
  return time.year == now.year ? date : '$date ${time.year}';
}

String formatCount(int count) =>
    count.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.entry,
    required this.mediaDirectory,
    this.onUserTap,
    this.onPostTap,
    this.fullCaption = false,
  });

  final FeedEntry entry;
  final Directory mediaDirectory;
  final void Function(String username)? onUserTap;
  final void Function(FeedEntry entry)? onPostTap;
  final bool fullCaption;

  File? _file(String? name) => name == null ? null : File('${mediaDirectory.path}/$name');

  @override
  Widget build(BuildContext context) {
    final post = entry.post;
    final avatar = _file(post.avatarFile);
    final username = post.username ?? 'unknown';
    final caption = post.caption ?? '';
    final permalink = post.code == null ? null : Uri.parse('https://www.instagram.com/p/${post.code}/');

    void openPost() {
      if (post.code != null) {
        onPostTap?.call(entry);
        openPostWeb(context, post.code!);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          leading: GestureDetector(
            onTap: () => onUserTap?.call(username),
            child: CircleAvatar(
              backgroundImage: avatar == null ? null : FileImage(avatar),
              child: avatar == null ? Text(username.characters.first.toUpperCase()) : null,
            ),
          ),
          title: GestureDetector(
            onTap: () => onUserTap?.call(username),
            child: Text(username, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          subtitle: post.takenAt == null ? null : Text(timeAgo(post.takenAt!, DateTime.now())),
        ),
        AspectRatio(
          // Instagram's feed frames posts between 4:5 portrait and 1.91:1 landscape.
          aspectRatio: (post.aspectRatio ?? 1).clamp(0.8, 1.91),
          child: _MediaPager(media: entry.media, isReel: post.productType == 'clips', fileFor: _file),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: post.code == null ? null : openPost,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 20),
                      const SizedBox(width: 4),
                      Text(post.likeCount == null ? '–' : formatCount(post.likeCount!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: post.code == null ? null : openPost,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 20),
                      const SizedBox(width: 4),
                      Text(post.commentCount == null ? '–' : formatCount(post.commentCount!)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (permalink != null)
                TextButton.icon(
                  onPressed: () => launchUrl(permalink, mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open in Instagram'),
                ),
            ],
          ),
        ),
        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: fullCaption
                ? Text.rich(
                    TextSpan(
                      children: [
                        if (username.isNotEmpty)
                          TextSpan(text: '$username ', style: const TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(text: caption),
                      ],
                    ),
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  )
                : ExpandableCaption(username: username, text: caption),
          ),
        if (post.code != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: openPost,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(width: 8),
                    Text(
                      'Add a comment…',
                      style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MediaPager extends StatefulWidget {
  const _MediaPager({required this.media, required this.isReel, required this.fileFor});

  final List<StoredMedia> media;
  final bool isReel;
  final File? Function(String? name) fileFor;

  @override
  State<_MediaPager> createState() => _MediaPagerState();
}

class _MediaPagerState extends State<_MediaPager> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.media.length;
    if (count == 0) return const _Placeholder(icon: Icons.image_not_supported_outlined);
    if (count == 1) return _MediaView(media: widget.media.first, isReel: widget.isReel, fileFor: widget.fileFor);

    return Stack(
      children: [
        PageView.builder(
          itemCount: count,
          onPageChanged: (page) => setState(() => _page = page),
          itemBuilder: (_, index) =>
              _MediaView(media: widget.media[index], isReel: widget.isReel, fileFor: widget.fileFor),
        ),
        Positioned(top: 8, right: 8, child: _Badge(label: '${_page + 1}/$count')),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(count, (index) {
                  final active = index == _page;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: active ? 6 : 5,
                    height: active ? 6 : 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? Colors.white : Colors.white38,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaView extends StatelessWidget {
  const _MediaView({required this.media, required this.isReel, required this.fileFor});

  final StoredMedia media;
  final bool isReel;
  final File? Function(String? name) fileFor;

  @override
  Widget build(BuildContext context) {
    final image = fileFor(media.imageFile);
    final video = fileFor(media.videoFile);
    final cover = image == null
        ? const _Placeholder(icon: Icons.image_outlined)
        : Image.file(
            image,
            fit: BoxFit.cover,
            cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
          );

    if (video != null || media.videoUrl != null) {
      return _VideoView(file: video, url: media.videoUrl, isReel: isReel, cover: cover);
    }
    return cover;
  }
}

class _VideoView extends StatefulWidget {
  const _VideoView({this.file, this.url, required this.isReel, required this.cover});

  final File? file;
  final String? url;
  final bool isReel;
  final Widget cover;

  @override
  State<_VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<_VideoView> {
  VideoPlayerController? _controller;
  bool _initializing = false;

  Future<void> _togglePlayback() async {
    if (_initializing) return;
    VideoPlayerController? controller = _controller;
    if (controller == null) {
      if (widget.file != null) {
        controller = _controller = VideoPlayerController.file(widget.file!);
      } else if (widget.url != null) {
        controller = _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
      } else {
        return;
      }
    }
    if (!controller.value.isInitialized) {
      setState(() => _initializing = true);
      try {
        await controller.initialize();
        await controller.setLooping(true);
      } catch (e) {
        debugPrint('[video] error: $e');
      } finally {
        if (mounted) setState(() => _initializing = false);
      }
    }
    if (controller.value.isInitialized) {
      controller.value.isPlaying ? await controller.pause() : await controller.play();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final initialized = controller?.value.isInitialized ?? false;
    final playing = controller?.value.isPlaying ?? false;

    return GestureDetector(
      onTap: _togglePlayback,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (initialized)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            )
          else
            widget.cover,
          if (widget.isReel)
            const Positioned(top: 8, right: 8, child: _Badge(label: 'Reel', icon: Icons.movie_outlined))
          else if (widget.url != null)
            const Positioned(top: 8, right: 8, child: _Badge(label: 'Video', icon: Icons.videocam_outlined)),
          if (_initializing)
            const Center(child: CircularProgressIndicator(color: Colors.white70))
          else if (!playing)
            const Center(child: Icon(Icons.play_circle_fill, size: 56, color: Colors.white70)),
        ],
      ),
    );
  }
}

class ExpandableCaption extends StatefulWidget {
  const ExpandableCaption({super.key, this.username, required this.text, this.maxLines = 3});

  final String? username;
  final String text;
  final int maxLines;

  @override
  State<ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<ExpandableCaption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Text.rich(
        TextSpan(
          children: [
            if (widget.username != null)
              TextSpan(text: '${widget.username} ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: widget.text),
          ],
        ),
        maxLines: _expanded ? null : widget.maxLines,
        overflow: _expanded ? null : TextOverflow.ellipsis,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: Colors.white), const SizedBox(width: 4)],
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(child: Icon(icon, size: 40, color: Theme.of(context).colorScheme.outline)),
    );
  }
}

class CompactPostTile extends StatelessWidget {
  const CompactPostTile({
    super.key,
    required this.entry,
    required this.mediaDirectory,
    this.onUserTap,
    this.onPostTap,
  });

  final FeedEntry entry;
  final Directory mediaDirectory;
  final void Function(String username)? onUserTap;
  final void Function(FeedEntry entry)? onPostTap;

  File? _file(String? name) => name == null ? null : File('${mediaDirectory.path}/$name');

  @override
  Widget build(BuildContext context) {
    final post = entry.post;
    final username = post.username ?? 'unknown';
    final avatar = _file(post.avatarFile);
    final firstMedia = entry.media.firstOrNull;
    final thumbnail = _file(firstMedia?.imageFile);
    final isReel = post.productType == 'clips';
    final hasMultiple = entry.media.length > 1;

    void openPost() {
      if (post.code != null) {
        onPostTap?.call(entry);
        openPostWeb(context, post.code!);
      }
    }

    return InkWell(
      onTap: post.code == null ? null : openPost,
      child: Opacity(
        opacity: post.isRead ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbnail != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        thumbnail,
                        fit: BoxFit.cover,
                        cacheWidth: 150,
                        cacheHeight: 150,
                      ),
                      if (hasMultiple)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.photo_library_outlined, size: 10, color: Colors.white),
                                const SizedBox(width: 2),
                                Text(
                                  '${entry.media.length}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isReel || (!isReel && firstMedia?.videoUrl != null))
                        const Positioned(
                          bottom: 4,
                          right: 4,
                          child: Icon(Icons.play_circle_fill, size: 16, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => onUserTap?.call(username),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundImage: avatar == null ? null : FileImage(avatar),
                          child: avatar == null
                              ? Text(username.characters.first.toUpperCase(), style: const TextStyle(fontSize: 10))
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: GestureDetector(
                          onTap: () => onUserTap?.call(username),
                          child: Text(
                            username,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                      if (post.takenAt != null) ...[
                        const SizedBox(width: 4),
                        const Text('·', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo(post.takenAt!, DateTime.now()),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  if (post.caption case final caption? when caption.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (post.likeCount != null) ...[
                        GestureDetector(
                          onTap: post.code == null ? null : openPost,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(formatCount(post.likeCount!), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (post.commentCount != null) ...[
                        GestureDetector(
                          onTap: post.code == null ? null : openPost,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mode_comment_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(formatCount(post.commentCount!), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (isReel) ...[
                        const Icon(Icons.movie_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Reel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ] else if (hasMultiple) ...[
                        const Icon(Icons.photo_library_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${entry.media.length}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({
    super.key,
    required this.entry,
    required this.mediaDirectory,
    this.onUserTap,
  });

  final FeedEntry entry;
  final Directory mediaDirectory;
  final void Function(String username)? onUserTap;

  @override
  Widget build(BuildContext context) {
    final username = entry.post.username ?? 'Post';
    return Scaffold(
      appBar: AppBar(title: Text(username)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              PostCard(
                entry: entry,
                mediaDirectory: mediaDirectory,
                onUserTap: onUserTap,
                fullCaption: true,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
