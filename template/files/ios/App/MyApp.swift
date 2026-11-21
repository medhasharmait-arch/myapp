import SwiftUI
import AppCore

@main
struct __APP_NAME__: App {
    var body: some Scene {
        WindowGroup {
            AppRoot(repository: ItemRepository())
        }
    }
}
