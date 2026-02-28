import SwiftUI

struct EnGardeTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("En garde Tutorial", systemImage: "figure.fencing")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Stance & Alignment")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Stand side-on in en garde. Keep your weight centered, your front knee bent, and your back leg stable. Your leading arm stays aligned with your center line.")
                            .font(.body)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            tutorialImageCard(resourceName: "template", title: "Stance shape")
                            tutorialImageCard(resourceName: "swords", title: "Guard line")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            checklistRow(symbol: "checkmark.circle.fill", text: "Knees bent and stable")
                            checklistRow(symbol: "checkmark.circle.fill", text: "Feet in balanced split stance")
                            checklistRow(symbol: "checkmark.circle.fill", text: "Weapon arm aligned forward")
                            checklistRow(symbol: "camera.viewfinder", text: "Camera framing: top of neck to feet")
                        }

                        Toggle(isOn: $appState.isRightHanded) {
                            Text(appState.isRightHanded ? "Right-handed stance" : "Left-handed stance")
                                .font(.subheadline.weight(.medium))
                        }
                        .toggleStyle(.switch)

                        Text("Hold the correct alignment for 5 continuous seconds to complete the exercise.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button {
                            appState.openEnGardeUpperBodyTutorial()
                        } label: {
                            HStack {
                                Image(systemName: "figure.fencing")
                                    .font(.subheadline.weight(.semibold))

                                Text("START EN GARDE CHECK")
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
                    .padding(20)
                    .frame(maxWidth: 780, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
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

    private func tutorialImageCard(resourceName: String, title: String) -> some View {
        VStack(spacing: 6) {
            ResourceImageView(name: resourceName)
                .scaledToFill()
                .frame(height: 165)
                .frame(maxWidth: .infinity)
                .clipped()
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

    private func checklistRow(symbol: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
