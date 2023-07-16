//
//  AudioViewModelTests.swift
//  VocabAITests
//
//  Created by Musa Yazuju on 7/17/23.
//

import XCTest
import AVFoundation
@testable import VocabAI

class AudioViewModelTests: XCTestCase {

    var audioViewModel: AudioViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        audioViewModel = AudioViewModel.shared
    }

    override func tearDownWithError() throws {
        audioViewModel = nil
        try super.tearDownWithError()
    }

    func testSharedInstance() throws {
        XCTAssertNotNil(audioViewModel, "Shared instance should not be nil.")
    }

    func testSetCategoryToPlayback() throws {
        audioViewModel.setCategoryToPlayback()
    }
}
