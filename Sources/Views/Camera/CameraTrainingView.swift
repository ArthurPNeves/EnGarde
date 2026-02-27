import SwiftUI

struct CameraTrainingView: View {
    let mode: PoseTrainingMode
    let nextButtonTitle: String
    let onComplete: () -> Void

    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @StateObject private var poseEstimatorViewModel = PoseEstimatorViewModel()
    @State private var didPlaySuccessSound = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(mode == .setup ? "Camera Check" : "En garde Check")
                .font(.largeTitle.weight(.bold))

            statusBanner

            CameraFeedPlaceholderView()

            if mode == .enGarde {
                enGardeChecklist
            }

            debugSimulationControls

            holdProgress

            if poseEstimatorViewModel.didHoldTargetForRequiredDuration {
                PrimaryActionButton(title: nextButtonTitle, symbolName: "arrow.right") {
                    onComplete()
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .frame(maxWidth: 960, alignment: .leading)
        .onAppear {
            poseEstimatorViewModel.start(mode: mode)
        }
        .onDisappear {
            poseEstimatorViewModel.stop()
        }
        .onChange(of: poseEstimatorViewModel.didHoldTargetForRequiredDuration) { newValue in
            guard newValue, !didPlaySuccessSound else { return }
            didPlaySuccessSound = true
            audioPlayerViewModel.playSuccessSound()
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

    private var debugSimulationControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Simulation")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Toggle("Whole body detected", isOn: $poseEstimatorViewModel.mockBodyFullyVisible)

            if mode == .enGarde {
                Toggle("En garde posture detected", isOn: $poseEstimatorViewModel.mockEnGardePoseCorrect)
            }
        }
        .toggleStyle(.switch)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
