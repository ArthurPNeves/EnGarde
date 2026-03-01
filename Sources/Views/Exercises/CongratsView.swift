import SwiftUI

struct CongratsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            VStack(spacing: 22) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundStyle(.green)
                    .shadow(color: .green.opacity(0.55), radius: 20)

                Text("Challenge Complete!")
                    .font(.system(size: 52, weight: .bold, design: .rounded))

                Text("You held a perfect En Garde stance for 5 seconds. Great work.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 760)

                Button {
                    appState.navigate(to: .welcome)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "house.fill")
                            .font(.headline.weight(.bold))
                        Text("Back to Welcome")
                            .font(.title3.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.12, green: 0.50, blue: 0.98), Color(red: 0.06, green: 0.40, blue: 0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Capsule(style: .continuous)
                    )
                    .shadow(color: Color.blue.opacity(0.35), radius: 14, y: 8)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 600)
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)

            Spacer(minLength: 20)
        }
    }
}
