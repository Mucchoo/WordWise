//
//  NoCardViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/28/23.
//

import SwiftUI
import Combine

class NoCardViewModel: ObservableObject {
    @Published var animate: Bool = false
    private var timer: Timer? = nil
    
    init() {
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            self?.animate.toggle()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
