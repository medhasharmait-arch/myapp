# __APP_NAME__

A native mobile app (**Kotlin + Jetpack Compose** on Android, **Swift + SwiftUI** on iOS), built with an almost
zero-cost, fully cloud workflow. Agents work on Linux cloud VMs, borrowed macOS minutes cover the SwiftUI and simulator
work, and every UI change is reviewed as a committed screenshot diff.

**New here (person or AI agent)?** Read [AGENTS.md](AGENTS.md), then [docs/](docs/README.md): how it works, a playbook with
ready prompts, decisions, troubleshooting, setup and history. Features are specified in [specs/](specs/) (start from
[specs/_TEMPLATE.md](specs/_TEMPLATE.md)). Parked work is in [LATER.md](LATER.md).

## Setup progress

- [x] 1. GitHub repo (public: unlimited Actions minutes, macOS included); `main` takes PRs only and requires CI
- [x] 2. Claude Code cloud environment ([scripts/cloud-setup.sh](scripts/cloud-setup.sh)) + this scaffold
- [ ] 3. Claude on a Mac: `CLAUDE_CODE_OAUTH_TOKEN` secret + [ios-claude.yml](.github/workflows/ios-claude.yml)
- [x] 4. CI: [android.yml](.github/workflows/android.yml) (unit + Roborazzi + APK + Maestro on an emulator),
      [ios-core.yml](.github/workflows/ios-core.yml) (`swift test` on Linux),
      [ios-walkthrough.yml](.github/workflows/ios-walkthrough.yml) (Maestro video on the iOS simulator + Appetize)
- [ ] 5. Optional: Appetize (`APPETIZE_API_TOKEN` secret, then the `APPETIZE_PUBLIC_KEY` variable)
- [ ] 6. Later: see [LATER.md](LATER.md) (Firebase App Distribution, Codex review, phone apps, store releases)

## Workflows at a glance

| Workflow | Runs | Required to merge |
| --- | --- | --- |
| `android` | every PR (jobs skip unless `android/` or `.maestro/` changed); pushes to `main` | `android-build`, `android-e2e` |
| `ios-core` | every PR (job skips unless `ios/Packages/` changed); pushes to `main` | `ios-core-test` |
| `ios-walkthrough` | PRs with the `walkthrough` label; pushes to `main` touching `ios/` or `.maestro/`; manual | no |
| `ios-claude` | `@claude` comment on a PR with the `ios` label | no |

- **iOS video:** the PR comment links it; the latest `main` run is
  [main-walkthrough.mp4](https://github.com/__REPO__/releases/download/walkthroughs/main-walkthrough.mp4)
  (after the first walk-through on `main`).
- **Tap through iOS:** the Appetize link is in each walk-through PR comment (3-minute sessions, 30 free minutes a month).

## How a feature gets built

1. Write `specs/<feature>.md` from the template (on your phone is fine) and merge it.
2. Start a Claude Code cloud session on this repo: "Build `specs/<feature>.md` for Android, then for iOS core. Open a
   PR for each."
3. The Android PR runs unit tests, the screenshot check, the APK build and the Maestro flows on an emulator.
4. On the iOS PR, add the `ios` label and comment `@claude build, run on the simulator, compare with the spec, fix and
   record snapshots`. Add the `walkthrough` label to get a video of every Maestro flow on an iPhone simulator.
5. Look at the screenshot diffs and the video, tick the spec's acceptance checks in the PR, merge.
