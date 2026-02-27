import SwiftUI

struct CamSetupView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Camera Setup")
                    .font(.largeTitle.weight(.bold))

                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Position your device")
                            .font(.title2.weight(.bold))

                        Text("Place your device so your full body is visible. Keep your feet and head inside the frame before you begin posture checks.")
                            .foregroundStyle(.secondary)

                        HStack(spacing: 14) {
                            InstructionImagePlaceholder(title: "Device at chest height", symbolName: "ipad.landscape")
                            InstructionImagePlaceholder(title: "Body centered in frame", symbolName: "viewfinder")
                        }

                        Text("Good lighting improves tracking stability and lowers false negatives in pose detection.")
                            .foregroundStyle(.secondary)

                        PrimaryActionButton(title: "Next", symbolName: "arrow.right") {
                            appState.startSetupCameraFlow()
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
