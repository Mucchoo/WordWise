//
//  ReviewController.swift
//  WordWize
//
//  Created by Musa Yazuju on 9/5/23.
//

import Foundation
import StoreKit

protocol ReviewControllerProtocol {
    func requestReview(in scene: WindowSceneProviding?)
}

extension SKStoreReviewController: ReviewControllerProtocol {
    func requestReview(in scene: WindowSceneProviding?) {
        guard let uiWindowScene = scene as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: uiWindowScene)
    }
}
