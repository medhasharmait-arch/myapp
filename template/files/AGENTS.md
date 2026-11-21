# AGENTS.md: shared rules for Claude and Codex

This is a native mobile monorepo: **Android in Kotlin + Jetpack Compose** and **iOS in Swift + SwiftUI**.
Most work happens on Linux cloud VMs. Only SwiftUI builds and the iOS simulator need macOS.

## Start here

You start with no memory of earlier sessions; the repo is the memory. Read [docs/README.md](docs/README.md) for the
reading order. Before debugging, search [docs/troubleshooting.md](docs/troubleshooting.md) for the error. Before changing
how something works, check [docs/decisions.md](docs/decisions.md). Recipes and ready prompts are in
[docs/playbook.md](docs/playbook.md).

## Layout

```text
AGENTS.md                     # this file
CLAUDE.md                     # imports this file
LATER.md                      # parked work: what it gives, what you do, what an agent does
docs/                         # how it works, playbook, decisions, troubleshooting, setup, history
specs/                        # one Markdown spec per feature; both apps build from it
api/openapi.yaml              # shared API contract (added when the app gets a backend)
android/                      # Gradle, Kotlin, Jetpack Compose
  app/src/test/snapshots/     # committed Roborazzi screenshots
ios/
  project.yml                 # XcodeGen; the .xcodeproj is generated, never committed
  Packages/AppCore/           # Swift package: models, networking, logic (builds on Linux)
  App/                        # SwiftUI views only
  AppTests/__Snapshots__/     # committed snapshot-test images
.maestro/                     # UI flows, same screen names on both apps
.github/workflows/            # CI
scripts/                      # helper scripts (cloud environment setup, etc.)
```

## Build and test commands

| What | Command | Runs on |
| --- | --- | --- |
| Android unit tests + screenshot check | `cd android && ./gradlew :app:testDebugUnitTest :app:verifyRoborazziDebug` | Linux |
| Re-record Android screenshots | `cd android && ./gradlew :app:recordRoborazziDebug` | Linux |
| Android debug APK | `cd android && ./gradlew :app:assembleDebug` | Linux |
| iOS core logic tests | `swift test --package-path ios/Packages/AppCore` | Linux or macOS |
| Generate the Xcode project | `cd ios && xcodegen generate` | macOS |
| iOS build + tests + snapshots | `xcodebuild test -project ios/__APP_NAME__.xcodeproj -scheme __APP_NAME__ -destination 'platform=iOS Simulator,name=iPhone 17'` | macOS |

## Rules

1. **Never edit `.xcodeproj` or `.pbxproj`; edit `ios/project.yml`.** The macOS job runs XcodeGen before every build.
2. **Keep `AppCore` free of Apple-only frameworks.** Foundation only: no UIKit, SwiftUI or Combine, so `swift test` runs on Linux.
   On Linux `URLSession` lives in `FoundationNetworking`; guard it with `#if canImport(FoundationNetworking)`.
3. **Every UI change updates its screenshot images in the same PR.** On Android that means Roborazzi; on iOS, the snapshot tests.
   Look at the images you recorded before you call the work done.
4. **One spec, two PRs.** Every feature starts as `specs/<feature>.md`. The Android PR and the iOS PR both link to it.
5. **Asking for a Mac run:** add the `ios` label to the PR and comment `@claude` with what to do
   (e.g. "@claude build, run on the simulator, compare with the spec, fix and record snapshots").
   Mac minutes are scarce, so batch the requests and keep each run short.
   For a recorded iOS walk-through (every `.maestro/` flow on the simulator, as a video), add the `walkthrough` label
   instead; no `@claude` comment is needed. The video link is posted on the PR. Keep flows working on both platforms:
   any new screen needs its Maestro steps for iOS too.
6. **Secrets:** never put signing keys or tokens in code or in the cloud environment's variables. They live in GitHub or Codemagic secrets.

## Definition of done

A task is done when:

- [ ] the tests for the platforms it touches are green,
- [ ] the screenshot images are re-recorded and checked by eye,
- [ ] the spec's acceptance checklist is ticked in the PR description,
- [ ] the PR links to its spec.
- [ ] anything the next agent needs is written down: a new fix in `docs/troubleshooting.md`, a choice in
      `docs/decisions.md`, the milestone in `docs/history.md` ([docs/README.md](docs/README.md) has the table).
