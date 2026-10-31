# InstaReader

A personal, single-user Flutter app, sideloaded onto the user's iPhone. A hidden WebView loads the user's
Instagram feed, picks up the post data Instagram's own web page receives, stores it on the phone, and shows
it in the app's own UI. The app is read-only: it never likes, follows, comments or sends anything by itself.

Read these before changing anything:

- `docs/status.md` covers the current spec, what works, what is untested, and what to do next. **`PROMPT.md`
  is the original brief, but parts of it are out of date.** `docs/status.md` says which parts.
- `docs/architecture.md` explains how a refresh works, where data is stored, and what each file does.
- `docs/instagram-notes.md` lists facts about Instagram's web data, checked on the real phone. Read it
  before touching `assets/feed_hook.js` or the parsers.

## Working rules (from the user)

- Ask before choosing anything the spec doesn't cover, such as a library, storage location, or UI
  behaviour. Give a recommendation with the question.
- Test on the real iPhone only. Don't use emulators or simulators, because Instagram is more likely to show
  a "was this you?" check on them. Android isn't set up yet.
- A refresh only runs when the user pulls to refresh. No background jobs.
- The Mac's disk is nearly full. Check `df -h /System/Volumes/Data` before big downloads, warn below about
  15 GB, and let the user pick what to delete.
- Never print or commit the user's private data, such as message contents or captured responses. When
  investigating, print structure and counts only.

## Commands

```sh
flutter analyze
flutter test
dart run build_runner build   # after changing lib/database.dart; regenerates lib/database.g.dart
```

## Running on the iPhone

- The device is an iPhone 15 on iOS 27, UDID `00008120-000625C802E1A01E`. The signing team is `VR64YX76UK`.
  Xcode is signed in and Developer Mode is on.
- Run in the background and send the logs to a file, then watch that file:
  `flutter run -d 00008120-000625C802E1A01E --debug > <scratchpad>/ios_run.log 2>&1`
- Log prefixes are `[app]` for startup, `[refresh]` for a refresh started from the tabs, and `[spike]` for
  the debug screen.
- To hot restart a background `flutter run` without a keyboard, send `kill -USR2 <pid>`. The pid is the
  `dartvm` process whose arguments include `run`. `-USR1` does a hot reload. Native changes, such as new
  plugins or Swift code, need a full re-run.
- When the phone locks, iOS pauses the app and the run ends with "Lost connection to device". Ask the user
  to keep it unlocked, or to set Auto-Lock to Never.
- `flutter screenshot` doesn't work on this phone, so ask the user what they see.
- You can read app files from the Mac without the debugger:
  - To list files:
    `xcrun devicectl device info files --device <UDID> --domain-type appDataContainer --domain-identifier com.virajchavan.instareader --subdirectory "Library/Application Support/media"`
  - To copy the database:
    `xcrun devicectl device copy from --device <UDID> --domain-type appDataContainer --domain-identifier com.virajchavan.instareader --source "Library/Application Support/insta_reader.sqlite" --destination <file>`,
    then query it with `sqlite3 -readonly`.
  - On iOS, `getTemporaryDirectory()` is `Library/Caches`, not `tmp`.

## Code conventions

- **Comments:** a PostToolUse hook (`windbag`) blocks edits whose comments describe history, hedge, restate
  the code, mention tickets, or run long compared with the code they explain. A comment should state the
  constraint that makes the code correct. If there's no such constraint, leave the comment out.
- **Style:** match the code around you. That means single quotes, lines up to about 120 columns, and small
  private widgets kept in the same file.
- **Tests** use an in-memory drift database (`AppDatabase(NativeDatabase.memory())`). Two `AppDatabase`s
  open in one test cause a drift warning, so keep `setUp` scoped to the groups that need it.
- **Schema changes:** bump `schemaVersion`, add an `onUpgrade` step, and extend the upgrade test in
  `test/database_test.dart`. That test starts from the real version 1 schema.
- **Git:** the project is not a git repository yet.
