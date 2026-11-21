# Spec: Starter app (Hello + List)

Status: ready to build. Purpose: prove the whole pipeline end to end (code → tests → screenshots → CI → install) with the
smallest possible app. No backend; the data is hard-coded.

## Shared model (lives in `AppCore` on iOS, a Kotlin `data class` on Android)

`Item`: `id: String`, `title: String`, `subtitle: String`

`ItemRepository.items()` returns these 5 fixed items, in this order:

| id | title | subtitle |
| --- | --- | --- |
| 1 | Mercury | Closest to the Sun |
| 2 | Venus | Hottest planet |
| 3 | Earth | Home |
| 4 | Mars | The red planet |
| 5 | Jupiter | Largest planet |

## Screens

Screen names are the same on both platforms; Maestro flows and screenshot files use them.

### `HomeScreen`

- Large title "Hello!", centred.
- Body text under it: "Your cloud-built native app is running."
- One primary button, "See the planets", which opens `ListScreen`.

### `ListScreen`

- Top bar titled "Planets" with a back action.
- A list of the repository's items. Each row shows `title` (primary text) and `subtitle` (secondary text).
- Tapping a row opens `DetailScreen` for that item.

### `DetailScreen`

- Top bar titled with the item's `title`, with a back action.
- Shows `subtitle` as body text.

## States

| Screen | States to cover |
| --- | --- |
| HomeScreen | default |
| ListScreen | 5 items; empty (repository returns nothing → show "No planets yet") |
| DetailScreen | item 3 (Earth) |

Each state gets a screenshot, in light **and** dark mode.

## Acceptance checks

- [ ] `ItemRepository.items()` returns exactly the 5 items above, in order (unit test on both platforms).
- [ ] Home → List → Detail → back → back works (Maestro flow `.maestro/starter.yaml`).
- [ ] The empty state shows "No planets yet".
- [ ] Screenshots are committed for every state in the table, light and dark.
- [ ] Android: `testDebugUnitTest`, `verifyRoborazziDebug` and `assembleDebug` pass in CI.
- [ ] iOS: `swift test` on `AppCore` passes on Linux; the SwiftUI app builds and its snapshot tests pass on macOS.
