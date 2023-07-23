//
//  FilterViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/5/23.
//

import SwiftUI

class FilterViewModel: ObservableObject {
    static let shared = FilterViewModel()
    
    private var userDefaults: UserDefaults

    @Published var selectedCategories: [String] {
        didSet {
            if let encoded = try? JSONEncoder().encode(selectedCategories) {
                userDefaults.set(encoded, forKey: "selectedCategories")
            }
        }
    }
    
    @Published var filterStatus: [Int16] {
        didSet {
            if let encoded = try? JSONEncoder().encode(filterStatus) {
                userDefaults.set(encoded, forKey: "filterStatus")
            }
        }
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        if let data = userDefaults.data(forKey: "selectedCategories"),
           let categories = try? JSONDecoder().decode([String].self, from: data) {
            self.selectedCategories = categories
        } else {
            self.selectedCategories = []
        }
        
        if let data = userDefaults.data(forKey: "filterStatus"),
           let status = try? JSONDecoder().decode([Int16].self, from: data) {
            self.filterStatus = status
        } else {
            self.filterStatus = [0, 1, 2]
        }
    }
}
