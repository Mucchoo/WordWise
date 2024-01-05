//
//  CardViewModel.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import AVFoundation
import StoreKit
import Combine
import SwiftData

struct LearningCard {
    let card: Card
    var isLearning = true
}

class CardViewModel: ObservableObject {
    let container: DIContainer

    @Published var isDefinitionVisible = false
    @Published var isWordVisible = true
    @Published var learningCards: [LearningCard] = []
    @Published var index = 0
    @Published var isFinished = false
    @Published var shouldScrollToTop = false
    @Published var showTranslations = false
    @Published var translating = false
    @Published var isButtonEnabled = true
    @Published var showReviewAlert = false
    
    private var audioPlayer: AVAudioPlayer?
    private var cancellables = Set<AnyCancellable>()
    private var maximumCards: Int = 0
    var synthesizer = AVSpeechSynthesizer()
    var reviewController: ReviewControllerProtocol = SKStoreReviewController()
        
    var studyingCards: [Card] {
        let fetchDescriptor = FetchDescriptor<Card>()
        let todaysCards = (try? container.modelContext.fetch(fetchDescriptor)) ?? []
        return Array(todaysCards.prefix(maximumCards))

    }
    
    init(container: DIContainer, maximumCards: Int) {
        self.container = container
        self.maximumCards = maximumCards
        
        learningCards = studyingCards.map { LearningCard(card: $0) }.shuffled()
        setCategoryToPlayback()
    }
    
    var currentCard: LearningCard {
        get {
            return learningCards[safe: index] ?? .init(card: Card())
        }
        set (newCard) {
            learningCards[index] = newCard
        }
    }
    
    func speechText(_ text: String?) {
        guard !isPreview, let text else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 0.5
        utterance.pitchMultiplier = 1.2
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    func setCategoryToPlayback(session: AudioSessionProtocol = AVAudioSession.sharedInstance()) {
        guard !isPreview else { return }
        
        do {
            try session.setCategory(.playback, options: .allowBluetooth)
            try session.setActive(true, options: [])
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
            
            currentCard.card.nextLearningDate = Calendar.current.date(byAdding: .day, value: nextLearningDate, to: Date()) ?? Date()
            currentCard.card.masteryRate += 1
        }
    }

    func requestReviewIfNeeded(shouldRequest: Bool, in scene: WindowSceneProviding?) {
        if shouldRequest, let scene {
            reviewController.requestReview(in: scene)
        }
        showReviewAlert = false
    }
    
    func onTranslateButton() {
        if showTranslations {
            showTranslations = false
        } else {
            translating = true
            translateDefinitions { [weak self] in
                self?.translating = false
                self?.showTranslations = true
            }
        }
    }
    
    func translateDefinitions(completion: @escaping () -> ()) {
        var definitions = [String]()
        
        currentCard.card.meanings.forEach { meaning in
            meaning.definitions.forEach { definition in
                definitions.append(definition.definition)
            }
        }
        
        container.networkService.fetchTranslations(definitions)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                completion()
            } receiveValue: { response in
                print("response: \(response)")
                var index = 0
                
                self.currentCard.card.meanings.forEach { meaning in
                    meaning.definitions.forEach { definition in
                        definition.translatedDefinition = response.translations[safe: index]?.text ?? ""
                        index += 1
                    }
                }
            }
            .store(in: &cancellables)
    }
}

protocol ReviewControllerProtocol {
    func requestReview(in scene: WindowSceneProviding?)
}

extension SKStoreReviewController: ReviewControllerProtocol {
    func requestReview(in scene: WindowSceneProviding?) {
        guard let uiWindowScene = scene as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: uiWindowScene)
    }
}
