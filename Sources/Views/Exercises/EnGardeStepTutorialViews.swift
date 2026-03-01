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

    @State private var segmentIndex: Int = 0

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
                        if segmentIndex == 0 {
                            Text("Mission 1/2")
                                .font(.title3.weight(.semibold))

                            ResourceImageView(name: imageName)
                                .scaledToFill()
                                .frame(height: 210)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(.white.opacity(0.16), lineWidth: 1)
                                )

                            HStack(spacing: 8) {
                                ForEach(bullets, id: \.self) { bullet in
                                    Text(bullet)
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(.thinMaterial, in: Capsule(style: .continuous))
                                }
                            }

                            Button {
                                segmentIndex = 1
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("NEXT")
                                        .font(.subheadline.weight(.bold))
                                        .tracking(0.4)
                                    Image(systemName: "arrow.right")
                                        .font(.subheadline.weight(.bold))
                                    Spacer()
                                }
                                .foregroundStyle(.white)
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
                        } else {
                            Text("Mission 2/2")
                                .font(.title3.weight(.semibold))

                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(alignment: .top, spacing: 14) {
                                incorrectPanel
                                correctPanel
                            }

                            PrimaryActionButton(title: buttonTitle, symbolName: "arrow.right", action: action)
                        }
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

    private var incorrectPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("X Incorrect", systemImage: "xmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.red)

            HStack(spacing: 8) {
                ForEach(Array(bullets.prefix(3)), id: \.self) { bullet in
                    VStack(spacing: 5) {
                        ResourceImageView(name: "template_vertical")
                            .scaledToFill()
                            .frame(width: 92, height: 130)
                            .clipped()
                            .overlay(alignment: .bottom) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.red)
                                    .offset(y: 9)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(.red.opacity(0.65), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        Text(bullet)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red.opacity(0.9))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var correctPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("✓ Correct", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.green)

            ZStack {
                ResourceImageView(name: "template_vertical")
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.green.opacity(0.75), lineWidth: 1.2)

                VStack {
                    Spacer()
                    Image(systemName: "figure.fencing")
                        .font(.title)
                        .foregroundStyle(.green)
                    Spacer()
                    HStack {
                        Rectangle().fill(.green.opacity(0.6)).frame(height: 1)
                        Rectangle().fill(.green.opacity(0.6)).frame(height: 1)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(width: 220, alignment: .leading)
    }
}
