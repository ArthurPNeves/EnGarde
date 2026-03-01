import SwiftUI

@main
struct EnGardeApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel()
    @AppStorage("prefersDarkAppearance") private var prefersDarkAppearance: Bool = true

    var body: some Scene {
        WindowGroup {
            RootSplitView()
                .frame(minWidth: 900, minHeight: 620)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(appState)
                .environmentObject(audioPlayerViewModel)
                .tint(prefersDarkAppearance ? .white : Color(red: 0.07, green: 0.20, blue: 0.44))
                .preferredColorScheme(prefersDarkAppearance ? .dark : .light)
                .task {
                    appState.requestCameraPermission()
                }
        }
#if os(macOS)
        .defaultSize(width: 1200, height: 760)
    .windowResizability(.contentMinSize)
#endif
    }
}
