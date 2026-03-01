import SwiftUI

struct UpperBodyTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        EnGardeStepTutorialScaffold(
            title: "Upper Body Tutorial",
            description: "Focus on your upper body. Point the front arm forward with a slight bend at the elbow and keep the back arm elevated for balance.",
            bullets: [
                "Front arm points forward",
                "Front elbow stays slightly bent",
                "Back arm lifted and stable"
            ],
            imageName: "upper_correct",
            incorrectImageNames: ["upper_backNotLifited", "upper_fowardNotBend", "upper_fowardNotStraight"],
            correctImageName: "upper_correct",
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
            description: "Now train your lower body. Keep both knees deeply bent and maintain a wide base so your stance is grounded and stable.",
            bullets: [
                "Both knees deeply bent",
                "Ankles wider than shoulders",
                "Weight centered and controlled"
            ],
            imageName: "lower_correct",
            incorrectImageNames: ["lower_notBend", "lower_notOpen"],
            correctImageName: "lower_correct",
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
            description: "Combine everything: upper body alignment and lower body structure. Hold the full en garde pose for 5 seconds to complete the drill.",
            bullets: [
                "Front arm forward and controlled",
                "Back arm elevated",
                "Deep knees and wide stance"
            ],
            imageName: "full_correct",
            incorrectImageNames: ["full_upper", "full_botton"],
            correctImageName: "full_correct",
            buttonTitle: "Start Full Check"
        ) {
            appState.openEnGardeFullPoseCamera()
        }
    }
}

private struct EnGardeStepTutorialScaffold: View {
    let title: String
    let description: String
    let bullets: [String]
    let imageName: String
    let incorrectImageNames: [String]
    let correctImageName: String
    let buttonTitle: String
    let action: () -> Void

    @State private var segmentIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: "figure.fencing")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        if segmentIndex == 0 {
                            Text("Mission 1/2")
                                .font(.title3.weight(.semibold))

                            ResourceImageView(name: imageName)
                                .scaledToFit()
                                .frame(height: 210)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(.white.opacity(0.16), lineWidth: 1)
                                )

                            Text(readableSubtitle(from: imageName))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                ForEach(bullets, id: \.self) { bullet in
                                    Text(bullet)
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.08), in: Capsule(style: .continuous))
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

                            HStack(spacing: 10) {
                                Button {
                                    segmentIndex = 0
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.left")
                                            .font(.subheadline.weight(.bold))
                                        Text("BACK")
                                            .font(.subheadline.weight(.bold))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 13)
                                    .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                                            .strokeBorder(.white.opacity(0.22), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)

                                PrimaryActionButton(title: buttonTitle, symbolName: "arrow.right", action: action)
                            }
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

    private var incorrectPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("X Incorrect", systemImage: "xmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.red)

            HStack(spacing: 8) {
                ForEach(incorrectImageNames, id: \.self) { imageName in
                    VStack(spacing: 5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.black.opacity(0.28))

                            ResourceImageView(name: imageName)
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(4)
                        }
                        .frame(width: 92, height: 130)
                        .overlay(alignment: .bottom) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.red)
                                .padding(.bottom, 4)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(.red.opacity(0.65), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        Text(readableSubtitle(from: imageName))
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
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black.opacity(0.28))

                ResourceImageView(name: correctImageName)
                    .scaledToFit()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .padding(6)

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

            Text(readableSubtitle(from: correctImageName))
                .font(.caption2)
                .foregroundStyle(.green.opacity(0.9))
        }
        .frame(width: 220, alignment: .leading)
    }

    private func readableSubtitle(from imageName: String) -> String {
        var expanded = ""
        for character in imageName {
            if character == "_" {
                expanded.append(" ")
                continue
            }

            if character.isUppercase, !expanded.isEmpty, expanded.last != " " {
                expanded.append(" ")
            }

            expanded.append(character)
        }

        return expanded
            .replacingOccurrences(of: "foward", with: "forward")
            .replacingOccurrences(of: "Lifited", with: "lifted")
            .replacingOccurrences(of: "botton", with: "bottom")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}
