# Status

Last updated 2026-10-31.

## Current spec (overrides `PROMPT.md` where they differ)

The user changed these points while building:

- **Tabs and pages**
  - The app has three tabs: Summary, Feed and Messages. The Summary is the main page.
  - **Summary** covers the last 24 hours as a plain grouped list (who, how many posts, each caption). It
    uses no AI, since this pass has none, and shows no post photos.
  - **Messages** shows Instagram's own inbox page "as it is". The user can send messages there by hand;
    the app itself still never takes any action.
  - The Messages tab shows the number of **unread conversations**, updated on each refresh.
- **Feeds**
  - A **Favorites / Following switch** controls Summary, Feed and what a refresh fetches. The last choice
    is remembered. The plain home feed option was dropped. Favorites came first; Following was added
    because Instagram limits Favorites to 50 accounts.
- **Media**
  - **Reels** are stored and shown with their cover image and details, but their videos are never
    downloaded.
  - **Videos in regular posts** (carousel slides and old-style video posts) are downloaded, then deleted at
    the next launch. The user asked for "delete when the app closes", but iOS has no reliable close event.
  - **Downloads start after scrolling finishes**, not during it.
  - **Photos are saved at 720 px**, for speed.
  - Media lives in App Support and is **excluded from iCloud backup**.
- **Data:** the early test posts from Following and Home were deleted, and the store was refilled from
  Favorites.

## Built and checked on the iPhone

- **Login:** the visible WebView, with cookies kept between sessions. The hidden WebView loads the feed
  while logged in.
- **The hook:** it runs before Instagram's scripts. It catches the inline page and the XHR pages.
- **Saving:** posts are deduplicated. A refresh stops at a post already in the feed and stops on repeated
  pages. The data survives app restarts.
- **Files:** downloads, retries, and catching up on files a refresh missed. The iCloud exclusion flag reads
  back true. Last session's videos are deleted at launch.
- **Database upgrades:** version 1 to 2 (post shape) and version 2 to 3 (feed markers and settings) both ran
  on the phone.
- **Screens:** Summary, Feed and Messages, the feed switch, and remembering the feed choice.
- **Unread rule:** it gave 2 when run on a real captured response, matching Instagram's own badge.

## Built but NOT yet checked on the device

- **The unread badge from start to finish.** It's built and passes its unit tests, but no refresh has run
  on that build yet. The phone's database has no `unread_conversations` setting so far.
- **The 50-post cap.** The first Following refresh was cut off after 2 pages when the phone locked. 7
  Following posts are stored, and 27 images are waiting for the next refresh to download them.
- **Tap-to-play for post videos**, and **Open in Instagram**.
- **720 px photos on new posts.** The selection logic is unit-tested.

## Known issues

- **Disconnects.** When the phone locks, the debug run ends. The user hasn't yet chosen between turning
  off Auto-Lock while testing and installing a standalone release build.
- **Summary window.** The 24-hour window only moves when the screen rebuilds.
- **Swift Package Manager.** `flutter_inappwebview_ios` doesn't support it, so Flutter prints a warning that
  will become an error in a future version.
- **Android has never been built.** The build was stopped at the user's request, and the Android SDK
  licenses haven't been accepted (`flutter doctor --android-licenses`).

## Next steps

1. Check the unread badge and the remaining items above on the phone. The phone needs to stay unlocked.
2. **Step 4 from `PROMPT.md`:** a debug screen showing:
   - stats from the last refresh: pages, posts found, new vs duplicate, skipped item types, errors
   - a list of posts that opens each one's raw JSON
   - an export of everything as a JSON file
   It replaces `lib/spike_screen.dart`. Most stats already exist in `FetchReport`, but the report isn't
   saved anywhere yet.
3. The Android spike: build, log in, capture a page, and check document-start timing and
   `X-Requested-With`.
4. Later, as requested by the user: rules to clean up old media.
