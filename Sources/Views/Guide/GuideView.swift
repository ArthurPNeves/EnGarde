import SwiftUI

struct GuideView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Guide", systemImage: "figure.fencing")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Fencing is about distance, timing, balance, and control. The En Garde stance is your base: stable legs, ready arms, and clear posture before every action.")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 18) {
                        guideImage(resourceName: "EnGardePose", label: "En Garde stance")
                        guideImage(resourceName: preferredFightImageName, label: "Fight context")
                    }

                    Text("Our algorithm detects key joints and posture angles in real time to tell you exactly what to adjust.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    guideImage(resourceName: "usageImage", label: "Real-time algorithm feedback")

                    Text("Before training, setup your camera.")
                        .font(.title3.weight(.medium))

                    Button {
                        appState.advanceFromGuide()
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.subheadline.weight(.semibold))

                            Text("SETUP CAMERA")
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
                .padding(.horizontal, 8)
                .frame(maxWidth: 980, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                guideScrollCue
            }
        }
    }

    private var preferredFightImageName: String {
        resourceExists(named: "fight") ? "fight" : "Pasted image"
    }

    private func resourceExists(named name: String) -> Bool {
        if Bundle.module.url(forResource: name, withExtension: nil) != nil {
            return true
        }

        let candidates = ["png", "jpg", "jpeg", "heic", "webp", "gif", "mp4"]
        return candidates.contains { ext in
            Bundle.module.url(forResource: name, withExtension: ext) != nil
        }
    }

    private var guideScrollCue: some View {
        VStack(spacing: 4) {
            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
            Text("Scroll")
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(.white.opacity(0.85))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.22), in: Capsule(style: .continuous))
        .padding(.bottom, 8)
        .allowsHitTesting(false)
    }

    private func guideImage(resourceName: String, label: String) -> some View {
        VStack(spacing: 6) {
            ResourceImageView(name: resourceName)
                .scaledToFit()
                .frame(height: 250)
                .frame(maxWidth: .infinity)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
