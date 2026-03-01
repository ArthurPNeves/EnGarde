import SwiftUI

struct EnGardeTutorialView: View {
    @EnvironmentObject private var appState: AppState
    @State private var segmentIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("En garde Tutorial", systemImage: "figure.fencing")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Stance & Alignment")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 18) {
                        if segmentIndex == 0 {
                            Text("Mission 1/2 · Build your En garde base")
                                .font(.title3.weight(.semibold))

                            HStack(spacing: 12) {
                                tutorialImageCard(resourceName: "template", title: "Stance shape")
                                tutorialImageCard(resourceName: "swords", title: "Guard line")
                            }

                            HStack(spacing: 8) {
                                quickTag("Knees bent")
                                quickTag("Wide base")
                                quickTag("Arms ready")
                                quickTag("Hold 5s")
                            }

                            Toggle(isOn: $appState.isRightHanded) {
                                Text(appState.isRightHanded ? "Right-handed stance" : "Left-handed stance")
                                    .font(.subheadline.weight(.medium))
                            }
                            .toggleStyle(.switch)

                            nextButton(title: "NEXT") {
                                segmentIndex = 1
                            }
                        } else {
                            Text("Mission 2/2 · Spot the right posture")
                                .font(.title3.weight(.semibold))

                            HStack(alignment: .top, spacing: 14) {
                                incorrectPanel(
                                    titles: ["Arms too low", "Narrow base", "Unstable body"]
                                )
                                correctPanel()
                            }

                            nextButton(title: "START EN GARDE CHECK") {
                                appState.openEnGardeUpperBodyTutorial()
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 780, alignment: .leading)
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
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func nextButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "figure.fencing")
                    .font(.subheadline.weight(.semibold))

                Text(title)
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

    private func quickTag(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule(style: .continuous))
    }

    private func tutorialImageCard(resourceName: String, title: String) -> some View {
        VStack(spacing: 6) {
            ResourceImageView(name: resourceName)
                .scaledToFill()
                .frame(height: 165)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func incorrectPanel(titles: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("X Incorrect", systemImage: "xmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.red)

            HStack(spacing: 8) {
                ForEach(titles, id: \.self) { title in
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
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func correctPanel() -> some View {
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
        .frame(width: 220, alignment: .leading)
    }
}
