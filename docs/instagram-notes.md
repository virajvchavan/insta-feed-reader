# Instagram web: verified facts

These were checked on the user's iPhone 15 (iOS 27) in late October 2026, with the app posing as mobile
Safari at 390×844. `PROMPT.md` lists earlier checks made in desktop Chrome. Instagram changes often, so
re-check anything that starts failing.

## Feeds

- **URLs.** Following is `https://www.instagram.com/?variant=following`, which is chronological.
  Favorites is `https://www.instagram.com/?variant=favorites`, which is limited to 50 accounts. The plain
  home feed, `https://www.instagram.com/`, was dropped from the app.
- **Same data key.** All three feeds use `xdt_api__v1__feed__timeline__connection`, which holds `edges[]`
  and `page_info { end_cursor, has_next_page }`.
- **Page 1 is inline.** It's in `<script type="application/json">` and holds about 3 posts. Later pages come
  through **XHR** (not fetch) to `/graphql/query`, with 4–8 posts each.
- **The hook really does run first.** At injection, `readyState` is `loading`, there are 0 scripts in the
  DOM, and fetch and XHR are still the browser's own.
- **The plugin's ready event is too late to wait for.** `flutterInAppWebViewPlatformReady` only fires at
  full page load, which took 17–25 s on the home page. `callHandler` already works at document start on
  iOS, so the hook sends right away. The queue is only a fallback.
- **Favorites repeats itself.** After roughly 32 posts, the Favorites feed keeps sending pages of posts it
  has already sent, with `has_next_page` still true. That's why the "2 repeat pages" stop exists.
- **Non-post items seen so far:** `ad` and `suggested_users` (both on the home feed), plus an
  `XDTFeedItem` whose keys weren't recognised. Unknown items are now logged as `type{key,key}`.

## Media

- **Photo sizes.** `image_versions2.candidates` first lists sizes in the photo's real shape (for example
  1440, 1290, 1170, 1080, 828, 720, 640, 480, 320 and 240 px wide), then square crops (1080×1080 and
  smaller) used for profile grids. The app takes the smallest real-shape size that's at least 720 px wide.
- **Only one video size.** Every entry in `video_versions` has the same URL: a single 720p MP4 at roughly
  0.27 MB per second of video. A 360p version exists only in `video_dash_manifest`, where video and audio
  are separate tracks. iOS can't play those as a local file without merging them.
- **Links expire.** CDN links are signed and stop working after about 4 days for images and about 1.5 days
  for videos.
- **Dropped connections.** The CDN sometimes closes a connection before sending headers ("Connection closed
  before full header was received"). One retry handles it.

## Unread messages

- **Where the count comes from.** The page sends a GraphQL request named `IGDBadgeCountOffMsysQuery` to
  `/api/graphql` about 0–2 s after page 1. The response looks like this:
  `data.get_slide_mailbox_for_iris_subscription.threads_by_folder.edges[].node.as_ig_direct_thread`
  with the fields `marked_as_unread`, `last_activity_timestamp_ms`, `is_muted`, and
  `slide_read_receipts[] { participant_fbid, watermark_timestamp_ms }`.
- **How the count is worked out.** There's no ready-made number. A conversation is unread if it's marked
  unread, or if the viewer's watermark is older than its last activity. Muted conversations are skipped.
  The viewer is the only `participant_fbid` that appears in every conversation.
- **Checked against Instagram.** This rule gave 2, which matched the page's own badge (the messages link
  read "Messages2").
- **Shape.** The response holds the 15 most recent conversations and has `has_next_page`.

## Browser identity

- **The OS version is frozen.** On iOS 27, WKWebView's own agent says `iPhone OS 18_7`. The app adds
  `Version/27.0.1 Mobile/15E148 Safari/604.1`. `navigator.userAgentData` is null on iOS.
- **Android is unchecked.** The `X-Requested-With` setting and the `DOCUMENT_START_SCRIPT` support check
  are both written but haven't been tried on a device.
