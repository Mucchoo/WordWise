//
//  AudioHelper.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/27/23.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    
    func downloadAudio(card: Card) {
        if let phoneticUS = card.phoneticsArray.first(where: { $0.audio?.contains("us.mp3") ?? false }) {
            downloadAudio(phonetic: phoneticUS)
        } else if let phoneticUK = card.phoneticsArray.first {
            downloadAudio(phonetic: phoneticUK)
        }
    }
    
    func downloadAudio(phonetic: Phonetic) {
        guard let urlString = phonetic.audio,
              let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else { return }

        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let savedURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            let relativePath = url.lastPathComponent

            if isPlayable(url: savedURL) {
                print("File already exists: \(savedURL.absoluteString)")
                return
            }
            
            let downloadTask = URLSession.shared.downloadTask(with: URLRequest(url: url)) { url, response, error in
                guard error == nil, let fileURL = url else { return }
                
                do {
                    try FileManager.default.moveItem(at: fileURL, to: savedURL)
                    
                    DispatchQueue.main.async {
                        print("downloaded \(phonetic.unwrappedText): \(savedURL.absoluteString)")
                        phonetic.downloadedAudioUrlString = relativePath
                        PersistenceController.shared.saveContext()
                    }
                } catch {
                    print("failed downloading audio: \(error.localizedDescription)")
                }
            }
            
            downloadTask.resume()
        } catch {
            print("Failed to get documents directory: \(error.localizedDescription)")
        }
    }
    
    func getFileURL(with relativePath: String) -> URL? {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentsURL.appendingPathComponent(relativePath)
        } catch {
            print("Failed to get documents directory: \(error.localizedDescription)")
            return nil
        }
    }

    
    func isPlayable(url: URL) -> Bool {
        do {
            let _ = try AVAudioPlayer(contentsOf: url)
            return true
        } catch {
            return false
        }
    }
    
    func playAudio(card: Card) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            guard let relativePath = card.phoneticsArray.first?.downloadedAudioUrlString else {
                print("playAudio blocked")
                playAudio(card: card)
                return
            }
            
            guard let url = getFileURL(with: relativePath) else {
                print("Invalid file URL.")
                return
            }

            print("playAudio: \(card.text ?? "nil") url: \(url.absoluteString)")
            
            do {
                let audioSession = AVAudioSession.sharedInstance()
                if audioSession.category != .playback {
                    try audioSession.setCategory(.playback, options: .allowBluetooth)
                    try audioSession.setActive(true)
                }
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
            } catch {
                print("playAudio failed: \(error.localizedDescription)")
                playAudio(card: card)
            }
        }
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
