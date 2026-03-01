import SwiftUI
import Vision

struct CameraTrainingView: View {
    let mode: PoseTrainingMode
    let nextButtonTitle: String
    let onComplete: () -> Void

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @StateObject private var poseEstimatorViewModel = PoseEstimatorViewModel()

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

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    if mode == .enGarde {
                        enGardeChecklistOverlay
                    }
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

                if showNextButton {
                    HStack {
                        Spacer()
                        Button(action: onComplete) {
                            HStack(spacing: 8) {
                                Text(nextButtonTitle)
                                    .font(.subheadline.weight(.semibold))
                                Image(systemName: "arrow.right")
                                    .font(.subheadline.weight(.bold))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .foregroundStyle(.white)
                            .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                }

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

    private var holdProgressLine: some View {
        VStack(spacing: 0) {
            ProgressView(value: poseEstimatorViewModel.holdProgress)
                .tint(poseEstimatorViewModel.setupState == .success ? .green : .yellow)
                .shadow(
                    color: poseEstimatorViewModel.setupState == .inFrame ? .yellow.opacity(0.95) : .clear,
                    radius: 8,
                    x: 0,
                    y: 0
                )
        }
        .progressViewStyle(.linear)
    }

    @ViewBuilder
    private var enGardeChecklistOverlay: some View {
        if appState.currentEnGardeStep == .fullPose || appState.currentEnGardeStep == .completed {
            HStack(alignment: .top, spacing: 14) {
                checklistPanel(title: "Upper Body", items: upperChecklistItems)
                Spacer(minLength: 14)
                checklistPanel(title: "Lower Body", items: lowerChecklistItems)
            }
            .frame(maxWidth: .infinity, alignment: .top)
        } else {
            checklistPanel(title: nil, items: activeChecklistItems)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private func checklistPanel(title: String?, items: [(title: String, isValid: Bool)]) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            if let title {
                Text(title)
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(.white)
                    .padding(.bottom, 6)
            }

            ForEach(items, id: \.title) { item in
                checklistRow(title: item.title, isValid: item.isValid)
            }
        }
        .padding(30)
        .frame(maxWidth: 520, alignment: .leading)
    }

    @ViewBuilder
    private func checklistRow(title: String, isValid: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(isValid ? .green : .red)
            Text(title)
                .font(.title.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
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
