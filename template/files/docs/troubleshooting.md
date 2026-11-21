# Troubleshooting

Problems already hit in this workflow, with the cause and the fix. Search this page for the error text before you
debug. Add every new one, in the same PR as its fix.

## Cloud environment (`native-mobile`)

**Setup script fails on container start with exit 127, "command not found".**
`$SUDO DEBIAN_FRONTEND=noninteractive apt-get …` breaks when running as root: `$SUDO` is empty, so the variable
assignment becomes the command name. Fix (in the script): `$SUDO env DEBIAN_FRONTEND=noninteractive apt-get …`.

**`swiftly init` / `swiftly install` fail with a gpg import error.**
swift.org serves `keys/all-keys.asc` gzip-encoded and swiftly passes the compressed bytes to `gpg --import`. Fix: the
script downloads the official Swift tarball, imports keys with `curl --compressed`, checks the `.sig` and extracts to
`/opt/swift`.

**`swift: command not found` in a session, though setup succeeded.**
Some commands run in non-login shells that never read `.bashrc`. Fix: the script links the Swift tools into
`/usr/local/bin`.

**Gradle compiles with the wrong JDK (21 instead of 17).**
`JAVA_HOME` was derived from `javac`, which resolves to the image's default JDK. Fix: the script pins
`/usr/lib/jvm/java-17-openjdk-<arch>`; the environment's variables set it too.

**A download is blocked in a session.**
The environment's network access is too narrow. Use Custom with the default list plus `dl.google.com`,
`maven.google.com`, `services.gradle.org`, `plugins.gradle.org`, `download.swift.org` (or Full).

## Android

**Robolectric: "Android SDK 36 requires Java 21".**
Robolectric can't sandbox SDK 35+ on Java 17. Fix: the unit-test tasks use a JDK 21 toolchain
(`app/build.gradle.kts`); CI installs JDK 21 and 17 (17 last, so it is `JAVA_HOME`).

**A newer AndroidX/Compose version fails to build, asking for compileSdk 37.**
The newest AndroidX releases need SDK 37. Keep the newest version that supports 36, or bump the SDK everywhere in one
PR (see `playbook.md`).

**`verifyRoborazziDebug` fails after a UI change.**
The committed images are stale. Run `./gradlew :app:recordRoborazziDebug`, look at the new PNGs and commit them. The
`test-reports` artifact of the failed run has the diff images.

**After clearing a search, the list stays scrolled down (top items hidden).**
`LazyColumn` keeps its scroll anchor on the last match. Fix: scroll back to the top whenever the query changes.

**Maestro on the emulator: the first run is slow.**
The first run creates and caches the AVD snapshot (about 2 minutes, about 2.3 GB of cache under
`avd-36-google_apis-x86_64`). Later runs boot from the cache.

## iOS and the Mac runner

**SwiftPM can't read its cached package checkouts on the Mac runner.**
The runner's git sets `safe.bareRepository=explicit`. Fix, without touching any git config file: set
`GIT_CONFIG_COUNT=1`, `GIT_CONFIG_KEY_0=safe.bareRepository`, `GIT_CONFIG_VALUE_0=all` as env on the job or step.

**Simulator "iPhone 16" not found.**
The current `macos-latest` image has no iPhone 16. Use iPhone 17; the workflows fall back to the first available
iPhone and say which one they used.

**Snapshot tests fail on the first run.**
By design: `record: .missing` records missing images and fails. Run the tests a second time. To re-record, delete the
stale PNGs first.

**Pushed screens have no navigation bar in the light snapshots.**
Fix: host each screen in a key `UIWindow` and snapshot with `drawHierarchyInKeyWindow: true` (see
`ios/AppTests/ScreenshotTests.swift`).

**All iOS snapshots stop matching, with no code change.**
The runner image changed iOS or Xcode. Re-record all images in one Mac run and note the new image in `ios/README.md`.

**Search snapshots flake on the clear (×) button.**
The search bar's clear button appears a moment after layout. The two search tests use `precision: 0.99`; a
deterministic fix (fixed clear-button state in the test) is still open.

**Mac Claude run did its work but is marked failed: "exceeding the configured maximum of N turns".**
The action fails any run over `--max-turns`. The limit is now 120 turns and 60 minutes; a full build, record and review
took 85 turns and 39–55 minutes.

**An `@claude` comment does nothing.**
Check: the PR has the `ios` label; the commenter is an owner, member or collaborator; `CLAUDE_CODE_OAUTH_TOKEN` is
set; the Claude GitHub app is installed on the repo. Changes to `ios-claude.yml` only apply after they are merged to
`main` (comment triggers run from the default branch).

## iOS walk-through (Maestro on the simulator)

**Every flow fails with `DeviceUnreachableException: Device became unreachable during setPermissions`
(connection refused to 127.0.0.1).**
Maestro's XCTest driver was still starting on a cold CI simulator, and by default every `maestro` command reinstalls
the driver and removes it on exit. Fix (in `ios-walkthrough.yml`): `MAESTRO_DRIVER_STARTUP_TIMEOUT=240000`, a warm-up
step (`maestro --device $UDID hierarchy --no-reinstall-driver`, up to 3 tries), and `--no-reinstall-driver` on the
test run.

**iOS back navigation in a flow doesn't work with `back`.**
iOS has no system back. Tap the back button, which carries the previous screen's title (e.g. "Planets", then
"Back"), inside a `runFlow: when: platform: iOS` block.

**The video is empty or won't play.**
`simctl io recordVideo` must be stopped with SIGINT (`kill -INT`) so it can finish writing the MP4.

**Appetize created a second app instead of updating the first.**
`APPETIZE_PUBLIC_KEY` was not set when that run started (variables are read at the start). Set the variable, then
delete the extra app in the Appetize dashboard.

## GitHub and CI

**A PR is stuck "Expected — Waiting for status to be reported".**
A required check never ran because its workflow was path-filtered. Fix: the workflow runs on every PR and a `changes`
job skips the real jobs; a skipped required check counts as passed. Also check that the job's `name:` still matches
the ruleset.

**A generated YAML step breaks after a script rewrote it.**
A `printf '%s\\n'` inside a heredoc became a real newline. Prefer `grep -qE '…' <<< "$FILES"` and validate the YAML
before pushing.

**Line-ending noise on Windows (`LF will be replaced by CRLF`).**
`.gitattributes` forces LF (`* text=auto eol=lf`), keeps PNGs and jars binary, and `.bat` files CRLF.

**Auto-fix can't be turned on for a PR from a local session.**
The local session folder wasn't matched to the repo. Turn it on from the PR bar in the Claude app, or from a cloud
session on the repo.
