# History

What happened when, and the state of things now. Newest milestone last. Add a line when a PR changes something
others need to know.

## Current state (2026-11-21)

- **Built:** the starter app (Home → Planets list → Detail, empty state) and planet search, on Android and iOS, with
  unit tests, screenshots in light and dark, and Maestro flows passing on both platforms.
- **Setup steps from the guide:** repo + protection + required CI, cloud environment, Claude on a Mac, Android and
  iOS CI, the iOS walk-through video and Appetize, and a template for new projects are done. Codex review, Firebase
  App Distribution and the phone apps are parked in [../LATER.md](../LATER.md).
- **Open follow-ups:** the two iOS search snapshots use `precision: 0.99` because the clear button appears late
  ([troubleshooting.md](troubleshooting.md)); the duplicate Appetize app is still to be deleted (`LATER.md`).

## IDs and names this repo uses (no secret values)

| What | Value |
| --- | --- |
| Repo | `medhasharmait-arch/myapp`, public, default branch `main` |
| Android application id / package | `com.myapp` |
| iOS bundle id / Xcode scheme | `com.myapp.ios` / `MyApp` |
| Cloud environment | `native-mobile` (setup script `scripts/cloud-setup.sh`) |
| Ruleset | "Protect main", id 27726811; required checks `android-build`, `android-e2e`, `ios-core-test` (GitHub Actions, integration id 15368) |
| Labels | `ios`, `walkthrough` (an older `e2e` label exists but nothing uses it) |
| Secrets | `CLAUDE_CODE_OAUTH_TOKEN`, `APPETIZE_API_TOKEN` |
| Variables | `APPETIZE_PUBLIC_KEY` = `xl2c3ojeyoga4dy46hbhlhwymm` (<https://appetize.io/app/xl2c3ojeyoga4dy46hbhlhwymm>) |
| Extra Appetize app to delete | `ca4lyoc6lqjrf3l5fij5pjzh3q` |
| Video release | tag `walkthroughs` (pre-release): `main-walkthrough.mp4`, `pr-<N>-walkthrough.mp4` |
| Snapshot reference image | `macos-latest` with Xcode 26.6, iPhone 17, iOS 26 |

## Timeline

| Date | PR | What |
| --- | --- | --- |
| 2026-11-18 | | The plan: [original-guide.md](original-guide.md) |
| 2026-11-20 | — | Repo created (public). The owner chose two native codebases (no KMP), repo name `myapp`, and a simple starter app. Work moved fully to the cloud so the owner's low-spec PC does nothing heavy |
| 2026-11-20 | #1 | Cloud setup script works in non-login shells (Swift tools linked into `/usr/local/bin`) |
| 2026-11-20 | #2 | Scaffold: Android app with Roborazzi, `AppCore` Swift package, XcodeGen project, drafted SwiftUI, `android.yml` and `ios-core.yml`. Setup script fixed (root `$SUDO`, JDK pin, Swift tarball instead of swiftly, JDK 21 for Robolectric) |
| 2026-11-20 | #3 | `ios-claude.yml`: Claude on a Mac runner for `ios`-labelled PRs |
| 2026-11-20 | #4 | iOS starter built on the Mac (first Mac run: 85 turns, 39 min); 8 snapshots; key-window snapshot fix |
| 2026-11-20 | #5 | Mac workflow tuned: 120 turns / 60 min, SwiftPM `safe.bareRepository` workaround, iPhone 17 |
| 2026-11-20 | #6 | Maestro starter flow on an Android emulator in CI (cached AVD) |
| 2026-11-20 | #7 | Android: search the planets list (`specs/search.md`), `.maestro/search.yaml` |
| 2026-11-20 | #8 | iOS: search (`.searchable`), all 12 snapshots re-recorded on the Mac (55 min) |
| 2026-11-21 | #9 | `ios-walkthrough.yml`: Maestro flows on the iOS simulator as a video + Appetize. First run failed with `DeviceUnreachableException`; fixed with a driver warm-up |
| 2026-11-21 | #10 | Required checks always report (`changes` job); ruleset requires `android-build`, `android-e2e`, `ios-core-test` |
| 2026-11-21 | #11 | README setup progress and workflow overview |
| 2026-11-21 | #12 | `template/` for new projects (+ `template.yml` drift and sample builds), `LATER.md`, `specs/_TEMPLATE.md` |
| 2026-11-21 | #13 | `docs/`: how it works, playbook, decisions, troubleshooting, setup, history, the original guide |
