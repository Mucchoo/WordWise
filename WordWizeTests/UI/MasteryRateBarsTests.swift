//
//  MasteryRateBarsTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import WordWize

class MasteryRateBarsTests: XCTestCase {

    var viewModel: MasteryRateBarsViewModel!
    var sut: MasteryRateBars!
    
    override func setUp() {
        super.setUp()
        viewModel = .init(container: .mock(), categoryName: MockHelper.shared.mockCategory)
        sut = MasteryRateBars(vm: viewModel)
    }
    
    override func tearDown() {
        viewModel = nil
        sut = nil
        super.tearDown()
    }
    
    func testAllMasteryRateBarsArePresent() throws {
        XCTAssertEqual(try sut.inspect().geometryReader().vStack().count, 5)
    }
}

