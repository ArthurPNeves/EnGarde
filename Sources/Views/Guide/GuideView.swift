import SwiftUI

struct GuideView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Guide")
                    .font(.largeTitle.weight(.bold))

                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Fencing Rules")
                            .font(.title2.weight(.bold))

                        Text("Keep your guard up, remain balanced, and control distance. A valid en garde stance starts from stable foot spacing, bent knees, and a forward arm that protects your line.")
                            .foregroundStyle(.secondary)

                        HStack(spacing: 14) {
                            InstructionImagePlaceholder(title: "Correct guard distance", symbolName: "figure.stand")
                            InstructionImagePlaceholder(title: "Correct arm alignment", symbolName: "line.3.horizontal.decrease.circle")
                        }

                        Text("During drills, stay fully visible in frame from head to feet. The app will unlock the next exercise only when posture quality is held for 5 continuous seconds.")
                            .foregroundStyle(.secondary)

                        PrimaryActionButton(title: "Next", symbolName: "arrow.right") {
                            appState.advanceFromGuide()
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
