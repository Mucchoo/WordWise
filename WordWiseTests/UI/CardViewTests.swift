//
//  CardViewTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import WordWise

final class CardViewTests: XCTestCase {
    @Environment(\.colorScheme) private var colorScheme

    var vm: CardViewModel!
    var sut: CardView!
    
    override func setUp() {
        super.setUp()
        vm = .init(container: .mock())
        sut = .init(vm: vm, showingCardView: .constant(true))
    }
    
    override func tearDown() {
        vm = nil
        sut = nil
        super.tearDown()
    }
    
    func testDismissBar() throws {
        let bar = try sut.inspect().vStack().find(viewWithAccessibilityIdentifier: "dismissBar")
        XCTAssertEqual(try bar.fixedFrame().height, 8)
        XCTAssertEqual(try bar.fixedFrame().width, 60)
        XCTAssertNoThrow(try bar.gesture(DragGesture.self))
    }
    
    func testProgressBar() throws {
        let bar = try sut.inspect().vStack().geometryReader(1)
        XCTAssertEqual(try bar.cornerRadius(), 5)
        XCTAssertEqual(try bar.fixedHeight(), 10)
        
        XCTAssertNoThrow(try bar.find(viewWithAccessibilityIdentifier: "progressBarBackgroundRectangle"))
        XCTAssertNoThrow(try bar.find(viewWithAccessibilityIdentifier: "progressBarForegroundRectangle"))
    }
    
    func testWordInfoSection() throws {
        let section = try sut.inspect().vStack().zStack(3)
        
        let rectangle = try section.find(viewWithAccessibilityIdentifier: "coverRectangle")
        XCTAssertEqual(try rectangle.opacity(), vm.isDefinitionVisible ? 0 : 1)
        
        let scrollView = try section.scrollView(1)
        XCTAssertEqual(try scrollView.opacity(), vm.isFinished ? 0 : 1)
    }
    
    func testCompletionView() throws {
        let view = try sut.inspect().vStack().zStack(3).geometryReader(0)
        
        XCTAssertEqual(try view.vStack().text(0).string(), "Finished!")
        XCTAssertEqual(try view.vStack().image(1).actualImage().name(), "checkmark.circle")
        XCTAssertEqual(try view.vStack().text(2).string(), "You've learned \(vm.learningCards.count) cards")
                
        let expectedColor = colorScheme == .dark ? Color.sky : Color.ocean
        XCTAssertEqual(try view.vStack().text(0).attributes().foregroundColor(), expectedColor)
        XCTAssertEqual(try view.vStack().image(1).foregroundColor(), expectedColor)
        XCTAssertEqual(try view.vStack().text(2).attributes().foregroundColor(), expectedColor)
        
        XCTAssertEqual(try view.vStack().opacity(), vm.isFinished ? 1 : 0)
    }
    
    func testWordSection() throws {
        let section = try sut.inspect().vStack().hStack(2)
        
        XCTAssertEqual(try section.vStack(2).text(0).string(), vm.currentCard.card.text ?? "")
        XCTAssertEqual(try section.vStack(2).text(1).string(), vm.currentCard.card.phonetics.first?.text ?? "")
        XCTAssertEqual(try section.vStack(2).opacity(), vm.isWordVisible ? 1 : 0)
        
        let deepLButton = try section.button(4)
        XCTAssertEqual(try deepLButton.opacity(), vm.isDefinitionVisible ? 1 : 0)
        XCTAssertEqual(try deepLButton.labelView().image().actualImage().name(), "DeepL")
    }
    
    func testDeepLLoadingView() throws {
        let expectation = self.expectation(description: "Wait for vm.translating to change")
            
        DispatchQueue.main.async {
            self.vm.translating = true
            expectation.fulfill()
        }
            
        waitForExpectations(timeout: 5, handler: nil)
        sut = CardView(vm: vm, showingCardView: .constant(true))
            
        let section = try sut.inspect().vStack().hStack(2)
        let deepLButton = try section.button(4)
        XCTAssertNoThrow(try deepLButton.labelView().progressView())
    }
    
    func testDefinitionSection() throws {
        let section = try sut.inspect().vStack().zStack(3).scrollView(1).scrollViewReader().vStack().zStack(1).vStack(0).vStack(0)
                
        let meaningsCount = vm.currentCard.card.meanings.count
        
        for idx in 0..<meaningsCount {
            let row = try section.forEach(0).tupleView(idx)
            
            if idx != 0 {
                XCTAssertNoThrow(try row.group(0))
            }
        }
    }
    
