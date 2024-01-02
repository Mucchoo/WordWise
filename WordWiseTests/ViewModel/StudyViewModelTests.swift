//
//  StudyViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazuju on 9/5/23.
//

@testable import WordWise
import XCTest
import Combine

class StudyViewModelTests: XCTestCase {
    var vm: StudyViewModel!
    
    @MainActor override func setUp() {
        super.setUp()
        vm = StudyViewModel(container: .mock())
    }
    
    override func tearDown() {
        vm = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(vm.selectedCategory, "")
        XCTAssertEqual(vm.maximumCards, 1000)
        XCTAssertEqual(vm.showingCardView, false)
    }

    func testUpdateCards() {
        let card1 = Card()
        card1.category = "Test1"
        card1.nextLearningDate = Date()
        let card2 = Card()
        card2.category = "Test2"
        card2.nextLearningDate = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
        
        cards = [card1, card2]
        vm.selectedCategory = "Test1"
        vm.updateCards()
        
        XCTAssertEqual(studyingCards.count, 1)
        XCTAssertEqual(todaysCards.count, 1)
        XCTAssertEqual(upcomingCards.count, 0)
    }

    func testGetRateBarColors() {
        let colors = vm.getRateBarColors(rate: .zero)
        XCTAssertEqual(colors, [.black, .navy])
    }

    func testRateBarCardCount() {
        let card1 = Card()
        card1.category = "Test"
        card1.masteryRate = 0
        let card2 = Card()
        card2.category = "Test"
        card2.masteryRate = 3
        
        cards = [card1, card2]
        vm.selectedCategory = "Test"
        let count = vm.rateBarCardCount(rate: .zero)
        
        XCTAssertEqual(count, 1)
    }
}
