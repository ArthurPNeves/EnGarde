import AVFoundation
import CoreMedia
import Foundation
import Vision

enum PoseTrainingMode {
    case setup
    case enGarde
}

enum SetupState {
    case searching
    case inFrame
    case success
}

enum PoseStatusStyle {
    case neutral
    case success
    case warning
}

final class PoseEstimatorViewModel: NSObject, ObservableObject {
    @Published var mode: PoseTrainingMode = .setup
    @Published private(set) var captureSession = AVCaptureSession()
    @Published private(set) var setupState: SetupState = .searching
    @Published private(set) var isBodyFullyVisible: Bool = false
    @Published var isEnGardePoseCorrect: Bool = false
    @Published private(set) var holdProgress: Double = 0
    @Published private(set) var didHoldTargetForRequiredDuration: Bool = false
    @Published private(set) var errorMessage: String?

    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoOutputQueue = DispatchQueue(label: "engarde.pose.video-output", qos: .userInitiated)
    private let visionQueue = DispatchQueue(label: "engarde.pose.vision", qos: .userInitiated)

    private var isSessionConfigured = false
    private var holdTimer: Timer?
    private var holdStartDate: Date?
    private var hasAppliedSuccessSideEffects = false
    private let holdDuration: TimeInterval = 5.0

    private weak var appState: AppState?
    private weak var audioPlayerViewModel: AudioPlayerViewModel?

    var statusText: String {
        switch setupState {
        case .searching:
            return "Position yourself in frame"
        case .inFrame:
            return "Body detected. Hold steady for 5 seconds."
        case .success:
            return "Setup complete. Great work."
        }
    }

    var statusStyle: PoseStatusStyle {
        switch setupState {
        case .searching:
            return .warning
        case .inFrame, .success:
            return .success
        }
    }

    func configureDependencies(appState: AppState, audioPlayerViewModel: AudioPlayerViewModel) {
        self.appState = appState
        self.audioPlayerViewModel = audioPlayerViewModel
    }

    @MainActor
    func start(mode: PoseTrainingMode) {
        self.mode = mode
        resetTrackingState()
        requestCameraPermissionAndStartSession()
    }

