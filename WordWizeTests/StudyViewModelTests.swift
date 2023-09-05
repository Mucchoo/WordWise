//
//  StudyViewModelTests.swift
//  WordWizeTests
//
//  Created by Musa Yazuju on 9/5/23.
//

@testable import WordWize
import XCTest
import Combine

class StudyViewModelTests: XCTestCase {
    var vm: StudyViewModel!
    
    override func setUp() {
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
        let card1 = Card(context: vm.container.persistence.viewContext)
        card1.category = "Test1"
        card1.nextLearningDate = Date()
        let card2 = Card(context: vm.container.persistence.viewContext)
        card2.category = "Test2"
        card2.nextLearningDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())
        
        vm.container.appState.cards = [card1, card2]
        vm.selectedCategory = "Test1"
        vm.updateCards()
        
        XCTAssertEqual(vm.container.appState.studyingCards.count, 1)
        XCTAssertEqual(vm.container.appState.todaysCards.count, 1)
        XCTAssertEqual(vm.container.appState.upcomingCards.count, 0)
    }

    func testGetRateBarColors() {
        let colors = vm.getRateBarColors(rate: .zero)
        XCTAssertEqual(colors, [.black, .navy])
    }

    func testRateBarCardCount() {
        let card1 = Card(context: vm.container.persistence.viewContext)
        card1.category = "Test"
        card1.masteryRate = 0
        let card2 = Card(context: vm.container.persistence.viewContext)
        card2.category = "Test"
        card2.masteryRate = 3
        
        vm.container.appState.cards = [card1, card2]
        vm.selectedCategory = "Test"
        let count = vm.rateBarCardCount(rate: .zero)
        
        XCTAssertEqual(count, 1)
    }
}
