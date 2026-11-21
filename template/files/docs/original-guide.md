# Original guide

> The plan this workflow started from, kept as written (Nov 18, 2026). Where the repo differs, the other docs win:
> see [decisions.md](decisions.md) (for example: Codemagic was skipped because GitHub's macOS runners are free on a public
> repo, Android Maestro flows run on every Android PR instead of nightly, and Swift is installed from the official
> tarball instead of swiftly). One line of the original, an embedded diagram, could not be kept; see
> [how-it-works.md](how-it-works.md) for the diagram.

---

**Zero-Cost Cloud Native Mobile Workflow (Swift/SwiftUI + Kotlin)**

Nov 18, 2026 · @PipeXiner

## Summary

Split the work by what each machine can do. Linux cloud VMs (Claude Code and Codex) handle all Kotlin work and all non-UI Swift. Borrowed macOS minutes handle SwiftUI builds and the iOS simulator. Your phone is where you steer and review.

The key ideas that replace the Expo shortcuts:

- **Claude on a real Mac, on demand.** The Claude Code GitHub Action runs on a GitHub macOS runner with Xcode. Mention `@claude` on an issue or PR and it builds, boots the simulator, screenshots, fixes and commits, all on your Pro plan.
- **Screenshots the agent can see without an emulator.** Android Compose screens render to PNG on the JVM (Roborazzi or Paparazzi). iOS screens render in snapshot tests on the macOS runner. The images are committed to the repo, so GitHub's image diff becomes your design review screen on your phone.
- **A Swift core that compiles on Linux.** Business logic, models and networking live in a Swift package that the Linux agents can build and test with `swift test`. Only the SwiftUI layer needs a Mac.
- **No AWS on the critical path.** GitHub's Linux runners run hardware-accelerated Android emulators, so the EC2 + ReDroid box becomes optional.

**Cost:** $0 to build and test on simulators, emulators and your own Android phone. Money is only needed at three points: installing on a real iPhone or using TestFlight (Apple Developer Program, $99/year), publishing on Google Play ($25 once), or going past the free macOS minutes on a private repo.

## Stack

Every row is free at the quota shown. The last two rows are the only ones that cost money, and both are optional at the start.

| Layer | Tool | Free quota | Role |
| --- | --- | --- | --- |
| Source of truth | GitHub | Unlimited repos. Actions: unlimited on public repos; 2,000 Linux minutes/month on private, macOS counts 10x | Code, PRs, CI, image diffs for UI review |
| Agent on Linux | Claude Code cloud sessions (claude.ai/code, Code tab in the Claude app) | Included in Pro. VM: 4 vCPU, 16 GB RAM, 30 GB disk, Ubuntu x86\_64 | Kotlin + Android builds, JVM screenshots, Swift core, PRs, Auto-fix |
| Agent on macOS | Claude Code GitHub Action on a `macos` runner | Uses your Claude plan + GitHub macOS minutes | SwiftUI builds, simulator screenshots, iOS UI fixes |
| Second agent | Codex Cloud (ChatGPT Plus) | Plus VM: 2 vCPU, 8 GiB RAM, 8 GiB disk | PR reviews with `@codex review`, Swift core tasks |
| iOS CI | Codemagic personal account | 500 macOS M2 minutes/month | Build, unit + snapshot tests, simulator `.app` |
| Android CI | GitHub Actions `ubuntu-latest` + android-emulator-runner | Linux minutes (1x) | Instrumented tests and Maestro flows on a KVM emulator |
| UI flows | Maestro CLI (open source) | Free | YAML end-to-end flows with screenshots, same tool on both platforms |
| Hands-on iOS check | Appetize | 30 min/month, 3-minute sessions | Tap through a simulator build in the browser |
| Real Android device | Your phone + Firebase App Distribution | Free | Install every build from a link |
| Later, paid | Apple Developer Program | $99/year, includes 25 Xcode Cloud hours/month | Real iPhone, TestFlight, App Store |
| Optional | AWS EC2 Graviton + ReDroid | Free-plan credits; account closes after 6 months | An Android screen you can touch in the browser |

