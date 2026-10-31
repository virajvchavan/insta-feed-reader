# Architecture

## Screens

`HomeScreen` (`lib/home_screen.dart`) has three bottom tabs:

1. **Summary** (`lib/summary_view.dart`) shows the last 24 hours, grouped by person. Each person gets a post
   count, and each post shows its time, type (Photo, Carousel, Video or Reel) and caption. Post photos are
   not shown; a small avatar is.
2. **Feed** (`lib/post_card.dart`) shows full cards: avatar, username, time, photos (swipe through
   carousels, with a "2/7" counter), a "Reel" badge on Reel covers, tap-to-play for this session's videos,
   likes and comments, an expandable caption, and "Open in Instagram".
3. **Messages** (`lib/messages_view.dart`) shows Instagram's own `/direct/inbox/` page in a visible WebView.
   The WebView is created the first time the tab opens and kept alive afterwards. The tab's badge is the
   number of unread conversations.

On the Summary and Feed tabs, the top bar has:
- the **Favorites ▾ / Following** switch, which is saved in the database, and
- **🐞**, which opens the debug screen.

**Login** (`lib/login_screen.dart`, `openLogin()`) opens in two cases:
- on launch, when there is no `sessionid` cookie
- when a refresh lands on a login or checkpoint page. The hidden WebView is then shown as it is, through
  `InAppWebView(headlessWebView: …)`.

The **debug screen** (`lib/spike_screen.dart`) is left over from the spike. It runs a refresh with a
verbose log, shows storage stats, and has Log in and Clear stored data buttons. Step 4 replaces it.

## Startup (`lib/main.dart`)

1. Open the database.
2. Delete every video file left from the last session, and clear `video_file` in the database.
3. Read the saved feed choice.
4. Run the app.

`HomeScreen` then loads the saved unread count and checks for a session cookie.

## A refresh, step by step (`lib/feed_fetcher.dart`)

1. **Build the WebView settings** (`lib/browser.dart`). The user agent comes from the device's own WebView
   agent. On Android, `; wv` and `Version/x` are removed. On iOS, `Version/<iOS version> … Safari/604.1` is
   added. `X-Requested-With` is turned off on Android.
2. **Check for a session.** With no `sessionid` cookie, stop and ask the user to log in.
3. **Load the feed** in a `HeadlessInAppWebView` sized 390×844, at the selected feed's URL
   (`lib/feed_kind.dart`). `assets/feed_hook.js` is injected at document start, in the main frame only.
4. **The hook runs before any Instagram script.** It:
   - wraps `fetch` and `XMLHttpRequest`
   - sends `graphqlStart` for every `/graphql` request
   - sends the body of any `/graphql` response that contains the feed key
   - sends the `IGDBadgeCountOffMsysQuery` response, which holds the unread-message data
   - scans inline `<script type="application/json">` tags at `DOMContentLoaded` and at `load`
   - reports `hookInstalled`, which proves its timing: readyState, scripts in the DOM, and whether
     fetch/XHR were still the browser's own
   - sends everything through `flutter_inappwebview.callHandler('feedHook', …)`
5. **Parse and save, one page at a time.** `lib/feed_parser.dart` parses each body.
   `AppDatabase.savePost(post, feed)` returns one of:
   - `newPost`: stored for the first time
   - `addedToFeed`: already stored from the other feed, now marked for this one too
   - `alreadyInFeed`: already in this feed
6. **Scroll.** Pause 0.9–2.7 s, sometimes with an extra 2.5–6 s, then scroll 0.8–1.8 screens. Stop at the
   first of these:
   - the refresh was blocked
   - a post is `alreadyInFeed`
   - 2 pages in a row only repeat posts seen earlier in this refresh
   - 80 scrolls
   - 50 posts
   - `has_next_page` is false
   - no new page after 8 scrolls. This also saves a screenshot to `Library/Caches/stall.png`.
7. **Wait for the inbox badge** for up to 5 seconds, if it hasn't arrived yet.
8. **Close the WebView**, unless the refresh was blocked. In that case the login screen takes it over.
9. **Download everything still missing** (`lib/media_downloader.dart`):
   - avatars and images for every stored post
   - videos for this refresh's new posts, except Reels
   - at most 3 connections per server, with one retry on network errors

## Storage

- **Database:** drift, at `Library/Application Support/insta_reader.sqlite`, schema version 3.
  - `posts`: the clean fields, the full raw media JSON (`raw_json`), avatar file, `aspect_ratio`, and
    `in_favorites` / `in_following`.
  - `post_media`: one row per photo or video. Carousel items are in order; a single post has one row at
    position 0. Holds URLs and downloaded file names.
  - `app_settings`: `feed` (the last selected feed) and `unread_conversations`.
  - File columns hold names relative to the media folder, because iOS moves the app container when the
    app updates.
- **Media:** `Library/Application Support/media/`. The folder is excluded from iCloud backup through the
  `insta_reader/backup` method channel in `ios/Runner/AppDelegate.swift`. Each file is named after the last
  path segment of its CDN URL.
- **Videos last one session.** The next launch deletes them.

## Files

| File | What it does |
|---|---|
| `lib/main.dart` | Startup |
| `lib/home_screen.dart` | Tabs, refresh, feed switch, unread badge |
| `lib/summary_view.dart` | 24-hour grouping (`summarize`) and the Summary UI |
| `lib/post_card.dart` | Post card, video playback, `timeAgo`, `formatCount`, `ExpandableCaption` |
| `lib/messages_view.dart` | Messages tab WebView |
| `lib/login_screen.dart` | Visible WebView for login and checkpoints |
| `lib/spike_screen.dart` | Debug screen (temporary) |
| `lib/feed_fetcher.dart` | Hidden WebView, scroll loop, saving, downloads, `FetchReport` |
| `assets/feed_hook.js` | Document-start hook |
| `lib/feed_parser.dart` | Finds feed pages at any depth, `Post` model, picks the photo size |
| `lib/inbox_parser.dart` | Unread conversation count |
| `lib/database.dart` | Schema, migrations, queries, settings (`database.g.dart` is generated) |
| `lib/media_downloader.dart` | Media folder, downloads, video cleanup, iCloud exclusion |
| `lib/browser.dart` | User agent, WebView settings, session cookie check |
| `lib/feed_kind.dart` | Favorites and Following, with their URLs |
| `ios/Runner/AppDelegate.swift` | `insta_reader/backup` method channel |
