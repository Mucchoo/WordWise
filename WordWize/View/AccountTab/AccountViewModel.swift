//
//  AccountViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine

class AccountViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel

    @Published var nativeLanguage: String = "JA"
    @Published var isShowingReauthenticate: Bool = false
    @Published var isShowingTutorial: Bool = false
    @Published var isShowingMail: Bool = false
    @Published var isShowingShareSheet: Bool = false
    @Published var showingResetAlert: Bool = false
    
    let productURL = URL(string: "https://itunes.apple.com/jp/app/id1628829703?mt=8")!

    func showShareSheet() {
        isShowingShareSheet = true
    }
    
    func showMail() {
        isShowingMail = true
    }
    
    func showResetAlert() {
        showingResetAlert = true
    }
}
