import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const _backupChannel = MethodChannel('insta_reader/backup');

Future<Directory> mediaDirectory() async {
  final directory = Directory('${(await getApplicationSupportDirectory()).path}/media');
  await directory.create(recursive: true);
  return directory;
}

/// Videos only live for one app session; the next launch removes them,
/// including any partial download.
Future<int> deleteVideoFiles() async {
  var deleted = 0;
  await for (final entity in (await mediaDirectory()).list()) {
    if (entity is File && RegExp(r'\.mp4(\.part)?$').hasMatch(entity.path)) {
      await entity.delete();
      deleted++;
    }
  }
  return deleted;
}

Future<int> deleteAllMediaFiles() async {
  var deleted = 0;
  await for (final entity in (await mediaDirectory()).list()) {
    if (entity is File) {
      await entity.delete();
      deleted++;
    }
  }
  return deleted;
}

Future<({int files, int bytes})> mediaFolderUsage() async {
  var files = 0;
  var bytes = 0;
  await for (final entity in (await mediaDirectory()).list()) {
    if (entity is File) {
      files++;
      bytes += await entity.length();
    }
  }
  return (files: files, bytes: bytes);
}

class MediaDownloader {
  MediaDownloader._(this.directory, this.userAgent, this.excludedFromBackup);

  final Directory directory;
  final String userAgent;
  final bool? excludedFromBackup;
  final _client = HttpClient()..maxConnectionsPerHost = 3;
  final _inFlight = <String, Future<String>>{};
  int filesDownloaded = 0;
  int bytesDownloaded = 0;

  static Future<MediaDownloader> open({required String userAgent}) async {
    final directory = await mediaDirectory();
    final excluded = Platform.isIOS
        ? await _backupChannel.invokeMethod<bool>('excludeFromBackup', directory.path)
        : null;
    return MediaDownloader._(directory, userAgent, excluded);
  }

  /// Signed CDN links carry the size and signature in the query string, so
  /// the last path segment is a stable, unique name for the asset.
  Future<String> download(String url) {
    final uri = Uri.parse(url);
    final name = uri.pathSegments.last;
    return _inFlight.putIfAbsent(name, () => _download(uri, name));
  }

  /// The CDN has closed connections before sending headers, so a failed
  /// download gets one more attempt on a new request.
  Future<String> _download(Uri uri, String name) async {
    final target = File('${directory.path}/$name');
    if (await target.exists()) return name;
    try {
      await _fetchTo(uri, target);
    } on IOException {
      await _fetchTo(uri, target);
    }
    return name;
  }

  Future<void> _fetchTo(Uri uri, File target) async {
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.userAgentHeader, userAgent);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('HTTP ${response.statusCode}', uri: uri);
    }
    final partial = File('${target.path}.part');
    await response.pipe(partial.openWrite());
    bytesDownloaded += await partial.length();
    filesDownloaded++;
    await partial.rename(target.path);
  }

  void close() => _client.close();
}
