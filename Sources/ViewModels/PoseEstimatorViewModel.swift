import AVFoundation
import Combine
import CoreMedia
import Foundation
import Vision

enum PoseTrainingMode {
    case setup
    case enGarde
}

enum PoseStatusStyle {
    case neutral
    case success
    case warning
}

@MainActor
final class PoseEstimatorViewModel: ObservableObject {
    @Published var mode: PoseTrainingMode = .setup

    @Published var isBodyFullyVisible: Bool = false
    @Published var isEnGardePoseCorrect: Bool = false

    @Published var holdProgress: Double = 0
    @Published var didHoldTargetForRequiredDuration: Bool = false

    // Mock controls for UI scaffolding. Replace these with real Vision output updates.
    @Published var mockBodyFullyVisible: Bool = false {
        didSet { evaluateTargetState() }
    }

    @Published var mockEnGardePoseCorrect: Bool = false {
        didSet { evaluateTargetState() }
    }

    private var holdStartDate: Date?
    private var holdTimer: AnyCancellable?

    var statusText: String {
        if didHoldTargetForRequiredDuration {
            return "Great work. You can continue."
        }

        switch mode {
        case .setup:
            return isBodyFullyVisible ? "Body detected. Hold steady." : "Position yourself in frame"
        case .enGarde:
            if isBodyFullyVisible && isEnGardePoseCorrect {
                return "En garde posture detected. Hold steady."
            }
            return "Adjust feet, knees, and weapon arm"
        }
    }

    var statusStyle: PoseStatusStyle {
        if didHoldTargetForRequiredDuration {
            return .success
        }

        return targetConditionMet ? .success : .warning
    }

    private var targetConditionMet: Bool {
        switch mode {
        case .setup:
            return isBodyFullyVisible
        case .enGarde:
            return isBodyFullyVisible && isEnGardePoseCorrect
        }
    }

    func start(mode: PoseTrainingMode) {
        self.mode = mode
        resetStateForNewMode()
        setupVisionPipeline()
        startMockCapture()
        startHoldTimer()
    }

    func stop() {
        stopHoldTimer()
        stopCapture()
    }

    func setupVisionPipeline() {
        // Prepare VNDetectHumanBodyPoseRequest instances and camera pipeline bindings here.
    }

    func startMockCapture() {
        // Camera stream is mocked for now; in production this should start AVCaptureSession.
    }

    func stopCapture() {
        // Stop AVCaptureSession and cleanup resources here.
    }

    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        let request = VNDetectHumanBodyPoseRequest { [weak self] request, _ in
            guard
                let self,
                let observations = request.results as? [VNHumanBodyPoseObservation],
                let first = observations.first
            else {
                Task { @MainActor in
                    self?.updatePoseDetection(bodyVisible: false, enGardePoseCorrect: false)
                }
                return
            }

            Task { @MainActor in
                self.handleObservation(first)
            }
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        try? handler.perform([request])
    }

    func handleObservation(_ observation: VNHumanBodyPoseObservation) {
        // Full-body visibility can be inferred by checking required joints confidence.
        let bodyVisible = estimateFullBodyVisibility(from: observation)

        // En garde posture validation will later include specific joint-angle rules.
        let enGardePose = estimateEnGardePose(from: observation)

        updatePoseDetection(bodyVisible: bodyVisible, enGardePoseCorrect: enGardePose)
    }

    func estimateFullBodyVisibility(from observation: VNHumanBodyPoseObservation) -> Bool {
        _ = observation
        // TODO: Implement top-of-head through feet visibility checks.
        return mockBodyFullyVisible
    }

    func estimateEnGardePose(from observation: VNHumanBodyPoseObservation) -> Bool {
        _ = observation
        // TODO: Implement knee, foot, and elbow angle constraints.
        return mockEnGardePoseCorrect
    }

    private func startHoldTimer() {
        holdTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.evaluateTargetState()
            }
    }

    private func stopHoldTimer() {
        holdTimer?.cancel()
        holdTimer = nil
    }

    private func resetStateForNewMode() {
        isBodyFullyVisible = false
        isEnGardePoseCorrect = false
        holdProgress = 0
        didHoldTargetForRequiredDuration = false
        holdStartDate = nil
        mockBodyFullyVisible = false
        mockEnGardePoseCorrect = false
    }

    private func updatePoseDetection(bodyVisible: Bool, enGardePoseCorrect: Bool) {
        isBodyFullyVisible = bodyVisible
        isEnGardePoseCorrect = enGardePoseCorrect
    }

    private func evaluateTargetState() {
        if didHoldTargetForRequiredDuration {
            return
        }

        isBodyFullyVisible = mockBodyFullyVisible
        if mode == .enGarde {
            isEnGardePoseCorrect = mockEnGardePoseCorrect
        } else {
            isEnGardePoseCorrect = false
        }

        guard targetConditionMet else {
            holdStartDate = nil
            holdProgress = 0
            return
        }

        if holdStartDate == nil {
            holdStartDate = Date()
        }

        guard let holdStartDate else { return }

        let heldDuration = Date().timeIntervalSince(holdStartDate)
        holdProgress = min(heldDuration / 5.0, 1.0)

        if heldDuration >= 5.0 {
            didHoldTargetForRequiredDuration = true
            holdProgress = 1.0
        }
    }
}
