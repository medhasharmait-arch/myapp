# Template: a new native mobile project on the zero-cost cloud workflow

Everything `myapp` runs on, ready to copy into a new repo: agent rules, the docs (how it works, playbook, decisions,
troubleshooting, setup), CI for both platforms, the Mac and iOS
simulator workflows, the cloud environment script, spec templates, and the starter app (Kotlin + Compose and
Swift + SwiftUI) with its tests, screenshots and Maestro flows. A new project starts green on its first PR.

Nothing here runs on your computer. The heavy work (Gradle, Swift, emulators, simulators) happens in Claude Code
cloud sessions and GitHub Actions.

## What's inside

```text
template/
  README.md          # this guide
  new-project.sh     # copies files/ into a new repo and fills in the names
  setup-github.sh    # labels, branch protection with required checks, secrets (needs repo admin)
  files/             # the new project, with names as tokens
    AGENTS.md  CLAUDE.md  README.md  LATER.md  .gitattributes  .gitignore
    docs/              README (reading order)  how-it-works  playbook  decisions  troubleshooting  setup
                       history (a fresh log)  original-guide
    .github/workflows/  android.yml  ios-core.yml  ios-walkthrough.yml  ios-claude.yml
    .maestro/          starter.yaml  search.yaml
    scripts/           cloud-setup.sh
    specs/             _TEMPLATE.md  starter.md  search.md
    android/           Gradle + Compose app, unit tests, Roborazzi screenshots
    ios/               XcodeGen project.yml, AppCore package (Linux-testable), SwiftUI app, snapshot tests
```

| Token | Becomes | Example |
| --- | --- | --- |
| `__APP_NAME__` | Swift/Kotlin type names, Xcode project and scheme, app label | `Notes` |
| `__APP_ID__` | Android `applicationId` and Kotlin package | `com.example.notes` |
| `__APP_PATH__` (folder name) | the Kotlin package folders | `com/example/notes` |
| `__IOS_BUNDLE_ID__` | iOS bundle id | `com.example.notes.ios` |
| `__REPO__` | links in README and LATER | `you/notes` |

## What it costs

| Piece | Cost |
| --- | --- |
| GitHub repo + Actions (Linux, KVM emulator, macOS runners) | free while the repo is **public** |
| Claude Code cloud sessions and the Mac action | your Claude plan |
| Appetize (tap through the iOS build in a browser) | free: 30 minutes a month, 3-minute sessions |
| Firebase App Distribution (Android builds to your phone) | free (see `LATER.md`) |
| Store releases | parked in `LATER.md` ($25 Google Play once, $99 a year Apple) |

## Once per account (already done for `myapp`)

- **Claude GitHub app** installed with access to your repos: <https://github.com/apps/claude>. If you picked "Only
  select repositories", add each new repo there.
- **Cloud environment `native-mobile`** in Claude Code on the web, with
  [`files/scripts/cloud-setup.sh`](files/scripts/cloud-setup.sh) as its setup script (JDK 17, Android SDK 36, Swift).
  Every new repo can reuse it.
- **A Claude token for the Mac action:** `claude setup-token` prints one. Keep it in your password manager; each repo
  gets it as the `CLAUDE_CODE_OAUTH_TOKEN` secret.

## Start a new project

**1. Create the repo** on github.com (the phone app works too): **New repository**, Public, tick
**Add a README file** so `main` exists. Note the name, e.g. `you/notes`.

**2. Set it up.** From any shell with GitHub CLI signed in as the owner (it's a few API calls, nothing heavy), or ask a
local Claude session to run it:

```bash
bash template/setup-github.sh you/notes
```

It creates the `ios` and `walkthrough` labels, protects `main` (PRs only, required checks `android-build`,
`android-e2e`, `ios-core-test`) and asks you for `CLAUDE_CODE_OAUTH_TOKEN` and, optionally, `APPETIZE_API_TOKEN`
in gh's own prompt.

**3. Bootstrap it in a cloud session.** Start a Claude Code cloud session on the new repo, environment
`native-mobile`, with this prompt (change the three names):

> Bootstrap this repo from the mobile workflow template. Run
> `git clone --depth 1 https://github.com/medhasharmait-arch/myapp /tmp/wf` and then
> `bash /tmp/wf/template/new-project.sh --name Notes --app-id com.example.notes --repo you/notes .`
> On a new branch, run `cd android && ./gradlew :app:testDebugUnitTest :app:verifyRoborazziDebug :app:assembleDebug`
> and `swift test --package-path ios/Packages/AppCore`. Put today's date in the first row of the timeline in
> `docs/history.md`, then commit everything and open a PR titled "Bootstrap from template". Don't change any other
> file the script wrote unless a check fails.

**4. Check and merge the PR.** CI runs the Android build, screenshot check and Maestro flows on an emulator, and
`swift test` on Linux. Add the `walkthrough` label to get the iOS simulator video and the Appetize link in a PR
comment. When the checks are green, merge.

**5. Pin the Appetize app** (if you set the token): the first walk-through run's summary prints the command:

```bash
gh variable set APPETIZE_PUBLIC_KEY --repo you/notes --body <key>
```

**6. Build your app.** Copy `specs/_TEMPLATE.md` to `specs/<feature>.md`, fill it in, and ask a cloud session to build
it (the new repo's README, "How a feature gets built"). When your first real screens are in, ask a session to remove
the planets example: `specs/starter.md`, `specs/search.md`, their flows, screens, tests and screenshot images.

## Keeping the template up to date

`myapp` is where the workflow is tried first; this folder follows it.

- Changes to the workflows, `scripts/`, `.gitattributes`, `.gitignore`, `CLAUDE.md`, `AGENTS.md` and `docs/` (except
  `history.md`) are made in both places in the same PR. The `template` workflow (`.github/workflows/template.yml`) fails on drift: it fills the tokens
  back in with myapp's own names and compares those files with the repo.
- The same workflow makes a sample project with new names and builds it: Android unit tests, screenshot check and APK
  on Linux, `swift test` on Linux, and the iOS build plus snapshot tests on a Mac.
- New features of `myapp` itself stay out, so every new project starts from the small starter app.
