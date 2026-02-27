import SwiftUI

@main
struct EnGardeApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel()
    @AppStorage("prefersDarkAppearance") private var prefersDarkAppearance: Bool = true

    var body: some Scene {
        WindowGroup {
            RootSplitView()
                .environmentObject(appState)
                .environmentObject(audioPlayerViewModel)
                .preferredColorScheme(prefersDarkAppearance ? .dark : .light)
                .task {
                    appState.requestCameraPermission()
                }
        }
    }
}
