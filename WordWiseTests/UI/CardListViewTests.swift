//
//  CardListViewTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/10/23.
//

//import XCTest
//import ViewInspector
//import SwiftUI
//@testable import WordWise
//
//class CardListViewTests: XCTestCase {
//    
//    var vm: CardListViewModel!
//    var sut: CardListView!
//    
//    @MainActor override func setUp() {
//        super.setUp()
//        vm = .init(container: .mock(), category: MockHelper.mockCategory)
//        sut = CardListView(vm: vm)
//    }
//    
//    override func tearDown() {
//        vm = nil
//        sut = nil
//        super.tearDown()
//    }
//    
//    func testSearchBarIsVisible() throws {
//        let textField = try sut.inspect().find(ViewType.TextField.self)
//        XCTAssertEqual(try textField.input(), "")
//    }
//
//    func testCardsDisplay() throws {
//        let cardCount = try sut.inspect().find(ViewType.ForEach.self).count
//        XCTAssertEqual(cardCount, vm.cardList.count)
//    }
//
//    func testSelectModeButtonToggle() throws {
//        XCTAssertEqual(vm.multipleSelectionMode, false)
//        XCTAssertNoThrow(try sut.inspect().find(button: "Select"))
//    }
//
//    func testTextFieldIsLowerCase() throws {
//        let textField = try sut.inspect().find(ViewType.TextField.self)
//        XCTAssertEqual(try textField.input().lowercased(), try textField.input())
//    }
//
//    func testMenuActionsVisibility() throws {
//        vm.multipleSelectionMode = true
//        XCTAssertNoThrow(try sut.inspect().find(text: "Select Cards"))
//
//        vm.selectedCards = cards
//        let labelCount = try sut.inspect().findAll(ViewType.Label.self).count
//        XCTAssertEqual(labelCount, 3)
//    }
//
//    func testLazyVStackContainsForEach() throws {
//        let lazyVStack = try sut.inspect().find(ViewType.LazyVStack.self)
//        XCTAssertNoThrow(try lazyVStack.find(ViewType.ForEach.self))
//    }
//
//    func testSelectButtonChangesTitle() throws {
//        vm.multipleSelectionMode = false
//        let button = try sut.inspect().find(button: "Select")
//        try button.tap()
//        XCTAssertNoThrow(try sut.inspect().find(button: "Cancel"))
//    }
//
//    func testCardRowsHaveDividers() throws {
//        let forEeach = try sut.inspect().find(ViewType.ForEach.self)
//        for index in 0..<vm.cardList.count - 1 {
//            let cardRow = try forEeach[index].find(ViewType.VStack.self)
//            XCTAssertNotNil(try cardRow.find(ViewType.Divider.self))
//        }
//    }
//}
