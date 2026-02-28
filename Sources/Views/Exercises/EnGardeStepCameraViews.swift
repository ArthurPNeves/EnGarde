import SwiftUI

struct UpperBodyCameraView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        CameraTrainingView(mode: .enGarde, nextButtonTitle: "Next") {
            appState.completeEnGardeUpperBodyStep()
        }
        .onAppear {
            appState.currentEnGardeStep = .upperBody
        }
    }
}

struct LowerBodyCameraView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        CameraTrainingView(mode: .enGarde, nextButtonTitle: "Next") {
            appState.completeEnGardeLowerBodyStep()
        }
        .onAppear {
            appState.currentEnGardeStep = .lowerBody
        }
    }
}

struct FullPoseCameraView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        CameraTrainingView(mode: .enGarde, nextButtonTitle: "Finish") {
            appState.completeEnGardeFullPoseStep()
        }
        .onAppear {
            appState.currentEnGardeStep = .fullPose
        }
    }
}
