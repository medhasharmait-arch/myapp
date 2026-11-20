# Spec: Search the planets list

Status: ready to build. Builds on [`starter.md`](starter.md). Still no backend; the data is the same 5 hard-coded items.

## Behaviour

`ListScreen` gets a search field directly under its top bar.

- Placeholder text: "Search planets". It has a leading search icon.
- While the field has text, it shows a clear button (accessibility label "Clear search") that empties the field.
- Typing filters the list immediately; there is no submit button.
- An item matches when its `title` **or** its `subtitle` contains the query:
  - matching is case-insensitive,
  - leading and trailing spaces in the query are ignored,
  - a blank query matches every item.
- Matching items keep the repository's order.
- Tapping a matching row opens `DetailScreen` as before.
- The query survives a rotation or other configuration change. It does not need to survive leaving `ListScreen`: coming back from Home starts with an empty field.

## Empty and no-result states

| Situation | What `ListScreen` shows |
| --- | --- |
| The repository has no items | "No planets yet" (as in `starter.md`). No search field. |
| The repository has items, none match the query | The search field, and below it the text: No planets match "<query>" (the trimmed query, in straight double quotes) |

## Shared logic

The filtering is plain logic, so it lives next to the model and is unit-tested on both platforms:

- `ItemRepository.search(query)` returns `items()` filtered by the rules above.
- Android: in `com.myapp.data`. iOS: in `AppCore` (Foundation only, so it is tested on Linux).

Examples, using the 5 starter items:

| Query | Result (titles, in order) |
| --- | --- |
| `""` or `"   "` | Mercury, Venus, Earth, Mars, Jupiter |
| `"planet"` | Venus, Mars, Jupiter (subtitle match) |
| `"EARTH"` | Earth |
| `"  mars "` | Mars |
| `"pluto"` | (none) |

## States

| Screen | States to cover |
| --- | --- |
| ListScreen | 5 items with an empty search field; query "planet" (3 results); query "pluto" (no results); empty repository (unchanged from `starter.md`) |

Each state gets a screenshot, in light **and** dark mode.

## Acceptance checks

- [ ] `ItemRepository.search` returns the results in the examples table (unit test on both platforms).
- [ ] The no-results state shows No planets match "pluto".
- [ ] Screenshots are committed for every state in the table, light and dark.
- [ ] List → type "red" → only Mars is listed → tap Mars → Detail shows "The red planet" (Maestro flow `.maestro/search.yaml`).
- [ ] Android: `testDebugUnitTest`, `verifyRoborazziDebug`, `assembleDebug` and the Maestro flows pass in CI.
- [ ] iOS: `swift test` on `AppCore` passes on Linux; the SwiftUI app builds and its snapshot tests pass on macOS.
