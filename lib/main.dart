import 'package:flutter/material.dart';

import 'database.dart';
import 'feed_kind.dart';
import 'home_screen.dart';
import 'media_downloader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final deleted = await deleteVideoFiles();
  await db.clearVideoFiles();
  debugPrint('[app] deleted $deleted video files from the last session');
  runApp(InstaReaderApp(db: db, initialFeed: await db.selectedFeed()));
}

class InstaReaderApp extends StatelessWidget {
  const InstaReaderApp({super.key, required this.db, required this.initialFeed});

  final AppDatabase db;
  final FeedKind initialFeed;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaReader',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: HomeScreen(db: db, initialFeed: initialFeed),
    );
  }
}
