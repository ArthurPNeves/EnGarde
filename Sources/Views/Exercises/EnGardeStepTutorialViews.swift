import SwiftUI

struct UpperBodyTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        EnGardeStepTutorialScaffold(
            title: "Upper Body Tutorial",
            subtitle: "Front arm, back arm, blade line",
            description: "Focus on your upper body. Point the front arm forward with a slight bend at the elbow and keep the back arm elevated for balance.",
            bullets: [
                "Front arm points forward",
                "Front elbow stays slightly bent",
                "Back arm lifted and stable"
            ],
            imageName: "template",
            buttonTitle: "Next"
        ) {
            appState.openEnGardeUpperBodyCamera()
        }
    }
}

struct LowerBodyTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        EnGardeStepTutorialScaffold(
            title: "Lower Body Tutorial",
            subtitle: "Deep bend and wide stance",
            description: "Now train your lower body. Keep both knees deeply bent and maintain a wide base so your stance is grounded and stable.",
            bullets: [
                "Both knees deeply bent",
                "Ankles wider than shoulders",
                "Weight centered and controlled"
            ],
            imageName: "template_vertical",
            buttonTitle: "Next"
        ) {
            appState.openEnGardeLowerBodyCamera()
        }
    }
}

struct FullPoseTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        EnGardeStepTutorialScaffold(
            title: "Full Pose Tutorial",
            subtitle: "Combine upper and lower body",
            description: "Combine everything: upper body alignment and lower body structure. Hold the full en garde pose for 5 seconds to complete the drill.",
            bullets: [
                "Front arm forward and controlled",
                "Back arm elevated",
                "Deep knees and wide stance"
            ],
            imageName: "swords",
            buttonTitle: "Start Full Check"
        ) {
            appState.openEnGardeFullPoseCamera()
        }
    }
}

private struct EnGardeStepTutorialScaffold: View {
    let title: String
    let subtitle: String
    let description: String
    let bullets: [String]
    let imageName: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: "figure.fencing")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)

                        ResourceImageView(name: imageName)
                            .scaledToFill()
                            .frame(height: 210)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(.white.opacity(0.16), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(bullets, id: \.self) { bullet in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text(bullet)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        PrimaryActionButton(title: buttonTitle, symbolName: "arrow.right", action: action)
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
}
