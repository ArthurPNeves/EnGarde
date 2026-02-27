import AVFoundation
import Foundation

@MainActor
final class AudioPlayerViewModel: ObservableObject {
    private var player: AVAudioPlayer?

    init() {
        prepareSuccessSoundIfAvailable()
    }

    func prepareSuccessSoundIfAvailable() {
        guard let url = findSuccessChimeURL() else {
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("Unable to initialize success chime audio player: \(error.localizedDescription)")
        }
    }

    func playSuccessSound() {
        guard let player else {
            prepareSuccessSoundIfAvailable()
            self.player?.play()
            return
        }

        player.currentTime = 0
        player.play()
    }

    private func findSuccessChimeURL() -> URL? {
        let knownExtensions = ["wav", "mp3", "m4a", "aiff", "caf"]

        for ext in knownExtensions {
            if let url = Bundle.module.url(forResource: "success_chime", withExtension: ext) {
                return url
            }
        }

        if let extensionlessURL = Bundle.module.url(forResource: "success_chime", withExtension: nil) {
            return extensionlessURL
        }

        return nil
    }
}
