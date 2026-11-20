import Foundation

/// One row of the starter list. See specs/starter.md.
public struct Item: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String

    public init(id: String, title: String, subtitle: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}
