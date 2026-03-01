import SwiftUI

struct UpperBodyTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        PoseTutorialScreen(
            title: "Upper Body",
            heroImageName: "upper_correct",
            tags: ["Front arm forward", "Slight elbow bend", "Back arm elevated"],
            mistakes: [
                .init(imageName: "upper_backNotLifited", title: "Upper Back Not Lifted"),
                .init(imageName: "upper_fowardNotBend", title: "Upper Forward Not Bend"),
                .init(imageName: "upper_fowardNotStraight", title: "Upper Forward Not Straight")
            ],
            buttonTitle: "Next"
        ) {
            appState.openEnGardeUpperBodyCamera()
        }
    }
}

struct LowerBodyTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        PoseTutorialScreen(
            title: "Lower Body",
            heroImageName: "lower_correct",
            tags: ["Both knees deeply bent", "Ankles wider than shoulders", "Weight centered"],
            mistakes: [
                .init(imageName: "lower_notBend", title: "Lower Not Bend"),
                .init(imageName: "lower_notOpen", title: "Lower Not Open")
            ],
            buttonTitle: "Next"
        ) {
            appState.openEnGardeLowerBodyCamera()
        }
    }
}

struct FullPoseTutorialView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        PoseTutorialScreen(
            title: "Full En Garde Pose",
            heroImageName: "full_correct",
            tags: ["Front arm forward & controlled", "Back arm elevated", "Deep knees & wide stance"],
            mistakes: [
                .init(imageName: "full_upper", title: "Full Upper Incorrect"),
                .init(imageName: "full_botton", title: "Full Bottom Incorrect")
            ],
            buttonTitle: "Start Full Check"
        ) {
            appState.openEnGardeFullPoseCamera()
        }
    }
}

private struct PoseMistake: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
}

private struct PoseTutorialScreen: View {
    let title: String
    let heroImageName: String
    let tags: [String]
    let mistakes: [PoseMistake]
    let buttonTitle: String
    let action: () -> Void

    @State private var pageIndex: Int = 0

    var body: some View {
        GeometryReader { proxy in
            let heroHeight = min(max(proxy.size.height * 0.46, 260), 540)

            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                if pageIndex == 0 {
                    Text(briefInstruction)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    ResourceImageView(name: heroImageName)
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: heroHeight)

                    tagsRow

                    Spacer(minLength: 0)
                } else {
                    Text("Common mistakes to avoid before starting the check.")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("Avoid Common Mistakes")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal) {
                        HStack(spacing: 14) {
                            ForEach(mistakes) { mistake in
                                MistakeThumbnail(mistake: mistake)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .scrollIndicators(.hidden)

                    Spacer(minLength: 0)
                }

                Button {
                    if pageIndex == 0 {
                        pageIndex = 1
                    } else {
                        action()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Spacer()
                        Text(pageIndex == 0 ? "Next" : buttonTitle)
                            .font(.title3.weight(.bold))
                        Image(systemName: "arrow.right")
                            .font(.title3.weight(.bold))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.12, green: 0.50, blue: 0.98), Color(red: 0.06, green: 0.40, blue: 0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 18)
        }
    }

    private var briefInstruction: String {
        switch title {
        case "Upper Body":
            return "Align your arms: front arm forward with slight bend, back arm elevated."
        case "Lower Body":
            return "Set a strong base: bend both knees and keep your stance wide and centered."
        default:
            return "Combine upper and lower body alignment, then hold a stable full En Garde posture."
        }
    }

    private var tagsRow: some View {
        HStack(spacing: 10) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.blue.opacity(0.22), in: Capsule(style: .continuous))
            }
        }
    }
}

private struct MistakeThumbnail: View {
    let mistake: PoseMistake

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ResourceImageView(name: mistake.imageName)
                .scaledToFit()
                .frame(width: 150, height: 120)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .padding(6)
                }

            Text(mistake.title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .frame(width: 150, alignment: .leading)
        }
    }
}
