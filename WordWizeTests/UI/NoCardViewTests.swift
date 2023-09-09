//
//  NoCardViewTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import WordWize

final class NoCardViewTests: XCTestCase {
    
    private let boyLeft = "BoyLeft"
    var sut: NoCardView!
    
    override func setUp() {
        super.setUp()
        sut = .init(image: boyLeft)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testFindImage() throws {
        XCTAssertNoThrow(try sut.inspect().vStack().zStack(1).vStack(1).image(0))
    }
    
    func testFindText() throws {
        XCTAssertNoThrow(try sut.inspect().vStack().zStack(1).vStack(1).text(1).string())
    }
}
