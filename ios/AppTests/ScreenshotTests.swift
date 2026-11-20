import SnapshotTesting
import SwiftUI
import XCTest
import AppCore
@testable import MyApp

/// One snapshot per state in the specs/starter.md "States" table, in light and dark mode.
/// Images: ios/AppTests/__Snapshots__/ScreenshotTests/<test>.<light|dark>.png
/// Record by setting `record: .all` below (or SNAPSHOT_TESTING_RECORD=all), then look at the images.
@MainActor
final class ScreenshotTests: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }

    func testHomeScreen_default() {
        snap(AppRoot(repository: ItemRepository()))
    }

    func testListScreen_items() {
        snap(AppRoot(repository: ItemRepository(), path: [.list]))
    }

    func testListScreen_empty() {
        snap(AppRoot(repository: .empty, path: [.list]))
    }

    func testDetailScreen_earth() {
        let earth = ItemRepository().item(id: "3")!
        snap(AppRoot(repository: ItemRepository(), path: [.list, .detail(earth)]))
    }

    private func snap(
        _ view: some View,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        for (name, style) in [("light", UIUserInterfaceStyle.light), ("dark", .dark)] {
            let controller = UIHostingController(rootView: view)
            assertSnapshot(
                of: controller,
                as: .image(on: .iPhone13, traits: UITraitCollection(userInterfaceStyle: style)),
                named: name,
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}
