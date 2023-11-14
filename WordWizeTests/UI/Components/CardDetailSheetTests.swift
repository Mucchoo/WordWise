//
//  CardDetailSheetTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/11/23.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import WordWize

class CardDetailSheetTests: XCTestCase {
    
    var sut: CardDetailSheet!
    var didTapDelete = false
    var didTapUpdate = false
    
    override func setUp() {
        super.setUp()
        
        let container: DIContainer = .mock()
        let card = Card(context: container.context)
        card.text = "Card Text"
        card.masteryRate = 0
        card.category = MockHelper.shared.mockCategory
        
        sut = .init(
            selectedCard: .constant(card),
            categoryName: .constant(MockHelper.shared.mockCategory),
            selectedRate: .constant(0),
            container: .mock(),
            updateCard: { self.didTapUpdate = true },
            deleteCard: { self.didTapDelete = true })
    }
    
    override func tearDown() {
        sut = nil
        didTapDelete = false
        didTapUpdate = false
        super.tearDown()
    }
    
    func testCardDetailLayout() throws {
        let innerVStack = try sut.inspect().vStack().vStack(0)
        
        let nameText = try innerVStack.hStack(0).text(0).string()
        XCTAssertEqual(nameText, "Name")
        
        let cardText = try innerVStack.hStack(0).text(2).string()
        XCTAssertEqual(cardText, "Card Text")
        
        let categoryText = try innerVStack.hStack(2).text(0).string()
        XCTAssertEqual(categoryText, "Category")
        
        let masteryRateText = try innerVStack.hStack(4).text(0).string()
        XCTAssertEqual(masteryRateText, "Mastery Rate")
        
        let deleteButtonText = try sut.inspect().vStack().button(1).labelView().text().string()
        XCTAssertEqual(deleteButtonText, "Delete Card")
    }
    
    func testDeleteButtonTap() throws {
        try sut.inspect().vStack().button(1).tap()
        XCTAssertTrue(didTapDelete)
    }
    
    func testCategoryPickerSelection() throws {
        let picker = try sut.inspect().vStack().vStack(0).hStack(2).picker(2)
        let categories = try picker.forEach(0).text(0).string()
        
        XCTAssertEqual(categories, MockHelper.shared.mockCategory)
    }
    
    func testMasteryRatePickerSelection() throws {
        let picker = try sut.inspect().vStack().vStack(0).hStack(4).picker(2)
        let rateOptions = MasteryRate.allValues.map { $0.rawValue }
        
        XCTAssertNoThrow(try rateOptions.forEach { option in
            try picker.select(value: option)
        })
        
        let selectedRate = try picker.forEach(0).text(0).string()
        XCTAssertEqual(selectedRate, "0%")
    }
    
    func testOnDisappear() throws {
        let view = try sut.inspect().vStack()
        try view.callOnDisappear()
        XCTAssertTrue(didTapUpdate)
    }
}
