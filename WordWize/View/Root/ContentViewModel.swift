//
//  ContentViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/26/23.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var selectedTab = TabType.study.rawValue
    @Published var showTabBar = true
    @Published var tabPoints: [CGFloat] = Array(repeating: 0, count: TabType.allCases.count)
    
    init(container: DIContainer) {
        self.container = container
    }
}
