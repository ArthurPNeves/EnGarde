import SwiftUI

struct ThemeToggleButton: View {
    @Binding var isDarkMode: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                isDarkMode.toggle()
            }
        } label: {
            ZStack(alignment: isDarkMode ? .trailing : .leading) {
                Capsule(style: .continuous)
                    .fill(isDarkMode ? Color.white.opacity(0.18) : Color(red: 0.07, green: 0.20, blue: 0.44).opacity(0.22))
                    .frame(width: 58, height: 32)

                Circle()
                    .fill(isDarkMode ? Color.white : Color(red: 0.07, green: 0.20, blue: 0.44))
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(isDarkMode ? Color(red: 0.07, green: 0.20, blue: 0.44) : .white)
                    )
                    .padding(3)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Toggle appearance")
        .accessibilityValue(isDarkMode ? "Dark" : "Light")
    }
}
