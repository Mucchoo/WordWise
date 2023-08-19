//
//  AlertControllerView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/15/23.
//

import SwiftUI
import UIKit

struct PickerAlert: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String?
    let message: String?
    let categories: [String]
    @Binding var selectedCategory: String
    let onConfirm: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented, context.coordinator.alertController == nil {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let pickerView = UIPickerView()
            pickerView.dataSource = context.coordinator
            pickerView.delegate = context.coordinator

            let pickerViewController = UIViewController()
            pickerViewController.view = pickerView
            pickerViewController.preferredContentSize = CGSize(width: 250, height: 150)

            alert.setValue(pickerViewController, forKey: "contentViewController")
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                isPresented = false
                context.coordinator.alertController = nil
                onConfirm()
            })

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                isPresented = false
                context.coordinator.alertController = nil
            })

            context.coordinator.alertController = alert
            uiViewController.present(alert, animated: true) {
                context.coordinator.alertController = nil
            }
        } else if !isPresented, let alertController = context.coordinator.alertController, alertController.isBeingPresented {
            alertController.dismiss(animated: true) {
                context.coordinator.alertController = nil
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PickerAlert
        var alertController: UIAlertController?
        var pickerView: UIPickerView?

        init(_ parent: PickerAlert) {
            self.parent = parent
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.categories.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            parent.categories[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selectedCategory = parent.categories[row]
        }
    }
}