    func testImageSection() throws {
        let gridSize = (UIScreen.main.bounds.width - 21) / 2
        let section = try sut.inspect().vStack().zStack(3).scrollView(1).scrollViewReader().vStack().zStack(1).vStack(0).vStack(1)
        
        let innerVStack = try section.vStack(0)
        let firstHStack = try innerVStack.hStack(0)
        
        try testGridImage(hStack: firstHStack, imageCount: 2)
        
        if vm.currentCard.card.imageDatas.count > 2 {
            let secondHStack = try innerVStack.hStack(1)
            try testGridImage(hStack: secondHStack, imageCount: 2)
        }
        
        let expectedHeight = vm.currentCard.card.imageDatas.count > 2 ? gridSize * 2 + 2 : gridSize
        XCTAssertEqual(try innerVStack.fixedHeight(), expectedHeight)

        let pixabayText = try section.text(1)
        XCTAssertEqual(try pixabayText.string(), "Powered by Pixabay")
        XCTAssertEqual(try pixabayText.attributes().font(), Font.caption2)
        XCTAssertEqual(try pixabayText.attributes().foregroundColor(), Color.secondary)
    }

    func testGridImage(hStack: InspectableView<ViewType.HStack>, imageCount: Int) throws {
        for index in 0..<imageCount {
            let group = try hStack.group(index)
            
            if let imageData = vm.currentCard.card.imageDatas[safe: index]?.data, UIImage(data: imageData) != nil {
                XCTAssertNoThrow(try group.image(0))
            } else {
                XCTAssertNoThrow(try group.text(0))
            }
        }
    }
    
    func testDefinitionDetailView() throws {
        let definitionSection = try sut.inspect().vStack().zStack(3).scrollView(1).scrollViewReader().vStack().zStack(1).vStack(0).vStack(0)
        
        for index in vm.currentCard.card.meanings.indices {
              let detailView = try definitionSection.forEach(0).tupleView(0).vStack(1)
            
            let hStack = try detailView.hStack(0)
            let partOfSpeech = try hStack.text(0)
            XCTAssertEqual(try partOfSpeech.string(), vm.currentCard.card.meanings[index].partOfSpeech ?? "")
            
            for idx in vm.currentCard.card.meanings[index].definitionsArray.indices {
                let definition = vm.currentCard.card.meanings[index].definitionsArray[idx]
                
                let forEachVStack = try detailView.forEach(1).tupleView(0).vStack(1)
                let textString = try forEachVStack.text(0).string()
                XCTAssertEqual(textString, "\(idx + 1). \(vm.showTranslations ? definition.translatedDefinition ?? "" : definition.definition ?? "")")

                var viewIndex = 1
                if let example = definition.example, !example.isEmpty {
                    let exampleRow = try forEachVStack.group(viewIndex)
                    XCTAssertEqual(try exampleRow.text(1).string(), "Example: \(example)")
                    viewIndex += 1
                }
                
                if let synonyms = definition.synonyms, !synonyms.isEmpty {
                    let synonymsRow = try forEachVStack.group(viewIndex)
                    XCTAssertEqual(try synonymsRow.text(1).string(), "Synonyms: \(synonyms)")
                    viewIndex += 1
                }
                
                if let antonyms = definition.antonyms, !antonyms.isEmpty {
                    let antonymsRow = try forEachVStack.group(viewIndex)
                    XCTAssertEqual(try antonymsRow.text(1).string(), "Antonyms: \(antonyms)")
                }
            }
        }
    }
    
    func testBottomButtons() throws {
        let view = try sut.inspect().vStack().zStack(4)
        
        let goToTopPageButton = try view.button(0)
        XCTAssertEqual(try goToTopPageButton.opacity(), vm.isFinished ? 1.0 : 0.0)
        let goToTopPageText = try goToTopPageButton.labelView().text()
        XCTAssertEqual(try goToTopPageText.string(), "Go to Top Page")
        XCTAssertEqual(try goToTopPageText.attributes().foregroundColor(), .white)

        let hardButton = try view.hStack(1).button(0)
        let hardButtonText = try hardButton.labelView().text()
        XCTAssertEqual(try hardButtonText.string(), "Hard")
        XCTAssertEqual(try hardButtonText.attributes().foregroundColor(), .white)
        
        let easyButton = try view.hStack(1).button(1)
        let easyButtonText = try easyButton.labelView().text()
        XCTAssertEqual(try easyButtonText.string(), "Easy")
        XCTAssertEqual(try easyButtonText.attributes().foregroundColor(), .white)
    }
}
