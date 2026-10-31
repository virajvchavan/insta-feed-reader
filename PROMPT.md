# Project: Personal Instagram feed reader, pass 1 (no AI)

## Goal
Build a personal (single-user, sideloaded) Flutter app for Android and iOS. A hidden WebView loads my Instagram feed, extracts every post's data, stores it locally, and shows it in my own simple UI. There's no filtering yet. This pass proves the extraction pipeline works on real devices.

## Stack
- Flutter + `flutter_inappwebview` (`HeadlessInAppWebView`)
- `drift` (or `sqflite`) for local storage
- No AI or API keys in this pass

## Verified facts (tested in desktop Chrome on instagram.com while logged in, Oct 2026)
- Feed URL: `https://www.instagram.com/?variant=following` (chronological Following feed). Add a toggle for the default home feed.
- The first batch of posts is inline JSON in `<script type="application/json">` tags, under the key `xdt_api__v1__feed__timeline__connection` → `{ edges[], page_info { end_cursor, has_next_page } }`.
- Scrolling (`window.scrollBy`) triggers pagination via POST `/graphql/query`. The responses contain the same key. Strip a possible `for (;;);` prefix before parsing.
- Each `edge.node` has `media`, `ad`, `explore_story`, `suggested_users`, `end_of_feed_demarcator`, `stories_netego`, `bloks_netego`, `__typename`. Keep nodes with `media` as posts. Count the other node types and log them (don't display them).
- Useful `media` fields: `pk`/`id`, `code` (instagram.com/p/{code}), `user.username`, `user.profile_pic_url`, `caption.text`, `taken_at`, `like_count`, `comment_count`, `media_type` (1 photo, 2 video, 8 carousel), `product_type` (`feed`, `clips`, `carousel_container`), `image_versions2.candidates[0].url`, `video_versions[0].url` (direct .mp4), `carousel_media[]` (each with its own image or video), `accessibility_caption`.
- CDN URLs (`*.fbcdn.net`) are signed and expire, observed at about 4 days for images and about 1.5 days for videos. Download media when it's captured.
- Use a tolerant recursive finder for the connection key and media nodes. Don't hard-code deep paths.

## What to build
1. **Login screen:** show the WebView visibly the first time so I can log in manually. Cookies persist. Never handle my password.
2. **Fetcher:** HeadlessInAppWebView with a real viewport size (390×844).
   - Inject a DOCUMENT_START user script that hooks `fetch` and `XMLHttpRequest` and sends feed connections to Dart via a JS handler. Also parse the inline `<script>` JSON on page load.
   - Auto-scroll with randomized human-like pacing. Stop at an already-stored post ID, or at a cap (default 50).
   - Use a normal mobile browser user agent (no `; wv`). On Android, suppress the `X-Requested-With` header.
   - If a login or checkpoint page appears, stop and surface the WebView visibly.
3. **Storage:** store each post's normalized fields AND its full raw `media` JSON (for later), plus the downloaded media file paths. Dedupe by post ID.
4. **Feed screen (cache-first):**
   - Show stored posts instantly with pull-to-refresh and an "Updating…" indicator.
   - Simple cards: author and avatar, time, caption, the image (swipeable for carousels), Reels playing from the local file, like and comment counts, and an "Open in Instagram" link.
5. **Debug screen:**
   - Last refresh stats: pages captured, posts found, new vs. duplicate, skipped node types and their counts, errors
   - A tappable list of posts showing the raw JSON
   - Export everything as a JSON file

## Rules
- Strictly read-only: no likes, follows, comments or any write actions.
- Refresh only when I trigger it (pull-to-refresh). No background jobs yet.

## Build order (stop and show me results after each step)
1. **Spike:** log in, capture one page of feed JSON on BOTH Android and iOS, and print normalized posts to the console. Confirm the document-start hook fires before Instagram's scripts.
2. Storage plus media download.
3. Feed screen.
4. Debug screen and JSON export.

Ask me before choosing anything not specified here.
