import AVFoundation
import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var cameraPermissionState: CameraPermissionState = .notDetermined
    @Published var selectedSidebar: SidebarItem = .welcome
    @Published var activeFlow: FlowDestination?
    @Published var isCameraSetupValidated: Bool = false
    @Published var currentEnGardeStep: EnGardeStep = .upperBody
    @Published var isRightHanded: Bool = true

    var destination: NavigationDestination {
        if let activeFlow {
            return .flow(activeFlow)
        }
        return .sidebar(selectedSidebar)
    }

    func requestCameraPermission() {
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch currentStatus {
        case .authorized:
            cameraPermissionState = .authorized
        case .denied:
            cameraPermissionState = .denied
        case .restricted:
            cameraPermissionState = .restricted
        case .notDetermined:
            cameraPermissionState = .notDetermined
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.cameraPermissionState = granted ? .authorized : .denied
                }
            }
        @unknown default:
            cameraPermissionState = .denied
        }
    }

    func navigate(to sidebar: SidebarItem) {
        selectedSidebar = sidebar
        activeFlow = (sidebar == .exercises) ? .enGardeTutorial : nil
    }

    func beginTrainingFromWelcome() {
        navigate(to: .guide)
    }

    func advanceFromGuide() {
        selectedSidebar = .guide
        activeFlow = .cameraSetupTutorial
    }

    func startSetupCameraFlow() {
        isCameraSetupValidated = false
        activeFlow = .setupCameraLive
    }

    func completeSetupCameraFlow() {
        navigate(to: .exercises)
    }

    func startEnGardeFlow() {
        currentEnGardeStep = .upperBody
        activeFlow = .enGardeTutorial
    }

    func openEnGardeUpperBodyTutorial() {
        currentEnGardeStep = .upperBody
        activeFlow = .enGardeUpperBodyTutorial
    }

    func openEnGardeUpperBodyCamera() {
        currentEnGardeStep = .upperBody
        activeFlow = .enGardeUpperBodyCamera
    }

    func openEnGardeLowerBodyTutorial() {
        currentEnGardeStep = .lowerBody
        activeFlow = .enGardeLowerBodyTutorial
    }

    func openEnGardeLowerBodyCamera() {
        currentEnGardeStep = .lowerBody
        activeFlow = .enGardeLowerBodyCamera
    }

    func openEnGardeFullPoseTutorial() {
        currentEnGardeStep = .fullPose
        activeFlow = .enGardeFullPoseTutorial
    }

    func openEnGardeFullPoseCamera() {
        currentEnGardeStep = .fullPose
        activeFlow = .enGardeFullPoseCamera
    }

    func completeEnGardeUpperBodyStep() {
        openEnGardeLowerBodyTutorial()
    }

    func completeEnGardeLowerBodyStep() {
        openEnGardeFullPoseTutorial()
    }

    func completeEnGardeFullPoseStep() {
        currentEnGardeStep = .completed
        showCongrats()
    }

    func showCongrats() {
        activeFlow = .congrats
    }

    func returnToEnGarde() {
        navigate(to: .exercises)
    }

    func goBackToTutorial(from mode: PoseTrainingMode) {
        switch mode {
        case .setup:
            activeFlow = .cameraSetupTutorial
        case .enGarde:
            switch currentEnGardeStep {
            case .upperBody:
                openEnGardeUpperBodyTutorial()
            case .lowerBody:
                openEnGardeLowerBodyTutorial()
            case .fullPose, .completed:
                openEnGardeFullPoseTutorial()
            }
        }
    }
}
