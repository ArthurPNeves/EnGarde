import SwiftUI

struct GuideView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Guide", systemImage: "figure.fencing")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Fencing Fundamentals & App Use")
                .font(.title2.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("Welcome to En Garde. This application is designed to analyze your fencing posture in real time. We cover the basics: fencing is a combat sport with defined lanes, timing, distance control, and the en garde stance as your core foundation.")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            guideImageCard(resourceName: "template", label: "Fencing Illustration")
                            guideImageCard(resourceName: "swords", label: "Modern Foil Fencing")
                        }

                        Text("Our algorithm tracks body alignment and key joints to validate posture quality. As you progress, you'll receive immediate visual feedback for corridor positioning, stance balance, and en garde consistency.")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            mockupCard(resourceName: "template_vertical", label: "Posture Check Template")
                            mockupCard(resourceName: "template_vertical", label: "Posture Check Template usage")
                        }

                        Text("Before we do the fun stuff, let's setup your camera.")
                            .font(.title3.weight(.medium))

                        Button {
                            appState.advanceFromGuide()
                        } label: {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.subheadline.weight(.semibold))

                                Text("SETUP CAMERA")
                                    .font(.subheadline.weight(.bold))
                                    .tracking(0.4)

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(.subheadline.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.12, green: 0.50, blue: 0.98), Color(red: 0.06, green: 0.40, blue: 0.92)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(22)
                    .frame(maxWidth: 860, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(.white.opacity(0.16), lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.hidden)
        }
    }

    private func guideImageCard(resourceName: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(resourceName, bundle: .module)
                .resizable()
                .scaledToFill()
                .frame(height: 185)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func mockupCard(resourceName: String, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black.opacity(0.35))
                Image(resourceName, bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.green.opacity(0.45), lineWidth: 1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 170)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
