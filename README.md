# myapp

A native mobile app (**Kotlin + Jetpack Compose** on Android, **Swift + SwiftUI** on iOS), built with an almost
zero-cost, fully cloud workflow. Agents work on Linux cloud VMs, borrowed macOS minutes cover the SwiftUI and simulator
work, and every UI change is reviewed as a committed screenshot diff.

Agents: read [AGENTS.md](AGENTS.md). Features are specified in [specs/](specs/) (start from
[specs/_TEMPLATE.md](specs/_TEMPLATE.md)). Parked work is in [LATER.md](LATER.md).

**Starting another app?** [template/](template/README.md) has this whole workflow and the starter app, ready to copy
into a new repo.

## Setup progress

- [x] 1. GitHub repo (public: unlimited Actions minutes, macOS included); `main` takes PRs only and requires CI
- [x] 2. Claude Code cloud environment `native-mobile` ([scripts/cloud-setup.sh](scripts/cloud-setup.sh)) + monorepo scaffold
- [x] 3. Claude on a Mac: `CLAUDE_CODE_OAUTH_TOKEN` secret + [ios-claude.yml](.github/workflows/ios-claude.yml)
- [x] 4. CI: [android.yml](.github/workflows/android.yml) (unit + Roborazzi + APK + Maestro on an emulator),
      [ios-core.yml](.github/workflows/ios-core.yml) (`swift test` on Linux),
      [ios-walkthrough.yml](.github/workflows/ios-walkthrough.yml) (Maestro video on the iOS simulator + Appetize)
- [x] 5. [template/](template/README.md) for new projects, checked by [template.yml](.github/workflows/template.yml)
- [ ] Later, in [LATER.md](LATER.md): Firebase App Distribution, Codex code review, phone apps, store releases

Codemagic is skipped for now: the repo is public, so GitHub's macOS runners are free and unlimited.

## Workflows at a glance

| Workflow | Runs | Required to merge |
| --- | --- | --- |
| `android` | every PR (jobs skip unless `android/` or `.maestro/` changed); pushes to `main` | `android-build`, `android-e2e` |
| `ios-core` | every PR (job skips unless `ios/Packages/` changed); pushes to `main` | `ios-core-test` |
| `ios-walkthrough` | PRs with the `walkthrough` label; pushes to `main` touching `ios/` or `.maestro/`; manual | no |
| `ios-claude` | `@claude` comment on a PR with the `ios` label | no |
| `template` | PRs touching `template/`, workflows, `scripts/` or the agent rules (drift check; sample builds when `template/` changed) | no |

- **iOS video:** the PR comment links it; the latest `main` run is
  [main-walkthrough.mp4](https://github.com/medhasharmait-arch/myapp/releases/download/walkthroughs/main-walkthrough.mp4).
- **Tap through iOS:** [Appetize](https://appetize.io/app/xl2c3ojeyoga4dy46hbhlhwymm), updated by every walk-through run
  (3-minute sessions, 30 free minutes a month).
