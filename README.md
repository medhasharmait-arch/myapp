# myapp

A native mobile app (**Kotlin + Jetpack Compose** on Android, **Swift + SwiftUI** on iOS), built with an almost
zero-cost, fully cloud workflow. Agents work on Linux cloud VMs, borrowed macOS minutes cover the SwiftUI and simulator
work, and every UI change is reviewed as a committed screenshot diff.

Agents: read [AGENTS.md](AGENTS.md). Features are specified in [specs/](specs/).

## Setup progress

- [x] 1. GitHub repo (public: unlimited Actions minutes, macOS included); `main` takes PRs only and requires CI
- [x] 2. Claude Code cloud environment `native-mobile` ([scripts/cloud-setup.sh](scripts/cloud-setup.sh)) + monorepo scaffold
- [x] 3. Claude on a Mac: `CLAUDE_CODE_OAUTH_TOKEN` secret + [ios-claude.yml](.github/workflows/ios-claude.yml)
- [x] 4. CI: [android.yml](.github/workflows/android.yml) (unit + Roborazzi + APK + Maestro on an emulator),
      [ios-core.yml](.github/workflows/ios-core.yml) (`swift test` on Linux),
      [ios-walkthrough.yml](.github/workflows/ios-walkthrough.yml) (Maestro video on the iOS simulator + Appetize)
- [ ] 5. Codex code review linked to the repo
- [ ] 6. Android builds on your phone: Firebase App Distribution on merge to `main`
- [ ] 7. Phone apps: GitHub, Claude, ChatGPT, Firebase App Tester

Codemagic is skipped for now: the repo is public, so GitHub's macOS runners are free and unlimited.

## Workflows at a glance

| Workflow | Runs | Required to merge |
| --- | --- | --- |
| `android` | every PR (jobs skip unless `android/` or `.maestro/` changed); pushes to `main` | `android-build`, `android-e2e` |
| `ios-core` | every PR (job skips unless `ios/Packages/` changed); pushes to `main` | `ios-core-test` |
| `ios-walkthrough` | PRs with the `walkthrough` label; pushes to `main` touching `ios/` or `.maestro/`; manual | no |
| `ios-claude` | `@claude` comment on a PR with the `ios` label | no |

- **iOS video:** the PR comment links it; the latest `main` run is
  [main-walkthrough.mp4](https://github.com/medhasharmait-arch/myapp/releases/download/walkthroughs/main-walkthrough.mp4).
- **Tap through iOS:** [Appetize](https://appetize.io/app/xl2c3ojeyoga4dy46hbhlhwymm), updated by every walk-through run
  (3-minute sessions, 30 free minutes a month).
