//
//  WindowScene.swift
//  WordWise
//
//  Created by Musa Yazuju on 9/5/23.
//

import SwiftUI

protocol WindowSceneProviding {
    var activationState: UIScene.ActivationState { get }
}

extension UIWindowScene: WindowSceneProviding {}
