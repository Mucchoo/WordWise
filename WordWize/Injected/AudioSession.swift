//
//  AudioSession.swift
//  WordWize
//
//  Created by Musa Yazuju on 9/5/23.
//

import Foundation
import AVFoundation

protocol AudioSessionProtocol {
    func setCategory(_ category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions) throws
    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws
}

extension AVAudioSession: AudioSessionProtocol {}
