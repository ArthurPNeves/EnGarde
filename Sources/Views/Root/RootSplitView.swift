import SwiftUI

struct RootSplitView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("prefersDarkAppearance") private var prefersDarkAppearance: Bool = true

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailContent
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(
                    LinearGradient(
                        colors: [Color(.sRGBLinear, white: 0.12, opacity: 1), Color(.sRGBLinear, white: 0.06, opacity: 1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(prefersDarkAppearance ? 1 : 0)
                )
                .background(.background)
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "figure.fencing")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("En garde")
                        .font(.title2.weight(.bold))
                }
                Text("AI-powered fencing posture coach")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)

            Divider()
                .overlay(.white.opacity(0.1))

            List(SidebarItem.allCases, selection: sidebarSelectionBinding) { item in
                Label(item.title, systemImage: item.symbolName)
                    .font(.body.weight(.medium))
                    .symbolRenderingMode(.hierarchical)
                    .tag(item)
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)

            Divider()
                .overlay(.white.opacity(0.1))

            HStack(spacing: 12) {
                Image(systemName: prefersDarkAppearance ? "moon.stars.fill" : "sun.max.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 34, height: 34)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(prefersDarkAppearance ? "Dark Mode" : "Light Mode")
                        .font(.headline)
                    Text(prefersDarkAppearance ? "Switch to light" : "Switch to dark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: $prefersDarkAppearance)
                    .labelsHidden()
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(16)
        }
        .background(.regularMaterial)
    }

    private var detailContent: some View {
        Group {
            switch appState.destination {
            case .sidebar(.welcome):
                WelcomeView()
            case .sidebar(.guide):
                GuideView()
            case .sidebar(.camSetup):
                CamSetupView()
            case .sidebar(.exercises):
                ExercisesView()
            case .flow(.setupCameraLive):
                CameraTrainingView(mode: .setup, nextButtonTitle: "Next") {
                    appState.completeSetupCameraFlow()
                }
            case .flow(.enGardeTutorial):
                EnGardeTutorialView()
            case .flow(.enGardeCamera):
                CameraTrainingView(mode: .enGarde, nextButtonTitle: "View Result") {
                    appState.showCongrats()
                }
            case .flow(.congrats):
                CongratsView()
            case .flow(.lungeUnderConstruction):
                UnderConstructionView()
            }
        }
        .animation(.smooth, value: appState.destination)
    }

    private var sidebarSelectionBinding: Binding<SidebarItem?> {
        Binding<SidebarItem?>(
            get: { appState.selectedSidebar },
            set: { newSelection in
                guard let newSelection else { return }
                appState.navigate(to: newSelection)
            }
        )
    }
}
