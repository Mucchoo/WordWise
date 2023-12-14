//
//  CardsViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/13/23.
//

import XCTest
@testable import WordWise

class CardsViewModelTests: XCTestCase {
    
    func testInitializeWithTodaysType() {
        let vm = CardsViewModel(container: .mock(withMockCards: false), type: .todays)
        XCTAssertEqual(vm.title, "Todays Cards")
        XCTAssertEqual(vm.cards.count, 0)
    }
    
    func testInitializeWithUpcomingType() {
        let vm = CardsViewModel(container: .mock(withMockCards: false), type: .upcoming)
        XCTAssertEqual(vm.title, "Upcoming Cards")
        XCTAssertEqual(vm.cards.count, 0)
    }
    
    func testGetRemainingDays() {
        let vm = CardsViewModel(container: .mock(), type: .todays)
        
        let today = Date()
        let tomorrow = today.addingTimeInterval(90000)
        
        XCTAssertEqual(vm.getRemainingDays(today), "1 day left")
        XCTAssertEqual(vm.getRemainingDays(tomorrow), "2 days left")
        XCTAssertEqual(vm.getRemainingDays(nil), "")
    }
}
