//
//  MailView.swift
//  WordWise
//
//  Created by Musa Yazici on 9/11/23.
//

import UIKit
import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
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

struct ActivityViewController: UIViewControllerRepresentable {
    var shareItems: [Any]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
