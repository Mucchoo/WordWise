//
//  PickerAlert.swift
//  WordWize
//
//  Created by Musa Yazici on 9/11/23.
//

import SwiftUI

struct PickerAlert: UIViewControllerRepresentable {
    enum ViewType {
        case category, masteryRate
    }
    
    @ObservedObject var vm: CardListViewModel
    var title: String?
    var message: String?
    var options: [String] = []
    var onConfirm: (() -> ())?
    
    init(vm: CardListViewModel) {
        self.vm = vm
        
        guard let type = vm.pickerAlertType else { return }
        
        if type == .category {
            title = "Change Category"
            message = "Select new category for the \(vm.selectedCards.count) cards."
            options = vm.container.appState.categories.map { $0.name ?? "" }
            onConfirm = vm.changeCategory
        } else {
            title = "Change Mastery Rate"
            message = "Select Mastery Rate for the \(vm.selectedCards.count) cards."
            options = MasteryRate.allValues.map { $0.stringValue() + "%" }
            onConfirm = vm.changeMasteryRate
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let type = vm.pickerAlertType, context.coordinator.alertController == nil {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let pickerView = UIPickerView()
            pickerView.dataSource = context.coordinator
            pickerView.delegate = context.coordinator
            
            var newOptions: [String] = []
            if type == .category {
                newOptions = vm.container.appState.categories.map { $0.name ?? "" }
            } else {
                newOptions = MasteryRate.allValues.map { $0.stringValue() + "%" }
            }
            
            context.coordinator.optionsChanged(newOptions: newOptions)
            
            let pickerViewController = UIViewController()
            pickerViewController.view = pickerView
            pickerViewController.preferredContentSize = CGSize(width: 250, height: 150)
            
            alert.setValue(pickerViewController, forKey: "contentViewController")
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                vm.pickerAlertType = nil
                context.coordinator.alertController = nil
                onConfirm?()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                vm.pickerAlertType = nil
                context.coordinator.alertController = nil
            })
            
            context.coordinator.alertController = alert
            uiViewController.present(alert, animated: true) {
                context.coordinator.alertController = nil
            }
        } else if vm.pickerAlertType == nil, let alertController = context.coordinator.alertController, alertController.isBeingPresented {
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
            parent.options.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            parent.options[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.vm.pickerAlertValue = parent.options[row]
        }
        
        func optionsChanged(newOptions: [String]) {
            parent.options = newOptions
            pickerView?.reloadAllComponents()
        }
    }
}
