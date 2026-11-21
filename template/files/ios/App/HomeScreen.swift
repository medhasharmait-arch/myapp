import SwiftUI

struct HomeScreen: View {
    let onSeePlanets: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Hello!")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Your cloud-built native app is running.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("See the planets", action: onSeePlanets)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 20)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("HomeScreen")
    }
}

#Preview {
    NavigationStack { HomeScreen {} }
}
