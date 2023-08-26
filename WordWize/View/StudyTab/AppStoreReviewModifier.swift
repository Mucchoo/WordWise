//
//  AppStoreReviewModifier.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/28/23.
//

import SwiftUI
import StoreKit

struct AppStoreReviewModifier: ViewModifier {
    @Binding var showReviewRequest: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: showReviewRequest) { newValue in
                if newValue {
                    SKStoreReviewController.requestReview()
                    showReviewRequest = false
                }
            }
    }
}

extension View {
    func appStoreReviewModifier(showReviewRequest: Binding<Bool>) -> some View {
        self.modifier(AppStoreReviewModifier(showReviewRequest: showReviewRequest))
    }
}
