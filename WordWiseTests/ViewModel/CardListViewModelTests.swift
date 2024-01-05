//
//  CardListViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazuju on 9/6/23.
//

import XCTest
import Combine
@testable import WordWise

class CardListViewModelTests: XCTestCase {

    var vm: CardListViewModel!
    var cancellables: Set<AnyCancellable>!

    @MainActor override func setUp() {
        super.setUp()
        vm = CardListViewModel(container: .mock(), categoryName: "Fruits")
        cancellables = []
    }
    
    override func tearDown() {
        vm = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertEqual(vm.cardList.count, 0)
        XCTAssertEqual(vm.categoryName, "Fruits")
    }
    
    func testChangeCategory() {
        let card = Card()
        vm.selectedCards.append(card)
        vm.pickerAlertValue = "Vegetables"
        
        vm.changeCategory()
        
        XCTAssertEqual(card.category, "Vegetables")
    }

    func testChangeMasteryRate() {
        let rates: [(String, Int16)] = [("0%", 0), ("25%", 1), ("50%", 2), ("75%", 3), ("100%", 4)]

        rates.forEach { string, int in
            let card = Card()
            vm.selectedCards.append(card)
            
            vm.selectedRateString = string
            vm.changeMasteryRate()
            
            XCTAssertEqual(card.masteryRate, int)
        }
    }
    
    func testUpdateCard() {
        let rates: [Int16] = [0, 1, 2, 3, 4]
        
        rates.forEach { rate in
            let card = Card()
            vm.selectedCard = card
            vm.selectedRate = rate
            vm.updateCard()
            
            XCTAssertEqual(card.masteryRate, rate)
        }
    }
    
    func testShowCardDetail() {
        let card = Card()
        card.category = "Fruits"
        vm.showCardDetail(card)
        
        XCTAssertEqual(vm.cardCategory, "Fruits")
        XCTAssertTrue(vm.navigateToCardDetail)
    }
    
    func testSelectCard() {
        let card = Card()
        vm.selectCard(card)
        XCTAssertTrue(vm.selectedCards.contains(where: { $0 == card }))
        vm.selectCard(card)
        XCTAssertFalse(vm.selectedCards.contains(where: { $0 == card }))
    }
    
    func testDeleteSelectedCards() {
        let card1 = Card()
        let card2 = Card()
        
        vm.selectedCards.append(contentsOf: [card1, card2])
        vm.deleteSelectedCards()
        
        XCTAssertFalse(vm.cards.contains(card1))
        XCTAssertFalse(vm.cards.contains(card2))
    }

    func testMultipleSelectionModeToggle() {
        vm.multipleSelectionMode = true
        XCTAssertTrue(vm.multipleSelectionMode)
        XCTAssertEqual(vm.selectedCards.count, 0)

        vm.multipleSelectionMode = false
        XCTAssertFalse(vm.multipleSelectionMode)
        XCTAssertEqual(vm.selectedCards.count, 0)
    }

    func testUpdateCardWithNoSelectedCard() {
        let initialCards = vm.cards.map { $0.masteryRate }

        vm.updateCard()

        for (index, card) in vm.cards.enumerated() {
            XCTAssertEqual(card.masteryRate, initialCards[index])
        }
    }

    func testChangeMasteryRateInvalidInput() {
        let initialMasteryRates = vm.selectedCards.map { $0.masteryRate }
        
        vm.selectedRateString = "Unknown"
        vm.changeMasteryRate()

        for (index, card) in vm.selectedCards.enumerated() {
            XCTAssertEqual(card.masteryRate, initialMasteryRates[index])
        }
    }

    func testDeleteCardWithNoSelectedCard() {
        let initialCardCount = vm.cards.count
        vm.deleteCard()
        XCTAssertEqual(initialCardCount, vm.cards.count)
    }
    
    func testDeleteCard() {
        let expectation = XCTestExpectation(description: "Delete card")
        
        let card = Card()
        vm.selectedCard = card
        vm.deleteCard()
        
        DispatchQueue.main.async {
            self.vm.updateCardList()
            XCTAssertFalse(self.vm.cards.contains(where: { $0 == card }))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testUpdateCardList() {
        let card1 = Card()
        card1.category = MockHelper.shared.mockCategory
        let card2 = Card()
        card2.category = MockHelper.shared.mockCategory
        let card3 = Card()
        card3.category = MockHelper.shared.mockCategory
        
        vm.categoryName = MockHelper.shared.mockCategory
        vm.updateCardList()
        
        XCTAssertEqual(vm.cardList.count, 103)
    }

    func testSearchBarFiltering() {
        let card1 = Card()
        card1.category = MockHelper.shared.mockCategory
        let card2 = Card()
        card2.category = MockHelper.shared.mockCategory
        let card3 = Card()
        card3.category = MockHelper.shared.mockCategory
        
        card1.text = "Apple"
        card2.text = "Banana"
        card3.text = "Cherry"
        
        vm.categoryName = MockHelper.shared.mockCategory
        vm.searchBarText = "App"
        vm.updateCardList()
        
        XCTAssertEqual(vm.cardList.count, 1)
        XCTAssertEqual(vm.cardList.first?.text, "Apple")
    }
}
