import AppKit

@MainActor
final class SoundPlayer {
    static let availableSounds = [
        "Tink", "Pop", "Blow", "Bottle", "Frog", "Funk",
        "Hero", "Morse", "Ping", "Purr", "Sosumi", "Submarine"
    ]

    private let completeSound: NSSound?
    private var tickCache: [String: NSSound] = [:]
    private let preferences: PreferencesStore

    init(preferences: PreferencesStore = PreferencesStore()) {
        self.preferences = preferences
        completeSound = NSSound(contentsOfFile: "/System/Library/Sounds/Glass.aiff", byReference: true)
    }

    static func playPreview(named name: String) {
        guard let sound = NSSound(contentsOfFile: "/System/Library/Sounds/\(name).aiff", byReference: true) else { return }
        sound.volume = 0.5
        sound.play()
    }

    func playTick() {
        let name = preferences.tickSound
        if let cached = tickCache[name] {
            cached.stop()
            cached.play()
            return
        }
        let sound = NSSound(contentsOfFile: "/System/Library/Sounds/\(name).aiff", byReference: true)
        sound?.volume = 0.5
        tickCache[name] = sound
        sound?.play()
    }

    func playComplete() {
        completeSound?.stop()
        completeSound?.play()
    }
}
