import AudioToolbox
import UIKit

class AudioManager {
    static let shared = AudioManager()
    private init() {}

    func playPhaseComplete() {
        AudioServicesPlaySystemSound(1005)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            AudioServicesPlaySystemSound(1005)
        }
    }

    func playFlipConfirm() {
        AudioServicesPlaySystemSound(1519)
    }

    func playStart() {
        AudioServicesPlaySystemSound(1100)
    }

    func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
