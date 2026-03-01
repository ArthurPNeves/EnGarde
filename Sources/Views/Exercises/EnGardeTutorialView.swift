import SwiftUI
import AVKit

struct EnGardeTutorialView: View {
    @EnvironmentObject private var appState: AppState
    @State private var usabilityPlayer: AVPlayer?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("En garde Tutorial", systemImage: "figure.fencing")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Build your En garde base")
                            .font(.title3.weight(.semibold))

                        Text("Use the references below, then start the guided checks for upper body, lower body, and full pose.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            imageMediaCard(resourceName: "EnGardePose", title: "Reference pose")
                            videoMediaCard(title: "Usability video")
                        }

                        HStack(spacing: 8) {
                            quickTag("Knees bent")
                            quickTag("Wide base")
                            quickTag("Arms ready")
                            quickTag("Hold 5s")
                        }

                        Toggle(isOn: $appState.isRightHanded) {
                            Text(appState.isRightHanded ? "Right-handed stance" : "Left-handed stance")
                                .font(.subheadline.weight(.medium))
                        }
                        .toggleStyle(.switch)

                        nextButton(title: "START EN GARDE CHECK") {
                            appState.openEnGardeUpperBodyTutorial()
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 1280, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(.white.opacity(0.16), lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            if usabilityPlayer == nil,
               let url = Bundle.module.url(forResource: "usabilityVideo", withExtension: "mp4") {
                let player = AVPlayer(url: url)
                player.isMuted = true
                player.play()
                usabilityPlayer = player
            }
        }
        .onDisappear {
            usabilityPlayer?.pause()
        }
    }

    private func nextButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "figure.fencing")
                    .font(.subheadline.weight(.semibold))

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .tracking(0.4)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.12, green: 0.50, blue: 0.98), Color(red: 0.06, green: 0.40, blue: 0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func quickTag(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.08), in: Capsule(style: .continuous))
    }

    private func imageMediaCard(resourceName: String, title: String) -> some View {
        VStack(spacing: 6) {
            ResourceImageView(name: resourceName)
                .scaledToFit()
                .frame(maxWidth: .infinity)
            .frame(height: 280)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func videoMediaCard(title: String) -> some View {
        VStack(spacing: 6) {
            Group {
                if let usabilityPlayer {
                    VideoPlayer(player: usabilityPlayer)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
