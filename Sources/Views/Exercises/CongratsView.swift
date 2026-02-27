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

                    Text("You held a valid en garde stance for 5 seconds. The next drill is now unlocked.")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Label("Lunge unlocked", systemImage: "lock.open.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                }
            }
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .center)

            PrimaryActionButton(title: "Back to Exercises", symbolName: "list.bullet") {
                appState.returnToExercises()
            }
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            guard !didUnlock else { return }
            didUnlock = true
            appState.unlockLunge()
        }
    }
}
