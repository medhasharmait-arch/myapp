# AGENTS.md: shared rules for Claude and Codex

This is a native mobile monorepo: **Android in Kotlin + Jetpack Compose** and **iOS in Swift + SwiftUI**.
Most work happens on Linux cloud VMs. Only SwiftUI builds and the iOS simulator need macOS.

## Layout

```text
AGENTS.md                     # this file
CLAUDE.md                     # imports this file
LATER.md                      # parked work: what it gives, what you do, what an agent does
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
| iOS build + tests + snapshots | `xcodebuild test -project ios/MyApp.xcodeproj -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17'` | macOS |

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

## This repo only

This section is not copied into new projects. `template/` is the skeleton that new projects are made from
([template/README.md](template/README.md)). `template/files/` mirrors this repo with the names replaced by tokens
(`__APP_NAME__`, `__APP_ID__`, `__APP_PATH__`, `__IOS_BUNDLE_ID__`, `__REPO__`).

- When you change a workflow (other than `template.yml`), `scripts/`, `.gitattributes`, `.gitignore`, `CLAUDE.md`
  or this file above this section, make the same change in `template/files/` in the same PR. The `template` workflow
  fails when they drift apart.
- New features of this app stay out of the template. It keeps the starter app as it was when the template was made
  (Hello, the planets list and search), so every new project starts with a working, tested example of each piece.
