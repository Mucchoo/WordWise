//
//  AudioHelper.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/27/23.
//

import Foundation
import AVFoundation

class AudioViewModel {
    private var audioPlayer: AVAudioPlayer?
    private var synthesizer = AVSpeechSynthesizer()
    
    func speechText(_ text: String?) {
        guard let text = text else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 0.5
        utterance.pitchMultiplier = 1.2
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    func setCategoryToPlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetooth)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("failed setCategoryToPlayback: \(error.localizedDescription)")
        }
    }
}