## How it fits together

Claude works in three ways: a cloud session on Linux for most of the code, a GitHub Action on a macOS runner for anything that needs Xcode, and Auto-fix on open PRs.

*(Embedded diagram: 3 agents, 1 repo, 2 CI lanes, 3 ways to test. See how-it-works.md.)*

You review every UI change as a committed screenshot diff in the GitHub app. Only the Mac box and Codemagic spend macOS minutes.

## Repository layout for agents

Use one monorepo, so every agent sees both apps and the same feature spec. The layout puts as much work as possible where the Linux agents can build and test it.

```text
myapp/
├── AGENTS.md                 # shared rules for Claude and Codex
├── CLAUDE.md                 # one line: @AGENTS.md
├── specs/                    # one Markdown spec per feature, written once
├── api/openapi.yaml          # shared API contract, clients generated for both apps
├── android/                  # Gradle, Kotlin, Jetpack Compose
│   └── app/src/test/snapshots/      # committed Roborazzi screenshots
├── ios/
│   ├── project.yml           # XcodeGen; the .xcodeproj is generated, never committed
│   ├── Packages/AppCore/     # Swift package: models, networking, logic (builds on Linux)
│   ├── App/                  # SwiftUI views only
│   └── AppTests/__Snapshots__/      # committed snapshot-test images
├── .maestro/                 # UI flows, same screen names on both apps
└── .github/workflows/
```

Rules that make this work:

- **Never let an agent edit the `.pbxproj`.** Linux agents can't open Xcode, and a hand-edited project file breaks easily. They add a file and edit `project.yml`; the macOS job runs XcodeGen (or Tuist) before building.
- **Keep `AppCore` free of Apple-only frameworks.** Use Foundation only, no UIKit, SwiftUI or Combine, so `swift test` runs on Linux. On Linux, `URLSession` lives in `FoundationNetworking`, so guard that import with `#if canImport(FoundationNetworking)`.
- **Commit the screenshot images.** A UI change then shows up in the PR as a before/after image diff you can swipe through in the GitHub app.
- **One spec, two PRs.** Each feature starts as `specs/<feature>.md` with screens, states and acceptance checks. The Android PR and the iOS PR both link to it.

`AGENTS.md` should state:

1. The build and test commands for each platform, for example `./gradlew :app:testDebugUnitTest :app:verifyRoborazziDebug` and `swift test --package-path ios/Packages/AppCore`.
2. "Never edit `.xcodeproj` or `.pbxproj`; edit `ios/project.yml`."
3. "Every UI change updates its screenshot images in the same PR."
4. How to ask for a Mac run: comment `@claude` on the PR with the `ios` label.
5. When a task counts as done: tests green, screenshots updated, spec checklist ticked.

## Setup, step by step

All of this can be done from a browser or your phone. Claude does the scaffolding in step 2, so you never need Android Studio or Xcode.

1. **Create the GitHub repo.** Choose public or private first (see Decisions); it sets your macOS budget. Protect `main`: changes only through PRs, and CI must pass before merging.
2. **Set up the Claude Code cloud environment.**
   1. At claude.ai/code, connect GitHub and install the Claude GitHub App on the repo. This also turns on Auto-fix.
   2. Create an environment called `native-mobile` with **Custom** network access, keeping the default list. If a build can't download something, add `dl.google.com`, `maven.google.com`, `services.gradle.org`, `plugins.gradle.org` and `download.swift.org`.
   3. Write a setup script that installs a JDK, the Android command-line tools (platform, build-tools and platform-tools for your target API level) and a Swift toolchain via `swiftly`. Keep it under about 5 minutes, which is the limit for the environment to be cached.
   4. First task for Claude: "Scaffold the monorepo in AGENTS.md's layout: Compose app with Roborazzi, `AppCore` Swift package with tests, XcodeGen `project.yml` for a SwiftUI app, and the CI workflows in step 4."
