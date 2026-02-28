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
                    statusIndicatorButton

                    if mode == .enGarde {
                        enGardeChecklistPanel
                            .padding(.leading, 12)
                    }

                    Spacer()
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

    private var statusIndicatorButton: some View {
        Button(action: {}) {
            Circle()
                .fill(statusDotColor)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .strokeBorder(.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: statusDotColor.opacity(0.6), radius: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(poseEstimatorViewModel.statusText)
    }

    private var holdProgressLine: some View {
        VStack(spacing: 0) {
            ProgressView(value: poseEstimatorViewModel.holdProgress)
                .tint(.green)
        }
        .progressViewStyle(.linear)
    }

    private var enGardeChecklistPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(activeChecklistItems, id: \.title) { item in
                checklistRow(title: item.title, isValid: item.isValid)
            }
        }
        .padding(14)
        .frame(maxWidth: 300, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func checklistRow(title: String, isValid: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isValid ? .green : .red)
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
        }
    }

    private var activeChecklistItems: [(title: String, isValid: Bool)] {
        let upperItems: [(String, Bool)] = [
            ("Back arm", poseEstimatorViewModel.upperBodyIsBackArmElevated),
            ("Front arm forward", poseEstimatorViewModel.upperBodyIsFrontArmForward),
            ("Front arm angled", poseEstimatorViewModel.upperBodyIsFrontArmSlightlyBent)
        ]

        let frontKneeAngle = appState.isRightHanded
            ? poseEstimatorViewModel.lowerBodyRightKneeAngle
            : poseEstimatorViewModel.lowerBodyLeftKneeAngle

        let lowerItems: [(String, Bool)] = [
            ("Legs open", poseEstimatorViewModel.lowerBodyIsStanceWide),
            ("Forward feet pointing forward", poseEstimatorViewModel.lowerBodyIsFrontLegForward),
            ("Forward knee angled", (120...140).contains(frontKneeAngle)),
            ("Back angled", poseEstimatorViewModel.lowerBodyIsBackLegPointingCamera)
        ]

        switch appState.currentEnGardeStep {
        case .upperBody:
            return upperItems
        case .lowerBody:
            return lowerItems
        case .fullPose, .completed:
            return upperItems + lowerItems
        }
    }

    private var showNextButton: Bool {
        if mode == .setup {
            return appState.isCameraSetupValidated
        }
        return poseEstimatorViewModel.didHoldTargetForRequiredDuration
    }

    private var cameraTitle: String {
        guard mode == .enGarde else { return "Camera Check" }

        switch appState.currentEnGardeStep {
        case .upperBody:
            return "En garde · Upper Body"
        case .lowerBody:
            return "En garde · Lower Body"
        case .fullPose:
            return "En garde · Full Pose"
        case .completed:
            return "En garde · Complete"
        }
    }

    private var statusDotColor: Color {
        switch poseEstimatorViewModel.setupState {
        case .searching:
            return .red
        case .inFrame:
            return .yellow
        case .success:
            return .green
        }
    }
}
