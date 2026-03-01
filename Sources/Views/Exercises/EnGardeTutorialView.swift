import SwiftUI

struct EnGardeTutorialView: View {
    @EnvironmentObject private var appState: AppState

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
                            mediaCard(resourceName: "EnGardePose", title: "Reference pose")
                            mediaCard(resourceName: "usabilityVideo", title: "Usability video")
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

    private func mediaCard(resourceName: String, title: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black.opacity(0.25))

                ResourceImageView(name: resourceName)
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
            }
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
