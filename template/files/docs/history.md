# History

What happened when, and the state of things now. Newest milestone last. Add a line when a PR changes something
others need to know.

## Current state

- **Built:** the starter app from the workflow template (Home → Planets list → Detail, empty state, search) on Android
  and iOS, with unit tests, screenshots in light and dark, and Maestro flows. Replace it with your own features
  (see [playbook.md](playbook.md)), then update this line.
- **Parked:** see [../LATER.md](../LATER.md).
- **Known follow-up from the template:** the two iOS search snapshots use `precision: 0.99` because the clear button
  appears late ([troubleshooting.md](troubleshooting.md)).

## IDs and names this repo uses (no secret values)

| What | Value |
| --- | --- |
| Repo | `__REPO__`, public, default branch `main` |
| Android application id / package | `__APP_ID__` |
| iOS bundle id / Xcode scheme | `__IOS_BUNDLE_ID__` / `__APP_NAME__` |
| Cloud environment | `native-mobile` (setup script `scripts/cloud-setup.sh`) |
| Ruleset | "Protect main"; required checks `android-build`, `android-e2e`, `ios-core-test` (GitHub Actions) |
| Labels | `ios`, `walkthrough` |
| Secrets | `CLAUDE_CODE_OAUTH_TOKEN`, `APPETIZE_API_TOKEN` (optional) |
| Variables | `APPETIZE_PUBLIC_KEY` = (fill in after the first walk-through run) |
| Video release | tag `walkthroughs` (pre-release): `main-walkthrough.mp4`, `pr-<N>-walkthrough.mp4` |
| Snapshot reference image | `macos-latest` with Xcode 26.6, iPhone 17, iOS 26 (update when re-recorded) |

## Timeline

| Date | PR | What |
| --- | --- | --- |
| | #1 | Bootstrapped from the workflow template (<https://github.com/medhasharmait-arch/myapp/tree/main/template>) |