3. **Give Claude a Mac through GitHub Actions.**
   1. Run `claude setup-token` once from any terminal; a GitHub Codespace in your browser works. Save the token as the repo secret `CLAUDE_CODE_OAUTH_TOKEN`.
   2. Add `.github/workflows/claude-ios.yml`: `runs-on: macos-latest`, triggered by an `@claude` comment on an issue or PR with the `ios` label. Steps: checkout, `brew install xcodegen`, generate the project, then `anthropics/claude-code-action@v1`.
   3. In the action's prompt, tell Claude to: build with `xcodebuild`, boot a simulator, run the app, take screenshots with `xcrun simctl io booted screenshot`, look at them, fix, re-record snapshot images and push.
   4. Cap every run with `timeout-minutes: 30` and a max-turns limit; macOS minutes are the scarcest resource.
   5. Optional twin, `claude-android.yml`: the same action on `ubuntu-latest` with a KVM emulator, so Claude can use `adb` to install, tap and screenshot.
4. **Add the CI pipelines.**
   - `android.yml` (Linux, every PR touching `android/`): unit tests, Roborazzi screenshot check, `assembleDebug`, APK uploaded as an artifact. On merge to `main`: push the APK to Firebase App Distribution.
   - `android-e2e.yml` (Linux, nightly or `e2e` label): KVM emulator + Maestro flows, screenshots attached.
   - `ios-core.yml` (Linux, every PR touching `ios/Packages/`): `swift test`. Cheap, so run it every time.
   - `codemagic.yaml` (Codemagic macOS, PRs to `main` touching `ios/`): XcodeGen, build, unit + snapshot tests, simulator `.app` artifact, optional upload to Appetize.
5. **Connect Codex.** Link the same repo in Codex and turn on code review, so every PR gets a second opinion. Give its environment Swift for `AppCore` tasks; its 8 GiB disk is too small for Android work.
6. **Set up your phone.** Install the GitHub app (reviews and image diffs), the Claude app (Code tab), ChatGPT (Codex) and Firebase App Tester (Android builds). If you have an Android phone, it's your best free emulator.

## Daily loop for one feature

Do the thinking on free Linux time and spend Mac minutes only on compiling, looking and fixing. You steer everything from the Claude app and review in the GitHub app.

1. **Spec.** Ask Claude to write `specs/<feature>.md` with screens, states, API calls and acceptance checks. Edit it until it's right; both apps build from it.
2. **Android, all on Linux.** In a cloud session: "Implement `specs/<feature>.md` on Android." Claude writes Kotlin, runs the unit tests, records Roborazzi screenshots, looks at the images itself, fixes the layout and opens a PR.
3. **Review Android on your phone.** Swipe through the screenshot diffs in the GitHub app, then install the build from Firebase App Tester. Leave review comments; Auto-fix answers them.
4. **iOS logic, on Linux.** In a second cloud session (or Codex): implement the `AppCore` part of the spec with `swift test` passing, then open a PR.
5. **iOS UI: draft on Linux, verify on the Mac.** Claude writes the SwiftUI views in the cloud session, where they can't compile. Then comment on the PR with the `ios` label: "@claude build, run on the simulator, compare with the spec, fix and record snapshots." One short Mac run turns the draft into working, screenshotted UI.
6. **Review iOS.** Codemagic runs the full test suite. You check the snapshot diffs in the GitHub app; for interaction, open the build in Appetize for a 3-minute tap-through.
7. **Second opinion and merge.** Codex reviews both PRs. Merge when CI is green and the spec checklist is ticked.

Off the daily path: Android Maestro flows run nightly on the KVM emulator. iOS Maestro flows run only at milestones, because they use Mac minutes.

## Budget and guardrails

macOS time is the bottleneck. On a private repo, a 20-minute Mac run uses 200 of GitHub's 2,000 included minutes, because macOS counts 10x. A public repo removes that limit.

