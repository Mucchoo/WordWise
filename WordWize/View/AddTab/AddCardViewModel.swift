//
//  AddCardViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import Combine
import SwiftUI

class AddCardViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @Published var cardText: String = ""
    @Published var selectedCategory: String = ""
    @Published var generatingCards: Bool = false
    @Published var showingFetchFailedAlert = false
    @Published var showingAddCategoryAlert = false
    @Published var showingFetchSucceededAlert = false
    @Published var showPlaceholder = true
        
    private let placeHolder = "pineapple\nstrawberry\ncherry\nblueberry\npeach"

    var displayText: String {
        showPlaceholder ? placeHolder : cardText
    }
    
    func addCardPublisher() -> AnyCancellable {
        return dataViewModel.addCardPublisher(text: cardText, category: selectedCategory)
            .sink { [weak self] in
                self?.generatingCards = false
                
                if self?.dataViewModel.fetchFailedWords.isEmpty == true {
                    self?.showingFetchSucceededAlert = true
                } else {
                    self?.showingFetchFailedAlert = true
                }
            }
    }
    
    func generateCards() {
        let cancellable = addCardPublisher()
        cancellable.store(in: &dataViewModel.cancellables)

        cardText = ""
        generatingCards = true
    }
    
    func addCategory(name: String) {
        dataViewModel.addCategory(name: name)
        selectedCategory = name
    }
    
    func shouldDisableAddCardButton() -> Bool {
        return cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func updateTextEditor(text: String, isFocused: Bool) {
        cardText = text.lowercased()
        if cardText.isEmpty && !isFocused {
            showPlaceholder = true
        }
    }
    
    func togglePlaceHolder(_ isFocused: Bool) {
        showPlaceholder = !isFocused && (cardText.isEmpty || cardText == placeHolder)
    }
}
