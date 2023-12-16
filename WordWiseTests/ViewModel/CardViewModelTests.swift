//
//  CardViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazuju on 9/5/23.
//

import XCTest
@testable import WordWise
import Combine
import AVFoundation

class MockSpeechSynthesizer: AVSpeechSynthesizer {
    var speakCalled = false

    override func speak(_ utterance: AVSpeechUtterance) {
        speakCalled = true
    }
}

class MockAudioSession: AudioSessionProtocol {
    var setCategoryCalled = false
    var setActiveCalled = true
    
    func setCategory(_ category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions = []) throws {
        setCategoryCalled = true
    }
    
    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
        setActiveCalled = true
    }
}

class MockWindowScene: WindowSceneProviding {
    var activationState: UIScene.ActivationState = .foregroundActive
}

class MockReviewController: ReviewControllerProtocol {
    var requestReviewCalled = false
    
    func requestReview(in scene: WindowSceneProviding?) {
        requestReviewCalled = true
    }
}

class CardViewModelTests: XCTestCase {

    var vm: CardViewModel!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor override func setUp() {
        super.setUp()
        vm = CardViewModel(container: .mock())
        cancellables = []
    }
    
    override func tearDown() {
        vm = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(vm.index, 0)
        XCTAssertEqual(vm.isFinished, false)
        XCTAssertEqual(vm.isWordVisible, true)
        XCTAssertEqual(vm.isDefinitionVisible, false)
        XCTAssertEqual(vm.showTranslations, false)
        XCTAssertEqual(vm.isButtonEnabled, true)
    }

    func testHardButtonPressed() {
        let isButtonEnabledExpectation = XCTestExpectation(description: "isButtonEnabled should be updated")
        let isWordVisibleExpectation = XCTestExpectation(description: "isWordVisible should be updated")
        
        vm.$isButtonEnabled
            .dropFirst()
            .sink { isEnabled in
                if !isEnabled {
                    isButtonEnabledExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        vm.$isWordVisible
            .dropFirst()
            .sink { isVisible in
                if isVisible {
                    isWordVisibleExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        vm.hardButtonPressed()
        
        wait(for: [isButtonEnabledExpectation, isWordVisibleExpectation], timeout: 2)
    }

    func testEasyButtonPressed() {
        let isFinishedExpectation = XCTestExpectation(description: "isFinished should be updated")
        
        vm.$isFinished
            .dropFirst()
            .sink { isFinished in
                if isFinished {
                    isFinishedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        vm.learningCards = [LearningCard(card: vm.container.appState.studyingCards[0])]
        vm.easyButtonPressed()
        
        wait(for: [isFinishedExpectation], timeout: 2)
    }

    func testSpeechTextIsCalled() {
        let mockSynthesizer = MockSpeechSynthesizer()
        vm.synthesizer = mockSynthesizer
        vm.speechText("Hello world")
        XCTAssertTrue(mockSynthesizer.speakCalled)
    }

    func testSetCategoryToPlayback() {
        let mockAudioSession = MockAudioSession()
        vm.setCategoryToPlayback(session: mockAudioSession)
        XCTAssertTrue(mockAudioSession.setCategoryCalled)
    }

    func testOnTranslateButton() {
        let showTranslationsExpectation = XCTestExpectation(description: "showTranslations should be updated")
        let translatingExpectation = XCTestExpectation(description: "translating should be updated")
        
        vm.$showTranslations
            .dropFirst()
            .sink { isVisible in
                if isVisible {
                    showTranslationsExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        vm.$translating
            .dropFirst()
            .sink { isTranslating in
                if isTranslating {
                    translatingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        vm.onTranslateButton()
        wait(for: [showTranslationsExpectation, translatingExpectation], timeout: 2)
    }

    func testRequestReviewIfNeeded() {
        let mockReviewController = MockReviewController()
        let mockScene = MockWindowScene()
        vm.reviewController = mockReviewController
        vm.requestReviewIfNeeded(shouldRequest: true, in: mockScene)
        XCTAssertTrue(mockReviewController.requestReviewCalled)
    }
}
