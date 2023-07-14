//
//  FilterViewModel.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/5/23.
//

import SwiftUI

class FilterViewModel: ObservableObject {
    static let shared = FilterViewModel()
    
    @Published var selectedCategories: [String] {
        didSet {
            if let encoded = try? JSONEncoder().encode(selectedCategories) {
                UserDefaults.standard.set(encoded, forKey: "selectedCategories")
            }
        }
    }
    
    @Published var filterStatus: [Int16] {
        didSet {
            if let encoded = try? JSONEncoder().encode(filterStatus) {
                UserDefaults.standard.set(encoded, forKey: "filterStatus")
            }
        }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: "selectedCategories"),
           let categories = try? JSONDecoder().decode([String].self, from: data) {
            self.selectedCategories = categories
        } else {
            self.selectedCategories = []
        }
        
        if let data = UserDefaults.standard.data(forKey: "filterStatus"),
           let status = try? JSONDecoder().decode([Int16].self, from: data) {
            self.filterStatus = status
        } else {
            self.filterStatus = [0, 1, 2]
        }
    }
}

