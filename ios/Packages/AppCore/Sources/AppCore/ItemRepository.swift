import Foundation

/// Hard-coded data source for the starter app (specs/starter.md).
///
/// The default instance returns the 5 planets; `ItemRepository.empty` returns nothing and
/// drives the ListScreen empty state.
public struct ItemRepository: Sendable {
    public static let planets: [Item] = [
        Item(id: "1", title: "Mercury", subtitle: "Closest to the Sun"),
        Item(id: "2", title: "Venus", subtitle: "Hottest planet"),
        Item(id: "3", title: "Earth", subtitle: "Home"),
        Item(id: "4", title: "Mars", subtitle: "The red planet"),
        Item(id: "5", title: "Jupiter", subtitle: "Largest planet"),
    ]

    /// A repository with no items, for the empty state.
    public static let empty = ItemRepository(source: [])

    private let source: [Item]

    public init(source: [Item] = ItemRepository.planets) {
        self.source = source
    }

    public func items() -> [Item] {
        source
    }

    public func item(id: String) -> Item? {
        source.first { $0.id == id }
    }
}
