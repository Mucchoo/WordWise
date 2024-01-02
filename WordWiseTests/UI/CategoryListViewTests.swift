//
//  CategoryListViewTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import WordWise

class CategoryListViewTests: XCTestCase {
    
    var vm: CategoryListViewModel!
    var sut: CategoryListView!
    
    @MainActor override func setUp() {
        super.setUp()
        vm = .init(container: .mock())
        sut = .init(vm: vm)
    }
    
    override func tearDown() {
        vm = nil
        sut = nil
        super.tearDown()
    }

    func testEmptyState() throws {
        categories = []
        XCTAssertNoThrow(try sut.inspect().find(NoCardView.self))
    }
    
    func testCategoryRowCount() throws {
        let rowCount = try sut.inspect().navigationView().scrollView().vStack().forEach(0).count
        XCTAssertEqual(rowCount, 1)
    }
    
    func testCategoryRow() throws {
        let categoryRow = try sut.inspect().navigationView().scrollView().vStack().forEach(0)[0]
                
        let menu = try categoryRow.zStack().hStack(1).vStack(1).menu(1)
        XCTAssertNoThrow(try menu.labelView().image(0))
        XCTAssertNoThrow(try menu.button(0))
        XCTAssertNoThrow(try menu.button(1))

        let displayedName = try categoryRow.zStack().navigationLink(0).labelView().vStack(0).hStack(0).text(0).string()
        XCTAssertEqual(displayedName, MockHelper.shared.mockCategory)
    }
}

