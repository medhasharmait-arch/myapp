import SwiftUI
import AppCore

/// Navigation destinations; names match the screens in specs/starter.md.
enum Route: Hashable {
    case list
    case detail(Item)
}

/// Home -> List -> Detail navigation. `path` can be preset so snapshot tests render a pushed
/// screen with its real navigation bar and back button.
struct AppRoot: View {
    let repository: ItemRepository
    @State var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeScreen { path.append(.list) }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .list:
                        ListScreen(items: repository.items()) { path.append(.detail($0)) }
                    case .detail(let item):
                        DetailScreen(item: item)
                    }
                }
        }
    }
}
