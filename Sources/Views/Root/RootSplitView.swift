import SwiftUI

struct RootSplitView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("prefersDarkAppearance") private var prefersDarkAppearance: Bool = true

    private let visibleSidebarItems: [SidebarItem] = [.welcome, .guide, .exercises]

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailContent
                .padding(isCameraDestination ? 0 : 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(detailBackground)
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Text("EG")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .fill(Color(red: 0.12, green: 0.31, blue: 0.63))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("EG")
                            .font(.headline.weight(.semibold))
                        Text("version 1")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)

            Divider()
                .overlay(.white.opacity(0.1))

            VStack(alignment: .leading, spacing: 10) {
                Text("NAVIGATION")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)

                List(visibleSidebarItems, selection: sidebarSelectionBinding) { item in
                    Label(item.title, systemImage: item.symbolName)
                        .font(.body.weight(.medium))
                        .symbolRenderingMode(.hierarchical)
                        .tag(item)
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(.clear)
            }
            .padding(.top, 10)

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                Image(systemName: "moon.stars.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 34, height: 34)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Dark Mode")
                        .font(.headline)
                    Text("Switch to dark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ThemeToggleButton(isDarkMode: $prefersDarkAppearance)
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(16)
        }
        .background(sidebarBackground)
    }

    private var detailBackground: some View {
        LinearGradient(
            colors: prefersDarkAppearance
                ? [Color(red: 0.04, green: 0.10, blue: 0.23), Color(red: 0.02, green: 0.06, blue: 0.16)]
                : [Color.white, Color(red: 0.92, green: 0.95, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var sidebarBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    prefersDarkAppearance
                        ? Color(red: 0.03, green: 0.09, blue: 0.21)
                        : Color.white
                )
            Rectangle()
                .fill(.ultraThinMaterial)
        }
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
            case .flow(.cameraSetupTutorial):
                CamSetupView()
            case .flow(.setupCameraLive):
                CameraTrainingView(mode: .setup, nextButtonTitle: "Next") {
                    appState.completeSetupCameraFlow()
                }
            case .flow(.enGardeTutorial):
                EnGardeTutorialView()
            case .flow(.enGardeUpperBodyTutorial):
                UpperBodyTutorialView()
            case .flow(.enGardeUpperBodyCamera):
                UpperBodyCameraView()
            case .flow(.enGardeLowerBodyTutorial):
                LowerBodyTutorialView()
            case .flow(.enGardeLowerBodyCamera):
                LowerBodyCameraView()
            case .flow(.enGardeFullPoseTutorial):
                FullPoseTutorialView()
            case .flow(.enGardeFullPoseCamera):
                FullPoseCameraView()
            case .flow(.congrats):
                CongratsView()
            case .flow(.lungeUnderConstruction):
                UnderConstructionView()
            }
        }
        .animation(.smooth, value: appState.destination)
    }

    private var isCameraDestination: Bool {
        switch appState.destination {
        case .flow(.setupCameraLive),
                .flow(.enGardeUpperBodyCamera),
                .flow(.enGardeLowerBodyCamera),
                .flow(.enGardeFullPoseCamera):
            return true
        default:
            return false
        }
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
