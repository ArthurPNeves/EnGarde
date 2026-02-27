import AVFoundation
import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var cameraPermissionState: CameraPermissionState = .notDetermined
    @Published var selectedSidebar: SidebarItem = .welcome
    @Published var activeFlow: FlowDestination?
    @Published var isLungeUnlocked: Bool = false

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
        activeFlow = nil
    }

    func beginTrainingFromWelcome() {
        navigate(to: .guide)
    }

    func advanceFromGuide() {
        navigate(to: .camSetup)
    }

    func startSetupCameraFlow() {
        activeFlow = .setupCameraLive
    }

    func completeSetupCameraFlow() {
        navigate(to: .exercises)
    }

    func startEnGardeFlow() {
        activeFlow = .enGardeTutorial
    }

    func openEnGardeCamera() {
        activeFlow = .enGardeCamera
    }

    func showCongrats() {
        activeFlow = .congrats
    }

    func unlockLunge() {
        isLungeUnlocked = true
    }

    func returnToExercises() {
        navigate(to: .exercises)
    }

    func openLunge() {
        guard isLungeUnlocked else { return }
        activeFlow = .lungeUnderConstruction
    }
}
