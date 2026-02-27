import SwiftUI

struct EnGardeTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("En garde Tutorial")
                    .font(.largeTitle.weight(.bold))

                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Target posture")
                            .font(.title2.weight(.bold))

                        Text("Stand side-on, bend both knees lightly, and keep your leading arm aligned with your center line. Your rear heel stays grounded and your shoulders remain relaxed.")
                            .foregroundStyle(.secondary)

                        HStack(spacing: 14) {
                            InstructionImagePlaceholder(title: "Knees bent and stable", symbolName: "figure.walk")
                            InstructionImagePlaceholder(title: "Arm and blade line", symbolName: "arrow.up.right")
                        }

                        Text("When the camera confirms full-body framing and correct posture for 5 seconds, your drill is complete.")
                            .foregroundStyle(.secondary)

                        PrimaryActionButton(title: "Next", symbolName: "arrow.right") {
                            appState.openEnGardeCamera()
                        }
                    }
                }
            }
            .frame(maxWidth: 940, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }
}
