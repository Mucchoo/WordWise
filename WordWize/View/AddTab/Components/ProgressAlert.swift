//
//  ProgressAlert.swift
//  WordWize
//
//  Created by Musa Yazici on 9/11/23.
//

import SwiftUI

struct ProgressAlert: UIViewControllerRepresentable {
    @ObservedObject var vm: AddCardViewModel
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ProgressAlert>) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ProgressAlert>) {
        if !isPresented {
            if let shownAlert = uiViewController.presentedViewController as? UIAlertController,
               shownAlert.title == nil {
                shownAlert.dismiss(animated: true)
            }
            
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let progressContentView = ProgressAlertContent(vm: vm)
        let hostingController = UIHostingController(rootView: progressContentView)

        hostingController.view.backgroundColor = .clear
        hostingController.preferredContentSize = CGSize(width: 250, height: 100)
        alert.setValue(hostingController, forKey: "contentViewController")

        DispatchQueue.main.async {
            if uiViewController.presentedViewController == nil {
                uiViewController.present(alert, animated: true)
            }
        }
    }
}

struct ProgressAlertContent: View {
    @StateObject var vm: AddCardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Generating Cards...")
                .font(.headline)
                .bold()
                .padding(.bottom)
            Text("\(vm.fetchedWordCount) / \(vm.requestedWordCount) Completed")
                .font(.footnote)
                .padding(.bottom)
            ProgressView(value: Float(vm.fetchedWordCount), total: Float(vm.requestedWordCount))
                .padding(.horizontal)
        }
    }
}
