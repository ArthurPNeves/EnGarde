import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Welcome 👋")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Your AI fencing coach. Learn faster with real-time visual feedback.")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 18) {
                        topicCard(title: "Camera Vision", symbolName: "camera")
                        topicCard(title: "Posture Analysis", symbolName: "waveform.path.ecg")
                        topicCard(title: "Fencing Drills", symbolName: "figure.run")
                    }
                    .frame(maxWidth: .infinity)

                    PrimaryActionButton(title: "Begin Training", symbolName: "figure.fencing") {
                        appState.beginTrainingFromWelcome()
                    }
                }
                .padding(12)
                .frame(maxWidth: 1240)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func topicCard(title: String, symbolName: String) -> some View {
        TopicCard(title: title, symbolName: symbolName)
    }
}

private struct TopicCard: View {
    let title: String
    let symbolName: String

    @State private var isHovering: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbolName)
                .font(.system(size: 26, weight: .semibold))
                .frame(width: 54, height: 54)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(title)
                .font(.title2.weight(.bold))

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
        .background(Color.white.opacity(isHovering ? 0.14 : 0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(isHovering ? 0.35 : 0.18), lineWidth: 1)
        )
        .scaleEffect(isHovering ? 1.03 : 1.0)
        .shadow(color: .black.opacity(isHovering ? 0.22 : 0.08), radius: isHovering ? 14 : 6, y: isHovering ? 8 : 3)
        .animation(.easeOut(duration: 0.18), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
