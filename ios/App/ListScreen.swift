import SwiftUI
import AppCore

struct ListScreen: View {
    let items: [Item]
    let onSelect: (Item) -> Void

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView("No planets yet", systemImage: "globe")
            } else {
                List(items) { item in
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

#Preview("Empty") {
    NavigationStack { ListScreen(items: ItemRepository.empty.items()) { _ in } }
}
