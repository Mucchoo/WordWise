//
//  AddCardViewTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import WordWize

class AddCardViewTests: XCTestCase {

    var viewModel: AddCardViewModel!
    var sut: AddCardView!
    
    override func setUp() {
        super.setUp()
        viewModel = AddCardViewModel(container: .mock())
        sut = AddCardView(vm: viewModel)
    }
    
    override func tearDown() {
        viewModel = nil
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
        XCTAssertEqual(picker.count, viewModel.container.appState.categories.count)
    }
}
