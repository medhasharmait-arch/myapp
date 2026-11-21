# Decisions

Choices that shape this repo, why they were made, and what would make them worth revisiting. Don't undo one by
accident: change it here first, in the same PR as the change.

| # | Decision | Why | Revisit when |
| --- | --- | --- | --- |
| 1 | **Public GitHub repo** | GitHub Actions minutes are unlimited on public repos, macOS included, so CI and Mac runs cost nothing | the code must be private: then macOS minutes count 10x against 2,000 a month, so see Codemagic in `LATER.md` |
| 2 | **Two native codebases, no Kotlin Multiplatform** | pure Swift + SwiftUI and pure Kotlin + Compose; less to learn, no Kotlin-from-Swift friction | the shared logic grows large enough that writing it twice hurts |
| 3 | **One monorepo** | every agent sees both apps and the same spec | never, so far |
| 4 | **Specs first, one spec → two PRs** | both apps build from the same exact texts, states and examples; agents have an unambiguous target | never, so far |
| 5 | **XcodeGen `project.yml`; the `.xcodeproj` is never committed** | Linux agents can't open Xcode, and hand-edited `.pbxproj` files break | moving to Tuist or Swift Package-only apps |
| 6 | **`AppCore` is Foundation-only** | `swift test` runs on Linux, in cloud sessions and cheap CI, so only SwiftUI needs a Mac | never, so far |
| 7 | **Committed screenshot images** (Roborazzi; swift-snapshot-testing) | UI review becomes an image diff on the phone; agents look at the PNGs themselves | never, so far |
| 8 | **Claude on a Mac through the Claude Code GitHub Action** (`ios-claude.yml`) | a real Mac with Xcode on demand, on the Claude plan and free public-repo minutes | the Action's billing changes (check Anthropic's Agent SDK help article) |
| 9 | **Codemagic skipped** | the original plan used it for iOS CI, but GitHub's macOS runners are free on a public repo and simpler | the repo goes private (`LATER.md`) |
| 10 | **Maestro for end-to-end flows on both platforms; Android flows on every Android PR** | one YAML flow per spec covers both apps; the plan said nightly, but on a public repo every PR is free and catches more | Android CI time becomes a problem |
| 11 | **iOS walk-through by label, video in a GitHub release, plus Appetize** | a video you can watch on the phone without spending Appetize minutes; Appetize for hands-on checks | Appetize's free tier changes |
| 12 | **Required checks that always report** (`changes` job + skipped jobs) | path-filtered workflows never report on unrelated PRs, which would block them forever | GitHub adds native "required if run" checks |
| 13 | **Nothing heavy on the owner's computer** | the owner's PC is low-spec; all builds and tests run in cloud sessions and Actions | never: keep it that way |
| 14 | **compileSdk 36, AndroidX versions held at the newest that support it** | the spec fixed SDK 36; the newest AndroidX needs 37 | moving to SDK 37: bump everything in one PR (`playbook.md`) |
| 15 | **JDK 17 builds, JDK 21 runs unit tests** | Robolectric can't sandbox SDK 35+ on Java 17 | AGP or Robolectric requirements change |
| 16 | **Swift from the official tarball, not swiftly**, in the cloud environment | swiftly fails to import swift.org's gzip-served keys (see `troubleshooting.md`) | swiftly fixes it |
| 17 | **iPhone 17 / `macos-latest` image is the snapshot reference** | snapshots differ between iOS versions; record and verify on the same image | the runner image changes iOS: re-record all iOS snapshots in one Mac run |
| 18 | **Secrets only in GitHub secrets** | the cloud environment's variables are visible to anyone using the environment | never |
| 19 | **Pinned versions, downloaded artifacts instead of `curl \| bash`** (e.g. the Maestro zip) | reproducible runs; nothing changes under you | when updating, on purpose, in one PR |
| 20 | **Firebase App Distribution, Codex review and store releases are parked** | not needed to prove the loop; listed with steps in `LATER.md` | when you want builds on your Android phone or a second reviewer |
