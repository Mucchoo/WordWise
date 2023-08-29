//
//  AccountView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI
import UIKit
import MessageUI

struct AccountView: View {
    @StateObject private var viewModel: AccountViewModel
    
    init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: .init(container: container))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    MasteryRateBars(container: viewModel.container, categoryName: "")
                        .blurBackground()
                    
                    VStack {
                        nativeLanguageView
                        Divider()
                        navigationLinkView
                        Divider()
                        shareAppView
                        Divider()
                        feedbackView
                    }
                    .blurBackground()
                    
                    resetLearningDataView
                        .blurBackground()
                }
            }
            .gradientBackground()
            .navigationBarTitle("Account", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var nativeLanguageView: some View {
        HStack {
            Text("Native Language")
            Spacer()
            Picker(selection: $viewModel.nativeLanguage, label: EmptyView(), content: {
                    ForEach(PickerOptions.language, id: \.self) { language in
                        Text(language.name).tag(language.code)
                    }
                }
            )
            .cornerRadius(15)
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private var navigationLinkView: some View {
        HStack {
            NavigationLink("What is Mastery Rate?", destination: WhatIsMasteryRateView())
                .padding(.vertical, 8)
            Spacer()
        }
    }
    
    private var shareAppView: some View {
        Button(action: viewModel.showShareSheet) {
            HStack {
                Text("\(Image(systemName: "square.and.arrow.up")) Share App")
                Spacer()
            }
        }
        .accessibilityIdentifier("shareButton")
        .padding(.vertical, 8)
        .sheet(isPresented: $viewModel.isShowingShareSheet) {
            ActivityViewController(shareItems: [viewModel.productURL])
        }
    }
    
    private var feedbackView: some View {
        Button(action: viewModel.showMail) {
            HStack {
                Text("\(Image(systemName: "envelope")) Feedback")
                Spacer()
            }
        }
        .accessibilityIdentifier("feedbackButton")
        .padding(.vertical, 8)
        .sheet(isPresented: $viewModel.isShowingMail) {
            MailView() { result in }
        }
    }
    
    private var resetLearningDataView: some View {
        HStack {
            Button(action: viewModel.showResetAlert) {
                Text("\(Image(systemName: "trash")) Reset Learning Data")
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("resetLearningDataButton")
            .alert("Are you sure to reset all the learning data?", isPresented: $viewModel.showingResetAlert) {
                Button("Reset", role: .destructive, action: viewModel.resetLearningData)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Failed times and the status of all cards will be reset.")
            }
            
            Spacer()
        }
    }
}


private struct MailView: UIViewControllerRepresentable {
    typealias Callback = ((Result<MFMailComposeResult, Error>) -> Void)?
    
    struct Email {
      let subject: String
      let recipients: [String]?
      let message: String
    }
    
    @Environment(\.presentationMode) var presentation
    let callback: Callback
    @State var mailData = Email(
        subject: "Feedback",
        recipients: ["yazujumusa@gmail.com"],
        message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line. Thank you!")
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var data: Email
        let callback: Callback
        
        init(presentation: Binding<PresentationMode>, data: Binding<Email>, callback: Callback) {
            _presentation = presentation
            _data = data
            self.callback = callback
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                callback?(.failure(error))
            } else {
                callback?(.success(result))
            }
            $presentation.wrappedValue.dismiss()
        }
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(mailData.subject)
        vc.setToRecipients(mailData.recipients)
        vc.setMessageBody(mailData.message, isHTML: false)
        return vc
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation, data: $mailData, callback: callback)
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {}
}

private struct ActivityViewController: UIViewControllerRepresentable {
    var shareItems: [Any]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

//#Preview {
//    AccountView()
//        .injectMockDataViewModelForPreview()
//}
