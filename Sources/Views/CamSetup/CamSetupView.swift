import SwiftUI

struct CamSetupView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        GeometryReader { proxy in
            let heroHeight = min(max(proxy.size.height * 0.46, 260), 520)

            VStack(alignment: .leading, spacing: 20) {
                Text("Camera Setup")
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                HStack(spacing: 22) {
                    dotLegendItem(color: .red, text: "Outside Frame")
                    dotLegendItem(color: .yellow, text: "Keep Still")
                    dotLegendItem(color: .green, text: "Practice Ready")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                ResourceImageView(name: "camSetup_correct")
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: heroHeight)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Avoid Common Mistakes")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 14) {
                        mistakeThumb(imageName: "camSetup_feetNotShowing", title: "Feet Not Showing")
                        mistakeThumb(imageName: "camSetup_neckNotShowing", title: "Neck Not Showing")
                    }
                }

                Spacer(minLength: 0)

                Button {
                    appState.startSetupCameraFlow()
                } label: {
                    HStack(spacing: 10) {
                        Spacer()
                        Text("Next")
                            .font(.title3.weight(.bold))
                        Image(systemName: "arrow.right")
                            .font(.title3.weight(.bold))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.12, green: 0.50, blue: 0.98), Color(red: 0.06, green: 0.40, blue: 0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 18)
        }
    }

    private func dotLegendItem(color: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 11, height: 11)
            Text(text)
        }
    }

    private func mistakeThumb(imageName: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ResourceImageView(name: imageName)
                .scaledToFit()
                .frame(width: 150, height: 120)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .padding(6)
                }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