| Free pool (per month) | Spent by | Rule of thumb |
| --- | --- | --- |
| GitHub Actions, private: 2,000 Linux minutes (= 200 macOS) | Linux CI, KVM emulator runs, Claude Mac runs | Keep it for Claude Mac runs and Android CI; never build iOS on every push |
| GitHub Actions, public | Same | Unlimited on standard runners |
| Codemagic: 500 macOS M2 minutes | iOS build + test pipeline | Run on PRs to `main` touching `ios/`, not on every push |
| Claude Pro usage limits | Cloud sessions, Auto-fix, the GitHub Action | Long or parallel sessions drain it fastest; Auto-fix on chosen PRs only |
| Codex Plus limits | Reviews, `AppCore` tasks | Mostly reviews, which are cheap |
| Appetize: 30 minutes, 3-minute sessions | Hands-on iOS checks | Milestones only |

Guardrails to put in every workflow:

- **Trigger Mac jobs by label or comment only**, with path filters so a Kotlin-only PR never starts a Mac.
- **Set `timeout-minutes` on every job**, and a `concurrency` group so a new push cancels the older run.
- **Cache Gradle and Swift package builds.** Set `retention-days: 3` on APK and `.app` artifacts, since private repos get only 500 MB of artifact storage free.
- **Keep the Claude Action's default permission check**, so only people with write access can trigger it. This matters most on a public repo.
- **Keep signing keys in GitHub or Codemagic secrets**, never in the Claude cloud environment's variables, which anyone using the environment can read.
- **Check how Claude GitHub Action usage is billed.** Anthropic announced and then withdrew a separate credit pool for it in 2026, so read the current [Agent SDK help article](https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan) before relying on heavy Action use.

## Decisions to make

1. **Public or private repo.** Public gets unlimited GitHub Actions minutes on standard runners, macOS included, so Claude can use the Mac as often as your Claude plan allows. The cost: anyone can read your code. Go private for a commercial product, public for open-source or learning projects.
2. **When to pay for the Apple Developer Program ($99/year).** You need it for a real iPhone, TestFlight and the App Store. It also includes 25 Xcode Cloud hours a month, which can take over iOS CI from Codemagic. Buy it once the first iOS feature works in the simulator.
3. **Kotlin Multiplatform for shared logic (optional).** Instead of writing logic twice (Kotlin and `AppCore` Swift), write it once in Kotlin and keep both UIs native (SwiftUI and Compose). It roughly halves the logic work, and the Linux agents can build all of it. The costs are friction calling Kotlin from Swift and more to learn. Stay with two native codebases if you want pure Swift.
4. **The EC2 Android box (optional).** Only add it if you want an Android screen you can touch in a browser and don't have an Android phone. On the AWS Free plan the account closes after 6 months or when the credits run out, so script the setup and treat the instance as disposable.

## Sources

- [Claude Code cloud environments](https://code.claude.com/docs/en/cloud-environments): VM size, network levels, setup-script caching
- [Claude Code in the cloud](https://code.claude.com/docs/en/claude-code-on-the-web): Auto-fix, usage limits
- [Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions): `CLAUDE_CODE_OAUTH_TOKEN` on Pro
- [About billing for GitHub Actions](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions): free public repos, 10x macOS multiplier
- [GitHub: hardware-accelerated Android on 2-vCPU Linux runners](https://github.blog/changelog/2024-04-02-github-actions-hardware-accelerated-android-virtualization-now-available/) and [android-emulator-runner](https://github.com/ReactiveCircus/android-emulator-runner)
- [Codemagic pricing](https://docs.codemagic.io/billing/pricing/): 500 free macOS M2 minutes
- [Xcode Cloud](https://developer.apple.com/xcode-cloud/get-started): 25 hours with Developer Program membership
- [Codex cloud environments](https://developers.openai.com/codex/cloud/environments) and [Codex VM sizes by plan](https://capitalandcompute.net/blog/how-codex-cloud-environments-work/)
- [Appetize pricing](https://moquality.appetize.io/pricing): 30 free minutes, 3-minute sessions
- [AWS Free Tier plans](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-plans.html): 6-month account closure
