# iOS

SwiftUI app `__APP_NAME__` (iOS 17+, bundle id `__IOS_BUNDLE_ID__`). Read the repo's `AGENTS.md` first.

| Folder | What | Builds on |
| --- | --- | --- |
| `Packages/AppCore/` | Models and logic, Foundation only | Linux or macOS |
| `App/` | SwiftUI views (`HomeScreen`, `ListScreen`, `DetailScreen`, `AppRoot`) | macOS |
| `AppTests/` | Snapshot tests (swift-snapshot-testing) | macOS |
| `AppTests/__Snapshots__/` | Committed reference images | |
| `project.yml` | XcodeGen spec; the `.xcodeproj` is generated, never committed | |

## Commands

Run these from the repository root.

```bash
swift test --package-path ios/Packages/AppCore
```

```bash
xcodegen generate --spec ios/project.yml
```

```bash
xcodebuild test -project ios/__APP_NAME__.xcodeproj -scheme __APP_NAME__ -destination 'platform=iOS Simulator,name=iPhone 17'
```

If the runner image has no iPhone 17, pick another iPhone from `xcrun simctl list devices available`.

## Snapshots

`AppTests/ScreenshotTests.swift` has one test per state in the spec's States table. Each test records a light image and a dark image:
`__Snapshots__/ScreenshotTests/<test>.<light|dark>.png`.

- **Recording.** The tests run with `record: .missing`. A test without a reference image records one and fails on purpose. Run the tests a second time; that run should pass.
- **Re-recording after a UI change.** Delete the stale PNGs and run the tests twice.
- **Before committing.** Look at every image and compare it with the spec.

Snapshots render differently across iOS versions, so record and verify on the same runner image: the Mac workflow, `.github/workflows/ios-claude.yml`. The current images were recorded there on iPhone 17 with iOS 26 (Xcode 26.6).

## Mac runs

Linux sessions can't build the app. To get a Mac build, add the `ios` label to the PR and comment `@claude <what to do>` (`AGENTS.md` rule 5).
