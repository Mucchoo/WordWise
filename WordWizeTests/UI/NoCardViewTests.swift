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
    
    func testRandomOffsetWithinBounds() {
        for _ in 1...100 {
            let offset = CGSize.randomOffset()
            let horizontalRange = UIScreen.main.bounds.width / 2 + 100
            let verticalRange = UIScreen.main.bounds.height / 2 + 100

            XCTAssertGreaterThanOrEqual(offset.width, -horizontalRange)
            XCTAssertLessThanOrEqual(offset.width, horizontalRange)

            XCTAssertGreaterThanOrEqual(offset.height, -verticalRange)
            XCTAssertLessThanOrEqual(offset.height, verticalRange)
        }
    }
}
