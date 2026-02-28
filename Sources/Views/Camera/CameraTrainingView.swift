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
            Text(cameraTitle)
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
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
                        validationAndDebugSection
                    }

                    holdProgress

                    if showNextButton {
                        PrimaryActionButton(title: nextButtonTitle, symbolName: "arrow.right") {
                            onComplete()
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
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
                title: "Upper body validated",
                isValid: poseEstimatorViewModel.isUpperBodyValid
            )
            checklistRow(
                title: "Lower body validated",
                isValid: poseEstimatorViewModel.isLowerBodyValid
            )
            checklistRow(
                title: "Full body visible",
                isValid: poseEstimatorViewModel.isBodyFullyVisible
            )
            checklistRow(
                title: "Current step passed",
                isValid: poseEstimatorViewModel.isEnGardePoseCorrect
            )
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private var validationAndDebugSection: some View {
        if showUpperBodyDebugPanel || showLowerBodyDebugPanel {
            HStack(alignment: .top, spacing: 12) {
                enGardeChecklist
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                debugPanel
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        } else {
            enGardeChecklist
        }
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

    private var showUpperBodyDebugPanel: Bool {
        mode == .enGarde && appState.currentEnGardeStep == .upperBody
    }

    private var showLowerBodyDebugPanel: Bool {
        mode == .enGarde && appState.currentEnGardeStep == .lowerBody
    }

    @ViewBuilder
    private var debugPanel: some View {
        if showUpperBodyDebugPanel {
            upperBodyDebugPanel
        } else if showLowerBodyDebugPanel {
            lowerBodyDebugPanel
        }
    }

    private var upperBodyDebugPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upper Body Metrics (updates every 3s)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            metricRow(
                label: "frontDirectionX",
                value: String(format: "%.3f", poseEstimatorViewModel.upperBodyFrontDirectionX),
                passed: poseEstimatorViewModel.upperBodyIsFrontArmForward
            )

            metricRow(
                label: "frontArmAngle",
                value: String(format: "%.1f°", poseEstimatorViewModel.upperBodyFrontArmAngle),
                passed: poseEstimatorViewModel.upperBodyIsFrontArmSlightlyBent
            )

            metricRow(
                label: "backWristLiftDelta",
                value: String(format: "%.3f", poseEstimatorViewModel.upperBodyBackWristLiftDelta),
                passed: poseEstimatorViewModel.upperBodyIsBackArmElevated
            )

            if let updatedAt = poseEstimatorViewModel.upperBodyMetricsUpdatedAt {
                Text("Last update: \(updatedAt.formatted(date: .omitted, time: .standard))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var lowerBodyDebugPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lower Body Metrics (updates every 3s)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            metricRow(
                label: "leftKneeAngle",
                value: String(format: "%.1f°", poseEstimatorViewModel.lowerBodyLeftKneeAngle),
                passed: poseEstimatorViewModel.lowerBodyAreKneesDeeplyBent
            )

            metricRow(
                label: "rightKneeAngle",
                value: String(format: "%.1f°", poseEstimatorViewModel.lowerBodyRightKneeAngle),
                passed: poseEstimatorViewModel.lowerBodyAreKneesDeeplyBent
            )

            metricRow(
                label: "ankleDistance",
                value: String(format: "%.3f", poseEstimatorViewModel.lowerBodyAnkleDistance),
                passed: poseEstimatorViewModel.lowerBodyIsStanceWide
            )

            metricRow(
                label: "shoulderDistance",
                value: String(format: "%.3f", poseEstimatorViewModel.lowerBodyShoulderDistance),
                passed: poseEstimatorViewModel.lowerBodyIsStanceWide
            )

            if let updatedAt = poseEstimatorViewModel.lowerBodyMetricsUpdatedAt {
                Text("Last update: \(updatedAt.formatted(date: .omitted, time: .standard))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private func metricRow(label: String, value: String, passed: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(passed ? .green : .red)

            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.primary)
        }
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
