# myapp

A native mobile app (**Kotlin + Jetpack Compose** on Android, **Swift + SwiftUI** on iOS), built with an almost
zero-cost, fully cloud workflow. Agents work on Linux cloud VMs, borrowed macOS minutes cover the SwiftUI and simulator
work, and every UI change is reviewed as a committed screenshot diff.

Agents: read [AGENTS.md](AGENTS.md). Features are specified in [specs/](specs/).

## Setup progress

- [x] 1. GitHub repo (public: unlimited Actions minutes, macOS included), `main` protected
- [ ] 2. Claude Code cloud environment `native-mobile` ([scripts/cloud-setup.sh](scripts/cloud-setup.sh)) + first scaffold task
- [ ] 3. Claude on a Mac: `CLAUDE_CODE_OAUTH_TOKEN` secret + `.github/workflows/claude-ios.yml`
- [ ] 4. CI pipelines: `android.yml`, `android-e2e.yml`, `ios-core.yml`, `codemagic.yaml`
- [ ] 5. Codex code review linked to the repo
- [ ] 6. Phone: GitHub, Claude, ChatGPT, Firebase App Tester apps

## First cloud task (copy into a Claude Code cloud session)

> Read AGENTS.md and specs/starter.md. Scaffold the monorepo in AGENTS.md's layout:
> 1. `android/`: Gradle wrapper (Kotlin DSL, version catalog), a Jetpack Compose app (minSdk 26, target/compile SDK 36,
>    package `com.myapp`) with Roborazzi on Robolectric for JVM screenshot tests.
> 2. `ios/Packages/AppCore/`: Swift package (Foundation only) with `Item` and `ItemRepository` plus XCTest tests.
> 3. `ios/project.yml`: XcodeGen project for a SwiftUI app `MyApp` (iOS 17+) that depends on AppCore, plus an `AppTests`
>    target using swift-snapshot-testing. Draft the SwiftUI views, which can't compile here.
> 4. `.github/workflows/android.yml` and `ios-core.yml` (step 4 of the setup), with path filters, `timeout-minutes`,
>    `concurrency` groups, Gradle/SwiftPM caching and `retention-days: 3` on artifacts.
>
> Implement specs/starter.md on Android, record the Roborazzi screenshots and look at them yourself.
> Make `swift test` pass for AppCore. Open one PR with everything and tick the spec's acceptance checks that apply.
