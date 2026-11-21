import SwiftUI
import AppCore

struct DetailScreen: View {
    let item: Item

    var body: some View {
        Text(item.subtitle)
            .font(.body)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("DetailScreen")
    }
}

#Preview {
    NavigationStack { DetailScreen(item: ItemRepository.planets[2]) }
}
