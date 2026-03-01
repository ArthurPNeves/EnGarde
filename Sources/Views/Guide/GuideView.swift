import SwiftUI

struct GuideView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        GeometryReader { proxy in
            let topImageMaxHeight = min(max(proxy.size.height * 0.22, 140), 220)
            let usageImageMaxHeight = min(max(proxy.size.height * 0.28, 180), 280)

            VStack(alignment: .leading, spacing: 16) {
                Text("Guide")
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                Text("Fencing is about distance, timing, balance, and control. The En Garde stance is your base: stable legs, ready arms, and clear posture before every action.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 800, alignment: .leading)

                HStack(alignment: .top, spacing: 18) {
                    illustrationCard(resourceName: "EnGardePose", label: "En Garde stance", maxHeight: topImageMaxHeight)
                    illustrationCard(resourceName: preferredFightImageName, label: "Fight context", maxHeight: topImageMaxHeight)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Our algorithm detects key joints and posture angles in real time to tell you exactly what to adjust.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 760, alignment: .leading)

                    ResourceImageView(name: "usageImage")
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: usageImageMaxHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Spacer(minLength: 8)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Before training, setup your camera.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

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
            }
            .frame(maxWidth: 1000, maxHeight: .infinity, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 18)
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

    private func illustrationCard(resourceName: String, label: String, maxHeight: CGFloat) -> some View {
        VStack(spacing: 6) {
            ResourceImageView(name: resourceName)
                .scaledToFit()
                .frame(maxHeight: maxHeight)
                .frame(maxWidth: .infinity)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
