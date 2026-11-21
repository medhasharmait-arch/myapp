# Playbook

Recipes for everyday tasks, with prompts you can paste. Agents: follow [../AGENTS.md](../AGENTS.md) first; these
recipes add the steps around it.

## Build a new feature (one spec, two PRs)

**1. Spec.** Copy [`specs/_TEMPLATE.md`](../specs/_TEMPLATE.md) to `specs/<feature>.md`. Or ask a cloud session:

> Write `specs/<feature>.md` from `specs/_TEMPLATE.md` for: <what you want, in plain words>. Use exact visible texts,
> a States table and an examples table for the logic. Open a PR with only the spec.

Merge it when it reads right. Both apps are built from it.

**2. Android.** New cloud session on this repo, environment `native-mobile`:

> Implement `specs/<feature>.md` on Android. Follow AGENTS.md. Add unit tests for every example in the spec, record
> the Roborazzi screenshots and look at each image, add or extend the Maestro flow in `.maestro/`, run
> `cd android && ./gradlew :app:testDebugUnitTest :app:verifyRoborazziDebug :app:assembleDebug`, and open a PR that
> links the spec and ticks its Android acceptance checks.

**3. iOS core and drafted UI.** New cloud session (it can run in parallel with step 2):

> Implement `specs/<feature>.md` on iOS. Put the logic in `ios/Packages/AppCore` (Foundation only) with tests, and
> run `swift test --package-path ios/Packages/AppCore`. Draft the SwiftUI views and snapshot tests (they can't compile
> here). Make sure the Maestro flow works on iOS too. Open a PR that links the spec; leave the Mac checks unticked.

**4. Mac run** on the iOS PR: add the `ios` label, then comment:

> @claude build, run on the simulator, compare with the spec, fix and record snapshots

It takes 40–55 minutes and commits to the PR branch. Batch everything into one comment: each run costs a lot of Mac
time.

**5. Walk-through**: add the `walkthrough` label. A comment with the video and the Appetize link appears in about
15 minutes and updates on every push.

**6. Review and merge**: check the image diffs and the video, tick the spec's checklist in the PR description, merge
when the required checks are green. Log the feature in [history.md](history.md).

## Change the UI of an existing screen

- Android: change the code, then `cd android && ./gradlew :app:recordRoborazziDebug`, look at every changed PNG, and
  commit them with the code. CI's `verifyRoborazziDebug` fails if you forget.
- iOS: draft the change, then on the PR (`ios` label): `@claude delete the stale snapshots for <screen>, re-record,
  compare with specs/<feature>.md and fix`.
- Update the spec first if the change is a new requirement.

## Add or change a Maestro flow

- One file per spec in `.maestro/`, `appId: ${APP_ID}`. Match visible text exactly as the spec says.
- Put platform differences in `runFlow: when: platform: Android|iOS` blocks (back navigation especially).
- Android CI runs every flow in the folder. For iOS, add the `walkthrough` label to the PR.

## Change a workflow

- Keep `timeout-minutes`, `concurrency` and `retention-days: 3`.
- Don't rename `android-build`, `android-e2e` or `ios-core-test`: they are required checks (see
  [how-it-works.md](how-it-works.md#required-checks-and-the-changes-job)).
- Comment-triggered workflows (`ios-claude.yml`) run from `main`, so changes to them only take effect after merging.
- Validate the YAML before pushing (for example `actionlint`, or at least a YAML parser).

## Add a dependency

- Android: add it to `android/gradle/libs.versions.toml`. The app compiles against SDK 36; the newest AndroidX
  releases need SDK 37, so pick the newest version that still supports 36, or bump the SDK everywhere
  (`app/build.gradle.kts`, `scripts/cloud-setup.sh`, `android.yml`'s `API_LEVEL`) in one PR.
- iOS app: add the package in `ios/project.yml` (never in an `.xcodeproj`). `AppCore` stays Foundation-only with no
  Apple-only dependencies.

## Update the toolchain

Versions are listed in [how-it-works.md](how-it-works.md#toolchain-pinned-versions) with the file that pins each.
Change the version there and in the pinning file in one PR, then let CI prove it. For the cloud environment, also
re-paste `scripts/cloud-setup.sh` into the environment's setup script at claude.ai/code.

## Fix a red check

1. Open the failed job's log, then check [troubleshooting.md](troubleshooting.md) for the error text.
2. Screenshot failures: download the `test-reports` artifact (Android) for the diff images.
3. Maestro failures: download `maestro-results` (Android) or `ios-walkthrough` (iOS) for screenshots and logs.
4. If it's new, fix it and add the symptom, cause and fix to [troubleshooting.md](troubleshooting.md) in the same PR.

## Write a good PR

- Title says what changes for the user. Body links the spec and ticks its acceptance checks.
- Lists the screenshots added or changed, with one line each on what they show.
- Says what was not run or not checked (for example "Mac checks pending").

## End of every session (agents)

Before you finish, write down what the next agent will need: a new fix in [troubleshooting.md](troubleshooting.md),
a choice in [decisions.md](decisions.md), the milestone in [history.md](history.md), parked work in
[../LATER.md](../LATER.md). See the table in [README.md](README.md#where-to-write-down-what-you-learn).
