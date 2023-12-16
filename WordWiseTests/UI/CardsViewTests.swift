//
//  CardsViewTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import WordWise

class CardsViewTests: XCTestCase {

    var vm: CardsViewModel!
    var sut: CardsView!
    
    override func setUp() {
        super.setUp()
        vm = .init(container: .mock(), type: .upcoming)
        sut = CardsView(vm: vm)
    }
    
    override func tearDown() {
        vm = nil
        sut = nil
        super.tearDown()
    }
    
    func testScrollViewIsPresent() throws {
        XCTAssertNoThrow(try sut.inspect().vStack().scrollView(0))
    }
    
    func testCardRow() throws {
        let card = vm.cards.first!
        let view = sut.cardRow(card)
        
        XCTAssertEqual(try view.inspect().vStack().hStack(0).text(0).string(), card.text!)
        XCTAssertEqual(try view.inspect().vStack().hStack(0).text(2).string(), vm.getRemainingDays(card.nextLearningDate))
        XCTAssertEqual(try view.inspect().vStack().hStack(0).text(3).string(), card.rate.stringValue() + "%")
    }
}
