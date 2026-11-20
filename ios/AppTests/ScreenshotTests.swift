import SnapshotTesting
import SwiftUI
import XCTest
import AppCore
@testable import MyApp

/// One snapshot per state in the "States" tables of specs/starter.md and specs/search.md,
/// in light and dark mode.
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

    // specs/search.md
    func testListScreen_search_planet() {
        snap(AppRoot(repository: ItemRepository(), path: [.list], listQuery: "planet"))
    }

    func testListScreen_search_noresults() {
        snap(AppRoot(repository: ItemRepository(), path: [.list], listQuery: "pluto"))
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
            // Put the controller in a real window and let the NavigationStack lay out its
            // pushed screen (title + back button) before the image is taken.
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.overrideUserInterfaceStyle = style
            window.rootViewController = controller
            window.makeKeyAndVisible()
            RunLoop.main.run(until: Date().addingTimeInterval(1.0))
            assertSnapshot(
                of: controller,
                as: .image(on: .iPhone13, drawHierarchyInKeyWindow: true, traits: UITraitCollection(userInterfaceStyle: style)),
                named: name,
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}
