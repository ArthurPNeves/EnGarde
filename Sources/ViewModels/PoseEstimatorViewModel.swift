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
    @Published private(set) var isUpperBodyValid: Bool = false
    @Published private(set) var isLowerBodyValid: Bool = false
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

    private var currentStep: EnGardeStep {
        appState?.currentEnGardeStep ?? .upperBody
    }

    private var frontWrist: VNHumanBodyPoseObservation.JointName {
        (appState?.isRightHanded ?? true) ? .rightWrist : .leftWrist
    }

    private var backWrist: VNHumanBodyPoseObservation.JointName {
        (appState?.isRightHanded ?? true) ? .leftWrist : .rightWrist
    }

    private var frontElbow: VNHumanBodyPoseObservation.JointName {
        (appState?.isRightHanded ?? true) ? .rightElbow : .leftElbow
    }

    private var backElbow: VNHumanBodyPoseObservation.JointName {
        (appState?.isRightHanded ?? true) ? .leftElbow : .rightElbow
    }

    private var frontShoulder: VNHumanBodyPoseObservation.JointName {
        (appState?.isRightHanded ?? true) ? .rightShoulder : .leftShoulder
    }

    private var backShoulder: VNHumanBodyPoseObservation.JointName {
        (appState?.isRightHanded ?? true) ? .leftShoulder : .rightShoulder
    }

    var statusText: String {
        switch setupState {
        case .searching:
            if mode == .setup {
                return "Position yourself in frame"
            }
            switch currentStep {
            case .upperBody:
                return "Adjust front and back arms"
            case .lowerBody:
                return "Adjust knee bend and stance width"
            case .fullPose:
                return "Combine upper and lower body form"
            case .completed:
                return "En garde progression complete"
            }
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
                    self.applyFrameEvaluation(isValid: false, upperValid: false, lowerValid: false, fullVisible: false)
                    return
                }

                if self.mode == .setup {
                    let wholeBodyVisible = self.hasRequiredBoundaryJoints(in: observation)
                    self.applyFrameEvaluation(
                        isValid: wholeBodyVisible,
                        upperValid: false,
                        lowerValid: false,
                        fullVisible: wholeBodyVisible
                    )
                } else {
                    let upper = self.validateUpperBody(observation)
                    let lower = self.validateLowerBody(observation)
                    let full = self.validateFullPose(observation)

                    let shouldPass: Bool
                    switch self.currentStep {
                    case .upperBody:
                        shouldPass = upper
                    case .lowerBody:
                        shouldPass = lower
                    case .fullPose:
                        shouldPass = full
                    case .completed:
                        shouldPass = true
                    }

                    self.applyFrameEvaluation(
                        isValid: shouldPass,
                        upperValid: upper,
                        lowerValid: lower,
                        fullVisible: self.hasRequiredBoundaryJoints(in: observation)
                    )
                }
            } catch {
                self.applyFrameEvaluation(isValid: false, upperValid: false, lowerValid: false, fullVisible: false)
            }
        }
    }

    private func validateUpperBody(_ observation: VNHumanBodyPoseObservation) -> Bool {
        guard let points = try? observation.recognizedPoints(.all) else {
            return false
        }

        let confidence: Float = 0.3

        guard
            let frontWristPoint = points[frontWrist],
            let frontElbowPoint = points[frontElbow],
            let frontShoulderPoint = points[frontShoulder],
            let backWristPoint = points[backWrist],
            let backElbowPoint = points[backElbow],
            let backShoulderPoint = points[backShoulder],
            frontWristPoint.confidence > confidence,
            frontElbowPoint.confidence > confidence,
            frontShoulderPoint.confidence > confidence,
            backWristPoint.confidence > confidence,
            backElbowPoint.confidence > confidence,
            backShoulderPoint.confidence > confidence
        else {
            return false
        }

        let frontDirectionX = frontWristPoint.location.x - frontShoulderPoint.location.x
        let isFrontArmForward = (appState?.isRightHanded ?? true) ? (frontDirectionX > 0.06) : (frontDirectionX < -0.06)

        let frontArmAngle = angleDegrees(a: frontShoulderPoint.location, b: frontElbowPoint.location, c: frontWristPoint.location)
        let isFrontArmSlightlyBent = (frontArmAngle > 145 && frontArmAngle < 178)

        let isBackArmElevated = backWristPoint.location.y > (backShoulderPoint.location.y - 0.05)

        return isFrontArmForward && isFrontArmSlightlyBent && isBackArmElevated
    }

    private func validateLowerBody(_ observation: VNHumanBodyPoseObservation) -> Bool {
        guard let points = try? observation.recognizedPoints(.all) else {
            return false
        }

        let confidence: Float = 0.3
        guard
            let leftHip = points[.leftHip],
            let rightHip = points[.rightHip],
            let leftKnee = points[.leftKnee],
            let rightKnee = points[.rightKnee],
            let leftAnkle = points[.leftAnkle],
            let rightAnkle = points[.rightAnkle],
            let leftShoulder = points[.leftShoulder],
            let rightShoulder = points[.rightShoulder],
            leftHip.confidence > confidence,
            rightHip.confidence > confidence,
            leftKnee.confidence > confidence,
            rightKnee.confidence > confidence,
            leftAnkle.confidence > confidence,
            rightAnkle.confidence > confidence,
            leftShoulder.confidence > confidence,
            rightShoulder.confidence > confidence
        else {
            return false
        }

        let leftKneeAngle = angleDegrees(a: leftHip.location, b: leftKnee.location, c: leftAnkle.location)
        let rightKneeAngle = angleDegrees(a: rightHip.location, b: rightKnee.location, c: rightAnkle.location)

        let kneesDeeplyBent = (120...140).contains(leftKneeAngle) && (120...140).contains(rightKneeAngle)

        let ankleDistance = distance(leftAnkle.location, rightAnkle.location)
        let shoulderDistance = distance(leftShoulder.location, rightShoulder.location)
        let stanceWide = ankleDistance > shoulderDistance

        return kneesDeeplyBent && stanceWide
    }

    private func validateFullPose(_ observation: VNHumanBodyPoseObservation) -> Bool {
        validateUpperBody(observation) && validateLowerBody(observation)
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

    private func applyFrameEvaluation(isValid: Bool, upperValid: Bool, lowerValid: Bool, fullVisible: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.updateFrameVisibilityOnMain(
                isValid: isValid,
                upperValid: upperValid,
                lowerValid: lowerValid,
                bodyVisible: fullVisible
            )
        }
    }

    @MainActor
    private func updateFrameVisibilityOnMain(
        isValid: Bool,
        upperValid: Bool,
        lowerValid: Bool,
        bodyVisible: Bool
    ) {
        guard setupState != .success else { return }

        isBodyFullyVisible = bodyVisible
        isUpperBodyValid = upperValid
        isLowerBodyValid = lowerValid

        if mode == .enGarde {
            isEnGardePoseCorrect = (currentStep == .fullPose) ? (upperValid && lowerValid) : isValid
        }

        guard isValid else {
            setupState = .searching
            holdProgress = 0
            holdStartDate = nil
            didHoldTargetForRequiredDuration = false
            if mode == .setup {
                appState?.isCameraSetupValidated = false
            }
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
        if mode == .setup {
            appState?.isCameraSetupValidated = true
        }
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
        isUpperBodyValid = false
        isLowerBodyValid = false
        setupState = .searching
        holdProgress = 0
        didHoldTargetForRequiredDuration = false
        holdStartDate = nil
        hasAppliedSuccessSideEffects = false
        errorMessage = nil
        appState?.isCameraSetupValidated = false
        invalidateHoldTimer()
    }

    private func angleDegrees(a: CGPoint, b: CGPoint, c: CGPoint) -> Double {
        let ab = CGVector(dx: a.x - b.x, dy: a.y - b.y)
        let cb = CGVector(dx: c.x - b.x, dy: c.y - b.y)

        let dot = (ab.dx * cb.dx) + (ab.dy * cb.dy)
        let magAB = sqrt((ab.dx * ab.dx) + (ab.dy * ab.dy))
        let magCB = sqrt((cb.dx * cb.dx) + (cb.dy * cb.dy))
        guard magAB > 0, magCB > 0 else { return 180 }

        let cosValue = max(-1.0, min(1.0, dot / (magAB * magCB)))
        return acos(cosValue) * 180 / .pi
    }

    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt((dx * dx) + (dy * dy))
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
