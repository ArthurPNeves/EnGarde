import Foundation

enum EnGardeStep: Equatable {
    case upperBody
    case lowerBody
    case fullPose
    case completed
}

enum FlowDestination: Equatable {
    case cameraSetupTutorial
    case setupCameraLive
    case enGardeTutorial
    case enGardeUpperBodyTutorial
    case enGardeUpperBodyCamera
    case enGardeLowerBodyTutorial
    case enGardeLowerBodyCamera
    case enGardeFullPoseTutorial
    case enGardeFullPoseCamera
    case congrats
    case lungeUnderConstruction
}

enum NavigationDestination: Equatable {
    case sidebar(SidebarItem)
    case flow(FlowDestination)
}
