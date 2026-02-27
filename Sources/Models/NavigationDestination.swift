import Foundation

enum FlowDestination: Equatable {
    case cameraSetupTutorial
    case setupCameraLive
    case enGardeTutorial
    case enGardeCamera
    case congrats
    case lungeUnderConstruction
}

enum NavigationDestination: Equatable {
    case sidebar(SidebarItem)
    case flow(FlowDestination)
}
