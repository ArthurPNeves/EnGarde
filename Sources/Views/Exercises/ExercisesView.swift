import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Exercises")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 16)], spacing: 16) {
                exerciseCard(
                    title: "En garde",
                    subtitle: "Foundation stance",
                    symbolName: "figure.fencing",
                    isLocked: false
                ) {
                    appState.startEnGardeFlow()
                }

                exerciseCard(
                    title: "Lunge",
                    subtitle: appState.isLungeUnlocked ? "Unlocked" : "Complete En garde first",
                    symbolName: appState.isLungeUnlocked ? "bolt.fill" : "lock.fill",
                    isLocked: !appState.isLungeUnlocked
                ) {
                    appState.openLunge()
                }
            }
            .frame(maxWidth: 940)
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func exerciseCard(
        title: String,
        subtitle: String,
        symbolName: String,
        isLocked: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: symbolName)
                        .font(.title2.weight(.semibold))
                    Spacer()
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                    }
                }

                Text(title)
                    .font(.title3.weight(.bold))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.16), lineWidth: 1)
            )
            .opacity(isLocked ? 0.55 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }
}
