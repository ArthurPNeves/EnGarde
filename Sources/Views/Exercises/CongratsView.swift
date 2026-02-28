import SwiftUI

struct CongratsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var didUnlock = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            GlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Congrats", systemImage: "sparkles")
                        .font(.largeTitle.weight(.bold))

                    Text("You held a valid en garde stance for 5 seconds. Great work.")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Label("En garde completed", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                }
            }
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .center)

            PrimaryActionButton(title: "Back to En garde", symbolName: "list.bullet") {
                appState.returnToEnGarde()
            }
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            guard !didUnlock else { return }
            didUnlock = true
        }
    }
}
