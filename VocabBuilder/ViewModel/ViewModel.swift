//
//  ViewModel.swift
//  VocabBuilder
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

class ViewModel: ObservableObject {
    @Published var showShareSheet = false
    var productURL = URL(string: "https://itunes.apple.com/jp/app/id1628829703?mt=8")!
    
    func shareApp() {
        showShareSheet = true
    }
}

struct ShareView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        Button(action: {
            viewModel.shareApp()
        }) {
            Text("Share App")
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ActivityViewController(shareItems: [viewModel.productURL])
        }
    }
}
