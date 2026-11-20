import SwiftUI
import AppCore

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            AppRoot(repository: ItemRepository())
        }
    }
}
