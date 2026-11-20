import SwiftUI
import AppCore

/// The planets list with a search field (specs/starter.md, specs/search.md).
///
/// `items` is everything the repository has; the screen shows `items.search(query)`.
/// The query lives in `@State`, so it survives rotation, and each push from Home starts empty.
struct ListScreen: View {
    let items: [Item]
    let onSelect: (Item) -> Void
    @State private var query: String

    init(items: [Item], initialQuery: String = "", onSelect: @escaping (Item) -> Void) {
        self.items = items
        self.onSelect = onSelect
        _query = State(initialValue: initialQuery)
    }

    var body: some View {
        Group {
            if items.isEmpty {
                // No search field when there is nothing to search (specs/search.md).
                ContentUnavailableView("No planets yet", systemImage: "globe")
            } else {
                let results = items.search(query)
                List(results) { item in
                    Button { onSelect(item) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .foregroundStyle(.primary)
                            Text(item.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if results.isEmpty {
                        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                        ContentUnavailableView(
                            "No planets match \"\(trimmed)\"",
                            systemImage: "magnifyingglass"
                        )
                    }
                }
                .searchable(
                    text: $query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search planets"
                )
            }
        }
        .navigationTitle("Planets")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("ListScreen")
    }
}

#Preview("Items") {
    NavigationStack { ListScreen(items: ItemRepository().items()) { _ in } }
}

#Preview("Search") {
    NavigationStack { ListScreen(items: ItemRepository().items(), initialQuery: "planet") { _ in } }
}

#Preview("No results") {
    NavigationStack { ListScreen(items: ItemRepository().items(), initialQuery: "pluto") { _ in } }
}

#Preview("Empty") {
    NavigationStack { ListScreen(items: ItemRepository.empty.items()) { _ in } }
}
