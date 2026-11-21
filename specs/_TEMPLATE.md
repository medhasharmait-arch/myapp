# Spec: <feature name>

<!--
Copy this file to specs/<feature>.md and fill it in before any code is written (AGENTS.md rule 4).
Both apps are built from it: one Android PR and one iOS PR, each linking back here.
Write what the user sees and what must be true, not how to code it. Delete these comments when done.
-->

Status: draft | ready to build. Builds on [`starter.md`](starter.md).

## Behaviour

<!-- What the user can do, step by step. Exact visible text in quotes, because Maestro flows and tests match it. -->

-

## Shared model and logic

<!-- Plain logic goes in AppCore on iOS (Foundation only, tested on Linux) and a plain Kotlin package on Android.
     Give examples as a table so both platforms get the same unit tests. -->

| Input | Expected result |
| --- | --- |
| | |

## Screens

<!-- Use the same screen names on both platforms: Maestro flows and screenshot files use them. -->

### `<ScreenName>`

-

## States

| Screen | States to cover |
| --- | --- |
| | |

Each state gets a screenshot, in light **and** dark mode.

## Acceptance checks

- [ ] Unit tests for the shared logic pass on both platforms (the examples table above).
- [ ] Screenshots are committed for every state in the table, light and dark, and checked by eye.
- [ ] Maestro flow `.maestro/<feature>.yaml` passes on Android (CI) and iOS (`walkthrough` label).
- [ ] Android: `testDebugUnitTest`, `verifyRoborazziDebug` and `assembleDebug` pass in CI.
- [ ] iOS: `swift test` on `AppCore` passes on Linux; the SwiftUI app builds and its snapshot tests pass on macOS.
