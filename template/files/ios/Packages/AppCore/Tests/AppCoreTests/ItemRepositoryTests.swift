import XCTest
@testable import AppCore

final class ItemRepositoryTests: XCTestCase {
    func testItemsReturnsExactlyTheFivePlanetsInSpecOrder() {
        let expected = [
            Item(id: "1", title: "Mercury", subtitle: "Closest to the Sun"),
            Item(id: "2", title: "Venus", subtitle: "Hottest planet"),
            Item(id: "3", title: "Earth", subtitle: "Home"),
            Item(id: "4", title: "Mars", subtitle: "The red planet"),
            Item(id: "5", title: "Jupiter", subtitle: "Largest planet"),
        ]
        XCTAssertEqual(ItemRepository().items(), expected)
    }

    func testItemLooksUpById() {
        let repository = ItemRepository()
        XCTAssertEqual(repository.item(id: "3")?.title, "Earth")
        XCTAssertNil(repository.item(id: "42"))
    }

    func testEmptyRepositoryReturnsNoItems() {
        XCTAssertTrue(ItemRepository.empty.items().isEmpty)
        XCTAssertNil(ItemRepository.empty.item(id: "1"))
    }
}
