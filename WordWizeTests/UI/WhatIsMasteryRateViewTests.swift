//
//  WhatIsMasteryRateViewTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import WordWize

final class WhatIsMasteryRateViewTests: XCTestCase {
    
    var sut: WhatIsMasteryRateView!
    
    override func setUp() {
        super.setUp()
        sut = .init()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testTextsDisplayCorrectly() throws {
        let firstText = try sut.inspect().scrollView().vStack().vStack(0).text(0).string()
        XCTAssertEqual(firstText, "Mastery Rate is the level of memory retention based on the forgetting curve theory.")
        
        let secondText = try sut.inspect().scrollView().vStack().vStack(0).text(2).string()
        XCTAssertEqual(secondText, "When you see a card, you have two choices:")
    }
    
    func testImageExists() throws {
        XCTAssertNoThrow(try sut.inspect().scrollView().vStack().vStack(0).image(1))
    }
    
    func testTableHasCorrectData() throws {
        let vStack = try sut.inspect().scrollView().vStack().vStack(1)
        
        let expectedRates = ["Mastery Rate", "0%", "25%", "50%", "75%", "100%"]
        let expectedIntervals = ["Intervals", "1 day", "2 days", "4 days", "1 week", "2 weeks"]
        
        for (index, (expectedRate, expectedInterval)) in zip(expectedRates, expectedIntervals).enumerated() {
            let rowRate = try vStack.vStack(index).hStack(0).text(0).string()
            let rowInterval = try vStack.vStack(index).hStack(0).text(2).string()
            XCTAssertEqual(rowRate, expectedRate)
            XCTAssertEqual(rowInterval, expectedInterval)
        }
    }
    
    func testGradientColorsOnButton() throws {
        let hStack = try sut.inspect().scrollView().vStack().vStack(0).hStack(3)
        XCTAssertNoThrow(try hStack.text(0))
        XCTAssertNoThrow(try hStack.text(1))
    }
}
