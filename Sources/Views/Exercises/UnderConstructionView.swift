import SwiftUI

struct UnderConstructionView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Lunge", systemImage: "hammer.fill")
                        .font(.largeTitle.weight(.bold))
                    Text("This exercise is under construction. Check back soon for guided lunge feedback.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .center)

            PrimaryActionButton(title: "Back to Exercises", symbolName: "arrow.left") {
                appState.returnToExercises()
            }
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
