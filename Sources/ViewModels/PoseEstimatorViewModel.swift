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
    @Published private(set) var upperBodyFrontDirectionX: Double = 0
    @Published private(set) var upperBodyIsFrontArmForward: Bool = false
    @Published private(set) var upperBodyFrontArmAngle: Double = 0
    @Published private(set) var upperBodyIsFrontArmSlightlyBent: Bool = false
    @Published private(set) var upperBodyBackWristLiftDelta: Double = 0
    @Published private(set) var upperBodyIsBackArmElevated: Bool = false
    @Published private(set) var upperBodyMetricsUpdatedAt: Date?
    @Published private(set) var lowerBodyLeftKneeAngle: Double = 0
    @Published private(set) var lowerBodyRightKneeAngle: Double = 0
    @Published private(set) var lowerBodyAreKneesDeeplyBent: Bool = false
    @Published private(set) var lowerBodyAnkleDistance: Double = 0
    @Published private(set) var lowerBodyShoulderDistance: Double = 0
    @Published private(set) var lowerBodyIsStanceWide: Bool = false
    @Published private(set) var lowerBodyFrontLegDirectionX: Double = 0
    @Published private(set) var lowerBodyIsFrontLegForward: Bool = false
    @Published private(set) var lowerBodyBackLegDirectionX: Double = 0
    @Published private(set) var lowerBodyIsBackLegPointingCamera: Bool = false
    @Published private(set) var lowerBodyMetricsUpdatedAt: Date?
    @Published private(set) var activeEnGardeStep: EnGardeStep = .upperBody
    @Published private(set) var isRightHandedStance: Bool = true
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
    private var nextUpperBodyDebugPublishDate: Date = .distantPast
    private var nextLowerBodyDebugPublishDate: Date = .distantPast

    private weak var appState: AppState?
    private weak var audioPlayerViewModel: AudioPlayerViewModel?

    private var currentStep: EnGardeStep {
        activeEnGardeStep
    }

    private var frontWrist: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .rightWrist : .leftWrist
    }

    private var backWrist: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .leftWrist : .rightWrist
    }

    private var frontElbow: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .rightElbow : .leftElbow
    }

    private var backElbow: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .leftElbow : .rightElbow
    }

    private var frontShoulder: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .rightShoulder : .leftShoulder
    }

    private var backShoulder: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .leftShoulder : .rightShoulder
    }

    private var frontKnee: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .rightKnee : .leftKnee
    }

    private var backKnee: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .leftKnee : .rightKnee
    }

    private var frontAnkle: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .rightAnkle : .leftAnkle
    }

    private var backAnkle: VNHumanBodyPoseObservation.JointName {
        isRightHandedStance ? .leftAnkle : .rightAnkle
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

    @MainActor
    func configureDependencies(appState: AppState, audioPlayerViewModel: AudioPlayerViewModel) {
        self.appState = appState
        self.audioPlayerViewModel = audioPlayerViewModel
        syncWizardConfigurationFromAppState()
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
                self.setPermissionDeniedState()
            }
        @unknown default:
            Task { @MainActor in
                self.setPermissionDeniedState()
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

                    let step = self.currentStep
                    let shouldPass: Bool
                    switch step {
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

        let frontDirectionX = -(frontWristPoint.location.x - frontShoulderPoint.location.x)
        let isFrontArmForward = isRightHandedStance ? (frontDirectionX > 0.06) : (frontDirectionX < -0.06)

        let frontArmAngle = angleDegrees(a: frontShoulderPoint.location, b: frontElbowPoint.location, c: frontWristPoint.location)
        let isFrontArmSlightlyBent = (frontArmAngle > 90 && frontArmAngle < 110)

        let isBackArmElevated = backWristPoint.location.y > (backShoulderPoint.location.y - 0.05)

        let backWristLiftDelta = backWristPoint.location.y - (backShoulderPoint.location.y - 0.05)
        maybePublishUpperBodyDebugMetrics(
            frontDirectionX: frontDirectionX,
            isFrontArmForward: isFrontArmForward,
            frontArmAngle: frontArmAngle,
            isFrontArmSlightlyBent: isFrontArmSlightlyBent,
            backWristLiftDelta: backWristLiftDelta,
            isBackArmElevated: isBackArmElevated
        )

        return isFrontArmForward && isFrontArmSlightlyBent && isBackArmElevated
    }

    private func validateLowerBody(_ observation: VNHumanBodyPoseObservation) -> Bool {
        guard let points = try? observation.recognizedPoints(.all) else {
            return false
        }

        // Tunables for live testing.
        let shinVerticalTolerance: CGFloat = 0.05
        let minimumStanceWidth: CGFloat = 0.18

        let confidence: Float = 0.3
        guard
            let leftHip = points[.leftHip],
            let rightHip = points[.rightHip],
            let leftKnee = points[.leftKnee],
            let rightKnee = points[.rightKnee],
            let leftAnkle = points[.leftAnkle],
            let rightAnkle = points[.rightAnkle],
            let frontKneePoint = points[frontKnee],
            let backKneePoint = points[backKnee],
            let frontAnklePoint = points[frontAnkle],
            let backAnklePoint = points[backAnkle],
            let leftShoulder = points[.leftShoulder],
            let rightShoulder = points[.rightShoulder],
            leftHip.confidence > confidence,
            rightHip.confidence > confidence,
            leftKnee.confidence > confidence,
            rightKnee.confidence > confidence,
            leftAnkle.confidence > confidence,
            rightAnkle.confidence > confidence,
            frontKneePoint.confidence > confidence,
            backKneePoint.confidence > confidence,
            frontAnklePoint.confidence > confidence,
            backAnklePoint.confidence > confidence,
            leftShoulder.confidence > confidence,
            rightShoulder.confidence > confidence
        else {
            return false
        }

        let leftKneeAngle = angleDegrees(a: leftHip.location, b: leftKnee.location, c: leftAnkle.location)
        let rightKneeAngle = angleDegrees(a: rightHip.location, b: rightKnee.location, c: rightAnkle.location)

        let kneesDeeplyBent = (120...160).contains(leftKneeAngle) && (120...172).contains(rightKneeAngle)

        let ankleDistance = distance(leftAnkle.location, rightAnkle.location)
        let shoulderDistance = distance(leftShoulder.location, rightShoulder.location)
        let stanceWide = ankleDistance > shoulderDistance

        // Plumb-line test: front shin should be near vertical (knee stacked over ankle).
        let frontShinHorizontalOffset = abs(frontAnklePoint.location.x - frontKneePoint.location.x)
        let isFrontShinVertical = frontShinHorizontalOffset <= shinVerticalTolerance

        // Kept as debug-only metric.
        let backLegDirectionX = backAnklePoint.location.x - backKneePoint.location.x
        let isBackLegPointingCamera = abs(backLegDirectionX) <= 0.05

        maybePublishLowerBodyDebugMetrics(
            leftKneeAngle: leftKneeAngle,
            rightKneeAngle: rightKneeAngle,
            kneesDeeplyBent: kneesDeeplyBent,
            ankleDistance: ankleDistance,
            shoulderDistance: shoulderDistance,
            stanceWide: stanceWide,
            frontLegDirectionX: frontShinHorizontalOffset,
            isFrontLegForward: isFrontShinVertical,
            backLegDirectionX: backLegDirectionX,
            isBackLegPointingCamera: isBackLegPointingCamera
        )

        let isLowerBodyCorrect = isFrontShinVertical && kneesDeeplyBent && stanceWide
        return isLowerBodyCorrect
    }

    private func validateFullPose(_ observation: VNHumanBodyPoseObservation) -> Bool {
        validateUpperBody(observation) && validateLowerBody(observation)
    }

    private func hasRequiredBoundaryJoints(in observation: VNHumanBodyPoseObservation) -> Bool {
        guard let points = try? observation.recognizedPoints(.all) else {
            return false
        }

        let minimumConfidence: Float = 0.3

        let hasNose = hasPoint(.nose, points: points, minimumConfidence: 0.4)
        let hasLeftAnkle = hasReliableAnkle(
            ankle: .leftAnkle,
            knee: .leftKnee,
            points: points,
            minimumConfidence: max(minimumConfidence, 0.45)
        )
        let hasRightAnkle = hasReliableAnkle(
            ankle: .rightAnkle,
            knee: .rightKnee,
            points: points,
            minimumConfidence: max(minimumConfidence, 0.45)
        )
        let hasLeftWrist = hasPoint(.leftWrist, points: points, minimumConfidence: minimumConfidence)
        let hasRightWrist = hasPoint(.rightWrist, points: points, minimumConfidence: minimumConfidence)

        // Backend boundary check: nose + wrists + both reliable ankles.
        return hasNose && hasLeftAnkle && hasRightAnkle && hasLeftWrist && hasRightWrist
    }

    private func hasReliableAnkle(
        ankle: VNHumanBodyPoseObservation.JointName,
        knee: VNHumanBodyPoseObservation.JointName,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        minimumConfidence: Float
    ) -> Bool {
        guard
            let anklePoint = points[ankle],
            let kneePoint = points[knee],
            anklePoint.confidence > minimumConfidence,
            kneePoint.confidence > 0.3
        else {
            return false
        }

        // Reduce shin-as-ankle false positives: true ankle should be clearly below its knee.
        let requiredVerticalGap: CGFloat = 0.035
        return anklePoint.location.y < (kneePoint.location.y - requiredVerticalGap)
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
        syncWizardConfigurationFromAppState()

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
        syncWizardConfigurationFromAppState()

        isBodyFullyVisible = false
        isEnGardePoseCorrect = false
        isUpperBodyValid = false
        isLowerBodyValid = false
        upperBodyFrontDirectionX = 0
        upperBodyIsFrontArmForward = false
        upperBodyFrontArmAngle = 0
        upperBodyIsFrontArmSlightlyBent = false
        upperBodyBackWristLiftDelta = 0
        upperBodyIsBackArmElevated = false
        upperBodyMetricsUpdatedAt = nil
        lowerBodyLeftKneeAngle = 0
        lowerBodyRightKneeAngle = 0
        lowerBodyAreKneesDeeplyBent = false
        lowerBodyAnkleDistance = 0
        lowerBodyShoulderDistance = 0
        lowerBodyIsStanceWide = false
        lowerBodyFrontLegDirectionX = 0
        lowerBodyIsFrontLegForward = false
        lowerBodyBackLegDirectionX = 0
        lowerBodyIsBackLegPointingCamera = false
        lowerBodyMetricsUpdatedAt = nil
        setupState = .searching
        holdProgress = 0
        didHoldTargetForRequiredDuration = false
        holdStartDate = nil
        hasAppliedSuccessSideEffects = false
        errorMessage = nil
        nextUpperBodyDebugPublishDate = .distantPast
        nextLowerBodyDebugPublishDate = .distantPast
        appState?.isCameraSetupValidated = false
        invalidateHoldTimer()
    }

    @MainActor
    private func syncWizardConfigurationFromAppState() {
        guard let appState else { return }
        activeEnGardeStep = appState.currentEnGardeStep
        isRightHandedStance = appState.isRightHanded
    }

    private func maybePublishUpperBodyDebugMetrics(
        frontDirectionX: CGFloat,
        isFrontArmForward: Bool,
        frontArmAngle: Double,
        isFrontArmSlightlyBent: Bool,
        backWristLiftDelta: CGFloat,
        isBackArmElevated: Bool
    ) {
        let now = Date()
        guard now >= nextUpperBodyDebugPublishDate else { return }
        nextUpperBodyDebugPublishDate = now.addingTimeInterval(3)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.upperBodyFrontDirectionX = frontDirectionX
            self.upperBodyIsFrontArmForward = isFrontArmForward
            self.upperBodyFrontArmAngle = frontArmAngle
            self.upperBodyIsFrontArmSlightlyBent = isFrontArmSlightlyBent
            self.upperBodyBackWristLiftDelta = backWristLiftDelta
            self.upperBodyIsBackArmElevated = isBackArmElevated
            self.upperBodyMetricsUpdatedAt = now
        }
    }

    private func maybePublishLowerBodyDebugMetrics(
        leftKneeAngle: Double,
        rightKneeAngle: Double,
        kneesDeeplyBent: Bool,
        ankleDistance: CGFloat,
        shoulderDistance: CGFloat,
        stanceWide: Bool,
        frontLegDirectionX: CGFloat,
        isFrontLegForward: Bool,
        backLegDirectionX: CGFloat,
        isBackLegPointingCamera: Bool
    ) {
        let now = Date()
        guard now >= nextLowerBodyDebugPublishDate else { return }
        nextLowerBodyDebugPublishDate = now.addingTimeInterval(3)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.lowerBodyLeftKneeAngle = leftKneeAngle
            self.lowerBodyRightKneeAngle = rightKneeAngle
            self.lowerBodyAreKneesDeeplyBent = kneesDeeplyBent
            self.lowerBodyAnkleDistance = ankleDistance
            self.lowerBodyShoulderDistance = shoulderDistance
            self.lowerBodyIsStanceWide = stanceWide
            self.lowerBodyFrontLegDirectionX = frontLegDirectionX
            self.lowerBodyIsFrontLegForward = isFrontLegForward
            self.lowerBodyBackLegDirectionX = backLegDirectionX
            self.lowerBodyIsBackLegPointingCamera = isBackLegPointingCamera
            self.lowerBodyMetricsUpdatedAt = now
        }
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
