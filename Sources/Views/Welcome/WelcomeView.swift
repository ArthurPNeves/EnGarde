import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 26) {
                Text("Welcome to En Garde 👋")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Your AI-powered fencing coach. Master your stance with real-time computer vision.")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: 880)

                HStack(alignment: .top, spacing: 34) {
                    FeatureColumn(
                        symbolName: "camera.viewfinder",
                        title: "Camera Vision",
                        description: "Tracks your joints in real-time."
                    )
                    FeatureColumn(
                        symbolName: "waveform.path.ecg",
                        title: "Posture Analysis",
                        description: "Provides instant feedback on your stance."
                    )
                    FeatureColumn(
                        symbolName: "figure.fencing",
                        title: "Fencing Drills",
                        description: "Master the En Garde step-by-step."
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 6)

                Button {
                    appState.beginTrainingFromWelcome()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.headline.weight(.bold))
                        Text("Begin Training")
                            .font(.title3.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.12, green: 0.50, blue: 0.98), Color(red: 0.06, green: 0.40, blue: 0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Capsule(style: .continuous)
                    )
                    .shadow(color: Color.blue.opacity(0.35), radius: 14, y: 8)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 760)
                .padding(.top, 12)
            }
            .frame(maxWidth: 1240)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)

            Spacer(minLength: 18)
        }
    }
}

private struct FeatureColumn: View {
    let title: String
    let symbolName: String
    let description: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbolName)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color(red: 0.19, green: 0.60, blue: 1.0))

            Text(title)
                .font(.title3.weight(.bold))

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity)
    }
}
