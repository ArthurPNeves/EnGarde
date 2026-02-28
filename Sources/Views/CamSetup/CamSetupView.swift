import SwiftUI

struct CamSetupView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Camera Setup", systemImage: "figure.fencing")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Capture & Calibration")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Calibration Tutorial")
                            .font(.title3.weight(.semibold))

                        Text("To ensure accurate posture analysis, position your device so your body is visible from the top of the neck down to the feet. Refer to the visual indicators below.")
                            .font(.body)
                            .foregroundStyle(.secondary)

                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 10) {
                                instructionRow(icon: "camera.fill", text: "Setup Cam: Place your device on a stable surface at chest height.")
                                instructionRow(icon: "figure.stand", text: "Capture Framing: Keep your body visible from the top of the neck to the feet.")
                                instructionRow(icon: "circle.grid.3x3.fill", text: "Position Feedback: Red dot - Outside of Frame. Yellow dot - Inside, do not move. Green dot - Practice Ready.")
                            }

                            dotLegendGraphic
                                .frame(width: 120)
                        }

                        Text("\"Do not move the device once locked\"")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        HStack(alignment: .top, spacing: 14) {
                            incorrectPanel
                            correctPanel
                        }

                        Button {
                            appState.startSetupCameraFlow()
                        } label: {
                            HStack {
                                Spacer()
                                Text("NEXT")
                                    .font(.subheadline.weight(.bold))
                                    .tracking(0.4)
                                Image(systemName: "arrow.right")
                                    .font(.subheadline.weight(.bold))
                                Spacer()
                            }
                            .foregroundStyle(.white)
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
                    .padding(18)
                    .frame(maxWidth: 760, alignment: .leading)
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
                .padding(.bottom, 6)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func instructionRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .frame(width: 18)
                .foregroundStyle(.white)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var dotLegendGraphic: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack(spacing: 10) {
                dotColumn(color: .green)
                dotColumn(color: .yellow)
                dotColumn(color: .red)
            }
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func dotColumn(color: Color) -> some View {
        VStack(spacing: 7) {
            Circle().fill(color).frame(width: 10, height: 10)
            Circle().fill(color.opacity(0.85)).frame(width: 10, height: 10)
        }
    }

    private var incorrectPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("X Incorrect", systemImage: "xmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.red)

            HStack(spacing: 8) {
                incorrectCard(title: "Body Partially\nVisible")
                incorrectCard(title: "Device\nToo Low")
                incorrectCard(title: "Misaligned\nAngle")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func incorrectCard(title: String) -> some View {
        VStack(spacing: 5) {
            ResourceImageView(name: "template_vertical")
                .scaledToFill()
                .frame(width: 92, height: 130)
                .clipped()
                .overlay(alignment: .bottom) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .offset(y: 9)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.red.opacity(0.65), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.red.opacity(0.9))
        }
    }

    private var correctPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("✓ Correct", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.green)

            ZStack {
                ResourceImageView(name: "template_vertical")
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.green.opacity(0.75), lineWidth: 1.2)

                VStack {
                    Spacer()
                    Image(systemName: "figure.fencing")
                        .font(.title)
                        .foregroundStyle(.green)
                    Spacer()
                    HStack {
                        Rectangle().fill(.green.opacity(0.6)).frame(height: 1)
                        Rectangle().fill(.green.opacity(0.6)).frame(height: 1)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(width: 200, alignment: .leading)
    }
}
