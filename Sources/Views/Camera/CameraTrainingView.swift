import SwiftUI
import Vision

struct CameraTrainingView: View {
    let mode: PoseTrainingMode
    let nextButtonTitle: String
    let onComplete: () -> Void

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @StateObject private var poseEstimatorViewModel = PoseEstimatorViewModel()
    @State private var isReferencePoseVisible: Bool = true

    private let skeletonPassColor: Color = .green
    private let skeletonFailColor: Color = .red
    private let skeletonNeutralColor: Color = .gray.opacity(0.7)

    var body: some View {
        ZStack {
            CameraPreviewView(session: poseEstimatorViewModel.captureSession)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            PoseSkeletonOverlayView(
                points: poseEstimatorViewModel.skeletonPoints,
                segments: activeSkeletonSegments
            )
            .allowsHitTesting(false)

            LinearGradient(
                colors: [Color.black.opacity(0.35), Color.clear, Color.black.opacity(0.45)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            if showNextButton {
                centerNextButton
            }

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    if mode == .enGarde {
                        enGardeChecklistOverlay
                    }

                    Spacer(minLength: 0)

                    referencePoseOverlay
                }
                .padding(16)

                if let errorMessage = poseEstimatorViewModel.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                HStack(alignment: .center) {
                    Button {
                        appState.goBackToTutorial(from: mode)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left")
                                .font(.subheadline.weight(.bold))
                            Text("Go back to tutorial")
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .foregroundStyle(.white)
                        .background(Color.black.opacity(0.35), in: Capsule(style: .continuous))
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

                holdProgressLine
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
        .onAppear {
            poseEstimatorViewModel.configureDependencies(appState: appState, audioPlayerViewModel: audioPlayerViewModel)
            poseEstimatorViewModel.start(mode: mode)
        }
        .onDisappear {
            poseEstimatorViewModel.stop()
        }
    }

    private var centerNextButton: some View {
        Button(action: onComplete) {
            HStack(spacing: 12) {
                Text(nextButtonTitle)
                    .font(.title2.weight(.heavy))
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2.weight(.heavy))
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 18)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color.green, Color.green.opacity(0.78)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule(style: .continuous)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .green.opacity(0.45), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var referencePoseOverlay: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isReferencePoseVisible.toggle()
                }
            } label: {
                Label(isReferencePoseVisible ? "Hide pose" : "Show pose", systemImage: isReferencePoseVisible ? "eye.slash.fill" : "eye.fill")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .foregroundStyle(.white)
                    .background(Color.black.opacity(0.35), in: Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            if isReferencePoseVisible {
                ResourceImageView(name: referencePoseImageName)
                    .scaledToFit()
                    .frame(width: referencePoseWidth)
                    .padding(8)
                    .background(Color.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.white.opacity(0.22), lineWidth: 1)
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
    }

    private var referencePoseWidth: CGFloat {
        guard mode == .enGarde else { return 170 }
        switch appState.currentEnGardeStep {
        case .fullPose, .completed:
            return 260
        default:
            return 170
        }
    }

    private var referencePoseImageName: String {
        switch mode {
        case .setup:
            return "camSetup_correct"
        case .enGarde:
            switch appState.currentEnGardeStep {
            case .upperBody:
                return resourceExists(named: "uperr_correct") ? "uperr_correct" : "upper_correct"
            case .lowerBody:
                return "lower_correct"
            case .fullPose, .completed:
                return "Full_correct2"
            }
        }
    }

    private func resourceExists(named name: String) -> Bool {
        if Bundle.module.url(forResource: name, withExtension: nil) != nil {
            return true
        }

        let candidates = ["png", "jpg", "jpeg", "heic", "webp"]
        return candidates.contains { ext in
            Bundle.module.url(forResource: name, withExtension: ext) != nil
        }
    }

    private var holdProgressLine: some View {
        GeometryReader { proxy in
            let progress = max(0, min(poseEstimatorViewModel.holdProgress, 1))
            let fillColor: Color = progress >= 1 ? .green : .yellow

            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(.white.opacity(0.18))

                Capsule(style: .continuous)
                    .fill(fillColor)
                    .frame(width: proxy.size.width * progress)
                    .shadow(color: fillColor.opacity(0.55), radius: 6)
            }
        }
        .frame(height: 10)
    }

    @ViewBuilder
    private var enGardeChecklistOverlay: some View {
        if appState.currentEnGardeStep == .fullPose || appState.currentEnGardeStep == .completed {
            VStack(alignment: .leading, spacing: 10) {
                checklistPanel(title: "Upper Body", items: upperChecklistItems)
                checklistPanel(title: "Lower Body", items: lowerChecklistItems)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        } else {
            checklistPanel(title: nil, items: activeChecklistItems)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private func checklistPanel(title: String?, items: [(title: String, isValid: Bool)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 2)
            }

            ForEach(items, id: \.title) { item in
                checklistRow(title: item.title, isValid: item.isValid)
            }
        }
        .padding(14)
        .frame(maxWidth: 300, alignment: .leading)
    }

    @ViewBuilder
    private func checklistRow(title: String, isValid: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(isValid ? .green : .red)
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
    }

    private var wholeBodyItem: (title: String, isValid: Bool) {
        ("Whole body visible", poseEstimatorViewModel.isBodyFullyVisible)
    }

    private var upperChecklistItems: [(title: String, isValid: Bool)] {
        [
            wholeBodyItem,
            ("Back arm", poseEstimatorViewModel.upperBodyIsBackArmElevated),
            ("Front arm forward", poseEstimatorViewModel.upperBodyIsFrontArmForward),
            ("Front arm angled", poseEstimatorViewModel.upperBodyIsFrontArmSlightlyBent)
        ]
    }

    private var lowerChecklistItems: [(title: String, isValid: Bool)] {
        [
            wholeBodyItem,
            ("Legs open", poseEstimatorViewModel.lowerBodyIsStanceWide),
            ("Knees angled", poseEstimatorViewModel.lowerBodyAreKneesDeeplyBent)
        ]
    }

    private var activeSkeletonSegments: [PoseSkeletonOverlayView.Segment] {
        switch appState.currentEnGardeStep {
        case .upperBody:
            return upperSkeletonSegments
        case .lowerBody:
            return lowerSkeletonSegments
        case .fullPose, .completed:
            return upperSkeletonSegments + lowerSkeletonSegments
        }
    }

    private var upperSkeletonSegments: [PoseSkeletonOverlayView.Segment] {
        [
            .init(id: "u-neck-lshoulder", from: .neck, to: .leftShoulder, color: skeletonNeutralColor),
            .init(id: "u-neck-rshoulder", from: .neck, to: .rightShoulder, color: skeletonNeutralColor),
            .init(id: "u-shoulders", from: .leftShoulder, to: .rightShoulder, color: skeletonNeutralColor),

            .init(
                id: "u-front-shoulder-elbow",
                from: appState.isRightHanded ? .rightShoulder : .leftShoulder,
                to: appState.isRightHanded ? .rightElbow : .leftElbow,
                color: poseEstimatorViewModel.upperBodyIsFrontArmSlightlyBent ? skeletonPassColor : skeletonFailColor
            ),
            .init(
                id: "u-front-elbow-wrist",
                from: appState.isRightHanded ? .rightElbow : .leftElbow,
                to: appState.isRightHanded ? .rightWrist : .leftWrist,
                color: poseEstimatorViewModel.upperBodyIsFrontArmForward ? skeletonPassColor : skeletonFailColor
            ),
            .init(
                id: "u-back-shoulder-elbow",
                from: appState.isRightHanded ? .leftShoulder : .rightShoulder,
                to: appState.isRightHanded ? .leftElbow : .rightElbow,
                color: poseEstimatorViewModel.upperBodyIsBackArmElevated ? skeletonPassColor : skeletonFailColor
            ),
            .init(
                id: "u-back-elbow-wrist",
                from: appState.isRightHanded ? .leftElbow : .rightElbow,
                to: appState.isRightHanded ? .leftWrist : .rightWrist,
                color: poseEstimatorViewModel.upperBodyIsBackArmElevated ? skeletonPassColor : skeletonFailColor
            )
        ]
    }

    private var lowerSkeletonSegments: [PoseSkeletonOverlayView.Segment] {
        [
            .init(id: "l-neck-lhip", from: .neck, to: .leftHip, color: skeletonNeutralColor),
            .init(id: "l-neck-rhip", from: .neck, to: .rightHip, color: skeletonNeutralColor),
            .init(id: "l-hips", from: .leftHip, to: .rightHip, color: skeletonNeutralColor),
            .init(id: "l-lhip-lknee", from: .leftHip, to: .leftKnee, color: poseEstimatorViewModel.lowerBodyAreKneesDeeplyBent ? skeletonPassColor : skeletonFailColor),
            .init(id: "l-rhip-rknee", from: .rightHip, to: .rightKnee, color: poseEstimatorViewModel.lowerBodyAreKneesDeeplyBent ? skeletonPassColor : skeletonFailColor),
            .init(id: "l-lknee-lankle", from: .leftKnee, to: .leftAnkle, color: poseEstimatorViewModel.lowerBodyIsStanceWide ? skeletonPassColor : skeletonFailColor),
            .init(id: "l-rknee-rankle", from: .rightKnee, to: .rightAnkle, color: poseEstimatorViewModel.lowerBodyIsStanceWide ? skeletonPassColor : skeletonFailColor)
        ]
    }

    private var activeChecklistItems: [(title: String, isValid: Bool)] {
        switch appState.currentEnGardeStep {
        case .upperBody:
            return upperChecklistItems
        case .lowerBody:
            return lowerChecklistItems
        case .fullPose, .completed:
            return []
        }
    }

    private var showNextButton: Bool {
        if mode == .setup {
            return appState.isCameraSetupValidated
        }
        return poseEstimatorViewModel.didHoldTargetForRequiredDuration
    }

}
