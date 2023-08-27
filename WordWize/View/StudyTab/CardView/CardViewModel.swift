//
//  CardViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import AVFoundation
import StoreKit

struct LearningCard {
    let card: Card
    var isLearning = true
}

class CardViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel

    @Published var isDefinitionVisible = false
    @Published var isWordVisible = true
    @Published var learningCards: [LearningCard]
    @Published var index = 0
    @Published var isFinished = false
    @Published var shouldScrollToTop = false
    @Published var showTranslations = false
    @Published var translating = false
    @Published var isButtonEnabled = true
    @Published var showReviewAlert = false

    
    private var audioPlayer: AVAudioPlayer?
    private var synthesizer = AVSpeechSynthesizer()
    
    init(studyingCards: [Card]) {
        self.learningCards = studyingCards.map { LearningCard(card: $0) }.shuffled()
    }
    
    var currentCard: LearningCard {
        get {
            return learningCards[index]
        }
        set (newCard) {
            learningCards[index] = newCard
        }
    }
    
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
    
    func hardButtonPressed() {
        guard isButtonEnabled else { return }
        
        isButtonEnabled = false
        isDefinitionVisible = false
        isWordVisible = false
        showTranslations = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            withAnimation(.none) {
                let card = self.learningCards.remove(at: self.index)
                self.learningCards.append(card)
            }
            
            isButtonEnabled = true
            isWordVisible = true
            shouldScrollToTop = true
            
            let card = currentCard.card
            card.lastHardDate = Date()
            card.masteryRate = 0
            dataViewModel.persistence.saveContext()
            dataViewModel.loadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.speechText(card.text)
            }
        }
    }

    func easyButtonPressed() {
        guard isButtonEnabled else { return }
        
        isButtonEnabled = false
        isDefinitionVisible = false
        isWordVisible = false
        showTranslations = false
        currentCard.isLearning = false

        updateMasteryRate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }

            withAnimation(.none) {
                if self.index + 1 == self.learningCards.count {
                    self.isFinished = true
                    
                    if self.learningCards.count > 20 {
                        self.showReviewAlert = true
                    }
                } else {
                    self.index += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.speechText(self.currentCard.card.text)
                    }
                }
            }
            
            isButtonEnabled = true
            isWordVisible = true
            shouldScrollToTop = true
        }
    }
    
    private func updateMasteryRate() {
        var nextLearningDate = 0
        if let date = currentCard.card.lastHardDate, Calendar.current.isDateInToday(date) {
            nextLearningDate = 1
        } else {
            switch currentCard.card.rate {
            case .zero:
                nextLearningDate = 2
            case .twentyFive:
                nextLearningDate = 4
            case .fifty:
                nextLearningDate = 7
            case .seventyFive:
                nextLearningDate = 14
            default:
                break
            }
            
            currentCard.card.nextLearningDate = Calendar.current.date(byAdding: .day, value: nextLearningDate, to: Date())
            currentCard.card.masteryRate += 1
        }
        
        dataViewModel.persistence.saveContext()
        dataViewModel.loadData()
    }

    func requestReviewIfNeeded(shouldRequest: Bool) {
        if shouldRequest, let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        self.showReviewAlert = false
    }
    
    func onTranslateButton() {
        if showTranslations {
            showTranslations = false
        } else {
            translating = true
            dataViewModel.translateDefinitions(currentCard.card) { [weak self] in
                self?.translating = false
                self?.showTranslations = true
            }
        }
    }
}
