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
    @EnvironmentObject var dataViewModel: DataViewModel
    @State private var isActive = false
    @State private var isShowingAlert = false
    @State var isShowingReauthenticate = false
    @State var isShowingTutorial = false
    @State var isShowingMail = false
    @State var showingResetAlert = false
    @State var showingShareSheet = false
    @AppStorage("nativeLanguage") private var nativeLanguage = "JA"

    @State private var mailData = MailView.Email(subject: "Feedback", recipients: ["yazujumusa@gmail.com"], message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line. Thank you!")
    private var productURL = URL(string: "https://itunes.apple.com/jp/app/id1628829703?mt=8")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        MasteryRateBars(categoryName: "")
                    }
                    .modifier(BlurBackground())
                    
                    VStack {
                        HStack {
                            Text("Native Language")
                            Spacer()
                            Picker(selection: $nativeLanguage, label: EmptyView(), content: {
                                    ForEach(PickerOptions.language, id: \.self) { language in
                                        Text(language.name).tag(language.code)
                                    }
                                }
                            )
                            .cornerRadius(15)
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Divider()
                        
                        HStack {
                            NavigationLink("What is Mastery Rate?", destination: WhatIsMasteryRateView())
                                .padding(.vertical, 8)
                            Spacer()
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            HStack {
                                Text("\(Image(systemName: "square.and.arrow.up")) Share App")
                                Spacer()
                            }
                        }
                        .accessibilityIdentifier("shareButton")
                        .padding(.vertical, 8)
                        .sheet(isPresented: $showingShareSheet) {
                            ActivityViewController(shareItems: [productURL])
                        }

                        Divider()
                        
                        Button {
                            isShowingMail = true
                        } label: {
                            HStack {
                                Text("\(Image(systemName: "envelope")) Feedback")
                                Spacer()
                            }
                        }
                        .accessibilityIdentifier("feedbackButton")
                        .padding(.vertical, 8)
                        .sheet(isPresented: $isShowingMail) {
                            MailView(data: $mailData) { result in }
                        }
                    }
                    .modifier(BlurBackground())

                    HStack {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            Text("\(Image(systemName: "trash")) Reset Leaning Data")
                                .foregroundColor(.red)
                                .cornerRadius(10)
                        }
                        .accessibilityIdentifier("resetLearningDataButton")
                        .alert("Are you sure to reset all the learning data?", isPresented: $showingResetAlert) {
                            Button("Reset", role: .destructive, action: dataViewModel.resetLearningData)
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Failed times and the status of all cards will be reset.")
                        }
                        
                        Spacer()
                    }
                    .modifier(BlurBackground())
                }
            }
            .background(BackgroundView())
            .navigationBarTitle("Account", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    @Binding var data: Email
    let callback: Callback
    
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
        vc.setSubject(data.subject)
        vc.setToRecipients(data.recipients)
        vc.setMessageBody(data.message, isHTML: false)
        return vc
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation, data: $data, callback: callback)
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

#Preview {
    AccountView()
        .injectMockDataViewModelForPreview()
}
