//
//  AddCardViewTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import WordWise

class AddCardViewTests: XCTestCase {

    var vm: AddCardViewModel!
    var sut: AddCardView!
    
    @MainActor override func setUp() {
        super.setUp()
        vm = AddCardViewModel(container: .mock())
        sut = AddCardView(vm: vm)
    }
    
    override func tearDown() {
        vm = nil
        sut = nil
        super.tearDown()
    }
        
    func testCategoryPickerIsVisible() throws {
        XCTAssertNoThrow(try sut.inspect().find(ViewType.Picker.self))
    }

    func testAddCategoryButtonIsVisible() throws {
        XCTAssertNoThrow(try sut.inspect().find(button: "Add Category"))
    }
    
    func testTextEditorIsVisible() throws {
        XCTAssertNoThrow(try sut.inspect().find(ViewType.TextEditor.self))
    }
    
    func testGenerateButtonIsVisible() throws {
        XCTAssertNoThrow(try sut.inspect().find(button: "Add 0 Cards"))
    }
    
    func testCategoryPickerShowsCategories() throws {
        let picker = try sut.inspect().find(ViewType.Picker.self).find(ViewType.ForEach.self)
        XCTAssertEqual(picker.count, vm.container.appState.categories.count)
    }
    
    func testProgressAlertContentDisplaysGeneratingCards() throws {
        vm.fetchedWordCount = 5
        vm.requestedWordCount = 10
        
        let progressAlertContent = ProgressAlertContent(vm: self.vm)
        let text = try progressAlertContent.inspect().vStack().text(0).string()
        XCTAssertEqual(text, "Generating Cards...")
    }

    func testProgressAlertContentDisplaysCorrectProgressCount() throws {
        vm.fetchedWordCount = 5
        vm.requestedWordCount = 10
        
        let progressAlertContent = ProgressAlertContent(vm: self.vm)
        let text = try progressAlertContent.inspect().vStack().text(1).string()
        XCTAssertEqual(text, "5 / 10 Completed")
    }
}
