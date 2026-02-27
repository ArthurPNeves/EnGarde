import SwiftUI

struct CameraFeedPlaceholderView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)

            VStack(spacing: 12) {
                Image(systemName: "video.fill")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("Camera feed placeholder")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("AVCaptureSession + Vision bindings are scaffolded in the ViewModel")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, minHeight: 360)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
        )
    }
}
