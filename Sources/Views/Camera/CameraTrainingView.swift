import SwiftUI

struct CameraTrainingView: View {
    let mode: PoseTrainingMode
    let nextButtonTitle: String
    let onComplete: () -> Void

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @StateObject private var poseEstimatorViewModel = PoseEstimatorViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(mode == .setup ? "Camera Check" : "En garde Check")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 20) {
                statusBanner

                CameraPreviewView(session: poseEstimatorViewModel.captureSession)
                    .frame(maxWidth: .infinity, minHeight: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(.white.opacity(0.16), lineWidth: 1)
                    )

                if let errorMessage = poseEstimatorViewModel.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                if mode == .enGarde {
                    enGardeChecklist
                }

                holdProgress

                if showNextButton {
                    PrimaryActionButton(title: nextButtonTitle, symbolName: "arrow.right") {
                        onComplete()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .frame(maxWidth: 960)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            poseEstimatorViewModel.configureDependencies(appState: appState, audioPlayerViewModel: audioPlayerViewModel)
            poseEstimatorViewModel.start(mode: mode)
        }
        .onDisappear {
            poseEstimatorViewModel.stop()
        }
    }

    private var statusBanner: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(poseEstimatorViewModel.statusText)
                .font(.headline)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var holdProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hold timer")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ProgressView(value: poseEstimatorViewModel.holdProgress)
                .tint(.green)

            Text("Hold correct form for 5 continuous seconds")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var enGardeChecklist: some View {
        VStack(alignment: .leading, spacing: 10) {
            checklistRow(
                title: "Full body visible",
                isValid: poseEstimatorViewModel.isBodyFullyVisible
            )
            checklistRow(
                title: "En garde alignment (knees, feet, elbow)",
                isValid: poseEstimatorViewModel.isEnGardePoseCorrect
            )
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private func checklistRow(title: String, isValid: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isValid ? .green : .red)
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private var showNextButton: Bool {
        if mode == .setup {
            return appState.isCameraSetupValidated
        }
        return poseEstimatorViewModel.didHoldTargetForRequiredDuration
    }

    private var statusColor: Color {
        switch poseEstimatorViewModel.statusStyle {
        case .neutral:
            return .secondary
        case .success:
            return .green
        case .warning:
            return .red
        }
    }
}
