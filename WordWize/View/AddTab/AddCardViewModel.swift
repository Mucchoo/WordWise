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
    
    func addCategory(name: String) {
        dataViewModel.addCategory(name: name)
        selectedCategory = name
    }
    
    func shouldDisableAddCardButton() -> Bool {
        return cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
