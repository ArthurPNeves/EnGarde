import AppKit
import SwiftUI

struct ResourceImageView: View {
    let name: String

    var body: some View {
        Group {
            if let nsImage = loadImage(named: name) {
                Image(nsImage: nsImage)
                    .resizable()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.thinMaterial)
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func loadImage(named name: String) -> NSImage? {
        if let image = NSImage(named: NSImage.Name(name)) {
            return image
        }

        let candidates = ["png", "jpg", "jpeg", "heic", "webp"]
        for ext in candidates {
            if let url = Bundle.module.url(forResource: name, withExtension: ext),
               let image = NSImage(contentsOf: url) {
                return image
            }
        }

        if let url = Bundle.module.url(forResource: name, withExtension: nil),
           let image = NSImage(contentsOf: url) {
            return image
        }

        return nil
    }
}
