//
//  AccountViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine

class AccountViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var nativeLanguage: String = "JA"
    @Published var isShowingReauthenticate: Bool = false
    @Published var isShowingTutorial: Bool = false
    @Published var isShowingMail: Bool = false
    @Published var isShowingShareSheet: Bool = false
    @Published var showingResetAlert: Bool = false
    
    let productURL = URL(string: "https://itunes.apple.com/jp/app/id1628829703?mt=8")!
    
    init(container: DIContainer) {
        self.container = container
    }

    func showShareSheet() {
        isShowingShareSheet = true
    }
    
    func showMail() {
        isShowingMail = true
    }
    
    func showResetAlert() {
        showingResetAlert = true
    }
    
    func resetLearningData() {
        container.appState.cards.forEach { card in
            card.masteryRate = 0
            card.lastHardDate = nil
            card.nextLearningDate = nil
        }
        container.coreDataService.saveAndReload()
    }
}