    func stop() {
        DispatchQueue.main.async { [weak self] in
            self?.invalidateHoldTimer()
        }

        if captureSession.isRunning {
            videoOutputQueue.async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }

    private func requestCameraPermissionAndStartSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { [weak self] in
                self?.configureCaptureSessionIfNeeded()
                self?.startCaptureSession()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.errorMessage = nil
                        self?.configureCaptureSessionIfNeeded()
                        self?.startCaptureSession()
                    } else {
                        Task { @MainActor in
                            self?.setPermissionDeniedState()
                        }
                    }
                }
            }
        case .denied, .restricted:
            Task { @MainActor in
                self?.setPermissionDeniedState()
            }
        @unknown default:
            Task { @MainActor in
                self?.setPermissionDeniedState()
            }
        }
    }

    private func configureCaptureSessionIfNeeded() {
        guard !isSessionConfigured else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        do {
            guard let camera = AVCaptureDevice.default(for: .video) else {
                errorMessage = "No camera found on this Mac."
                captureSession.commitConfiguration()
                return
            }

            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)

            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            isSessionConfigured = true
            errorMessage = nil
        } catch {
            errorMessage = "Unable to configure camera: \(error.localizedDescription)"
        }

        captureSession.commitConfiguration()
    }

    private func startCaptureSession() {
        guard isSessionConfigured, !captureSession.isRunning else { return }
        videoOutputQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    @MainActor
    private func setPermissionDeniedState() {
        errorMessage = "Camera permission denied. Enable camera access in System Settings."
        isBodyFullyVisible = false
        setupState = .searching
        holdProgress = 0
        didHoldTargetForRequiredDuration = false
        appState?.isCameraSetupValidated = false
        invalidateHoldTimer()
    }

    private func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        visionQueue.async { [weak self] in
            guard let self else { return }
            let request = VNDetectHumanBodyPoseRequest()
            let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])

            do {
                try handler.perform([request])

                guard
                    let observation = (request.results as? [VNHumanBodyPoseObservation])?.first
                else {
                    self.applyFrameVisibility(false)
                    return
                }

                let wholeBodyVisible = self.hasRequiredBoundaryJoints(in: observation)
                self.applyFrameVisibility(wholeBodyVisible)
            } catch {
                self.applyFrameVisibility(false)
            }
        }
    }

    private func hasRequiredBoundaryJoints(in observation: VNHumanBodyPoseObservation) -> Bool {
        guard let points = try? observation.recognizedPoints(.all) else {
            return false
        }

        let minimumConfidence: Float = 0.3

        let hasNose = hasPoint(.nose, points: points, minimumConfidence: minimumConfidence)
        let hasLeftAnkle = hasPoint(.leftAnkle, points: points, minimumConfidence: minimumConfidence)
        let hasRightAnkle = hasPoint(.rightAnkle, points: points, minimumConfidence: minimumConfidence)
        let hasLeftWrist = hasPoint(.leftWrist, points: points, minimumConfidence: minimumConfidence)
        let hasRightWrist = hasPoint(.rightWrist, points: points, minimumConfidence: minimumConfidence)

        return hasNose && hasLeftAnkle && hasRightAnkle && hasLeftWrist && hasRightWrist
    }

    private func hasPoint(
        _ joint: VNHumanBodyPoseObservation.JointName,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        minimumConfidence: Float
    ) -> Bool {
        guard let point = points[joint] else {
            return false
        }
        return point.confidence > minimumConfidence
    }

    private func applyFrameVisibility(_ isVisible: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.updateFrameVisibilityOnMain(isVisible)
        }
    }

    @MainActor
    private func updateFrameVisibilityOnMain(_ isVisible: Bool) {
        guard setupState != .success else { return }

        isBodyFullyVisible = isVisible

        guard isVisible else {
            setupState = .searching
            holdProgress = 0
            holdStartDate = nil
            didHoldTargetForRequiredDuration = false
            appState?.isCameraSetupValidated = false
            invalidateHoldTimer()
            return
        }

        setupState = .inFrame
        startHoldTimerIfNeeded()
    }

    @MainActor
    private func startHoldTimerIfNeeded() {
        if holdStartDate == nil {
            holdStartDate = Date()
        }

        guard holdTimer == nil else { return }

        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tickHoldTimer()
            }
        }
    }

    @MainActor
    private func tickHoldTimer() {
        guard setupState == .inFrame else {
            invalidateHoldTimer()
            return
        }

        guard let holdStartDate else {
            holdStartDate = Date()
            return
        }

        let elapsed = Date().timeIntervalSince(holdStartDate)
        holdProgress = min(elapsed / holdDuration, 1.0)

        if elapsed >= holdDuration {
            markSetupSuccess()
        }
    }

    @MainActor
    private func markSetupSuccess() {
        setupState = .success
        didHoldTargetForRequiredDuration = true
        holdProgress = 1
        appState?.isCameraSetupValidated = true
        invalidateHoldTimer()

        guard !hasAppliedSuccessSideEffects else { return }
        hasAppliedSuccessSideEffects = true
        audioPlayerViewModel?.playSuccessSound()
    }

    @MainActor
    private func invalidateHoldTimer() {
        holdTimer?.invalidate()
        holdTimer = nil
    }

    @MainActor
    private func resetTrackingState() {
        isBodyFullyVisible = false
        isEnGardePoseCorrect = false
        setupState = .searching
        holdProgress = 0
        didHoldTargetForRequiredDuration = false
        holdStartDate = nil
        hasAppliedSuccessSideEffects = false
        errorMessage = nil
        appState?.isCameraSetupValidated = false
        invalidateHoldTimer()
    }
}

extension PoseEstimatorViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        _ = output
        _ = connection
        processSampleBuffer(sampleBuffer)
    }
}
