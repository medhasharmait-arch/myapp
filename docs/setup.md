# Setup

How this repo and its accounts were set up, so it can be checked or redone. Everything is done in a browser or the
phone apps, plus a few light `gh` commands; nothing heavy runs on your computer.

## Accounts (once per person)

| Account | Needed for | Notes |
| --- | --- | --- |
| GitHub | the repo, Actions, reviews | the GitHub mobile app for reviews and notifications |
| Claude (Pro or higher) | cloud sessions, Auto-fix, the Mac action | the Claude app's Code tab, or claude.ai/code |
| Appetize (free) | tapping through the iOS build in a browser | optional |
| ChatGPT Plus | Codex reviews | optional, parked in `LATER.md` |
| Firebase (free) | Android builds to your phone | optional, parked in `LATER.md` |

## Claude GitHub app

Install it from <https://github.com/apps/claude> → Configure, with access to this repo ("All repositories" saves doing
it for each new repo). It lets cloud sessions push branches and open PRs, and it turns on Auto-fix for PRs.

## Claude Code cloud environment `native-mobile` (once per account; every repo can reuse it)

At claude.ai/code → environment picker → **Add environment**:

- **Name:** `native-mobile`
- **Network access:** Custom, keep the default list, and add `dl.google.com`, `maven.google.com`,
  `services.gradle.org`, `plugins.gradle.org`, `download.swift.org`. (Full also works.)
- **Environment variables:**

  ```text
  ANDROID_HOME=/opt/android-sdk
  ANDROID_SDK_ROOT=/opt/android-sdk
  JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
  ```

- **Setup script:** the whole of [`scripts/cloud-setup.sh`](../scripts/cloud-setup.sh). It installs JDK 17 and 21,
  the Android command-line tools (API 36, build-tools 36.0.0, platform-tools) and Swift 6.4.2, in about 1.5 minutes
  (under the ~5-minute limit for the environment to be cached). It is idempotent.

When you change `scripts/cloud-setup.sh`, paste it into the environment again: the environment keeps its own copy.

## Token for Claude on a Mac

Run `claude setup-token` once (any terminal; a GitHub Codespace in the browser works). It prints a long-lived token
tied to your Claude subscription. Keep it in a password manager and save it as each repo's
`CLAUDE_CODE_OAUTH_TOKEN` secret. To pay per use instead, swap the action input in `ios-claude.yml` to
`anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}`.

## The GitHub repo

1. **Public**, with a README so `main` exists.
2. **Labels:**

   ```bash
   gh label create ios --color 000000 --description "Request a macOS run (@claude on a Mac runner)"
   gh label create walkthrough --color 5319E7 --description "Record the Maestro flows on the iOS simulator as a video"
   ```

3. **Settings → Actions → General → Workflow permissions:** "Read repository contents" (the default). Workflows that
   need more ask for it in their own `permissions:`.
4. **Ruleset** (Settings → Rules → Rulesets → New branch ruleset): name **Protect main**, enforcement Active, target
   the default branch, with:
   - Restrict deletions; Block force pushes
   - Require a pull request before merging (0 approvals)
   - Require status checks to pass: `android-build`, `android-e2e`, `ios-core-test`, each with source
     **GitHub Actions** (not "any source"); "Require branches to be up to date" off
5. **Secrets and variables → Actions:**
   - secret `CLAUDE_CODE_OAUTH_TOKEN` (above)
   - secret `APPETIZE_API_TOKEN` (optional): appetize.io → Account → API token
   - variable `APPETIZE_PUBLIC_KEY`: after the first walk-through run, from that run's summary

   Set them yourself in the browser or with `gh secret set NAME --repo <owner/name>`, which prompts for the value, so
   it never passes through a chat or a file.

## Phone

GitHub, Claude, and optionally ChatGPT and Firebase App Tester. Turn on GitHub notifications for pull requests and
Actions.

## Check the setup

- A docs-only PR: the three required checks show "skipped" and the PR can merge.
- A PR touching `android/`: `android-build` and `android-e2e` run and pass.
- A PR with the `walkthrough` label: a comment with the video link appears.
- On a PR with the `ios` label, `@claude say hello`: the Mac job starts (cancel it if you only wanted to check).
