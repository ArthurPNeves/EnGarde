import SwiftUI

struct UnderConstructionView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("En garde", systemImage: "hammer.fill")
                        .font(.largeTitle.weight(.bold))
                    Text("This area is under construction.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .center)

            PrimaryActionButton(title: "Back to En garde", symbolName: "arrow.left") {
                appState.returnToEnGarde()
            }
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
