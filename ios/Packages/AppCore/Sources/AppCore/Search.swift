import Foundation

extension Array where Element == Item {
    /// Search rules from specs/search.md: case-insensitive "contains" on title or subtitle,
    /// the query is trimmed, and a blank query matches everything. Order is preserved.
    public func search(_ query: String) -> [Item] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return self }
        return filter {
            $0.title.range(of: needle, options: .caseInsensitive) != nil
                || $0.subtitle.range(of: needle, options: .caseInsensitive) != nil
        }
    }
}

extension ItemRepository {
    /// Items whose title or subtitle contains `query` (specs/search.md).
    public func search(_ query: String) -> [Item] {
        items().search(query)
    }
}
