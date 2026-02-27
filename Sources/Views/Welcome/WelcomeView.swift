import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 10) {
                Image(systemName: "figure.fencing")
                    .font(.title2.weight(.semibold))
                Text("En garde")
                    .font(.largeTitle.weight(.bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("AI-powered fencing posture coach")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            GlassCard {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About the App")
                        .font(.title2.weight(.bold))

                    Text("En garde helps you train with computer-vision posture guidance. Use your camera for real-time stance checks, then progress through structured fencing drills with immediate feedback.")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Divider()

                    VStack(alignment: .leading, spacing: 14) {
                        featureRow(title: "Camera Vision", subtitle: "Real-time full-body detection", symbolName: "camera")
                        featureRow(title: "Posture Analysis", subtitle: "Instant form feedback", symbolName: "waveform.path.ecg")
                        featureRow(title: "Fencing Drills", subtitle: "Guided exercise progression", symbolName: "figure.run")
                    }
                }
            }
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity, alignment: .center)

            PrimaryActionButton(title: "Begin Training", symbolName: "figure.fencing") {
                appState.beginTrainingFromWelcome()
            }
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func featureRow(title: String, subtitle: String, symbolName: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbolName)
                .font(.headline.weight(.semibold))
                .frame(width: 30, height: 30)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
