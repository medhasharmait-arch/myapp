import XCTest
@testable import AppCore

/// The examples table in specs/search.md.
final class SearchTests: XCTestCase {
    private let repository = ItemRepository()

    private func titles(_ query: String) -> [String] {
        repository.search(query).map(\.title)
    }

    func testBlankQueryReturnsEveryItemInOrder() {
        XCTAssertEqual(repository.search(""), repository.items())
        XCTAssertEqual(repository.search("   "), repository.items())
    }

    func testSearchMatchesSubtitlesAndKeepsOrder() {
        XCTAssertEqual(titles("planet"), ["Venus", "Mars", "Jupiter"])
    }

    func testSearchIsCaseInsensitiveAndTrimsTheQuery() {
        XCTAssertEqual(titles("EARTH"), ["Earth"])
        XCTAssertEqual(titles("  mars "), ["Mars"])
    }

    func testSearchWithNoMatchReturnsNothing() {
        XCTAssertTrue(repository.search("pluto").isEmpty)
        XCTAssertTrue(ItemRepository.empty.search("").isEmpty)
    }
}
