//
//  ActivityViewController.swift
//  VocabAI
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {
    var shareItems: [Any]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
