//
//  AlertControllerView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/15/23.
//

import SwiftUI
import UIKit

struct AlertControllerView<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String?
    let message: String?
    let content: Content
    let onDismiss: (() -> Void)?
    var customAction: UIAlertAction?

    init(isPresented: Binding<Bool>, title: String?, message: String?, @ViewBuilder content: @escaping () -> Content, customAction: UIAlertAction? = nil, onDismiss: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.content = content()
        self.customAction = customAction
        self.onDismiss = onDismiss
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard context.coordinator.isAlertBeingPresented == false else { return }
        
        if !isPresented {
            if let alertController = context.coordinator.alertController,
               alertController.isBeingPresented {
                uiViewController.dismiss(animated: true, completion: nil)
            }
            return
        }

        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.setValue(hostingController, forKey: "contentViewController")
        
        if let action = customAction {
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            isPresented = false
            onDismiss?()
        })
        
        context.coordinator.alertController = alert

        DispatchQueue.main.async {
            context.coordinator.isAlertBeingPresented = true
            uiViewController.present(alert, animated: true) {
                context.coordinator.isAlertBeingPresented = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator {
        var parent: AlertControllerView
        var isAlertBeingPresented = false
        var alertController: UIAlertController?

        init(_ parent: AlertControllerView) {
            self.parent = parent
        }
    }
}
