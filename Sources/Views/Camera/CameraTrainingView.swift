import SwiftUI

struct CameraTrainingView: View {
    let mode: PoseTrainingMode
    let nextButtonTitle: String
    let onComplete: () -> Void

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @StateObject private var poseEstimatorViewModel = PoseEstimatorViewModel()

    var body: some View {
        ZStack {
            CameraPreviewView(session: poseEstimatorViewModel.captureSession)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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
            ("Forward feet pointing forward", poseEstimatorViewModel.lowerBodyIsFrontLegForward),
            ("Knees angled", poseEstimatorViewModel.lowerBodyAreKneesDeeplyBent)
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
