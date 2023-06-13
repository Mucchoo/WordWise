//
//  SettingView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject private var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    @State private var isShowingAlert = false
    @State var isShowingReauthenticate = false
    @State var isShowingTutorial = false
    @State var isShowingMail = false
    @State private var mailData = Email(subject: "Feedback", recipients: ["yazujumusa@gmail.com"], message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line! Thank you!")
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 20)
                
                VStack(spacing: 8) {
                    Button {
                        viewModel.shareApp()
                    } label: {
                        ListRowView(icon: "square.and.arrow.up", firstText: "Share App")
                    }
                    
                    Button {
                        isShowingMail = true
                    } label: {
                        ListRowView(icon: "envelope", firstText: "Feedback")
                    }
                    .sheet(isPresented: $isShowingMail) {
                        MailView(data: $mailData) { result in }
                    }
                    
                    Button {
                        isShowingReauthenticate = true
                    } label: {
                        ListRowView(icon: "person", firstText: "Change Account Info")
                    }
                    .sheet(isPresented: $isShowingReauthenticate) {
                        ReauthenticateView()
                    }
                    
                    Button(action: {
                        isShowingAlert = true
                    }) {
                        ListRowView(icon: "rectangle.portrait.and.arrow.right", firstText: "Log out", showDevider: false)
                    }
                    .alert(isPresented: $isShowingAlert) {
                        return Alert(title: Text("Are you sure?"), message: Text(""), primaryButton: .cancel(), secondaryButton: .destructive(Text("Log out"), action: {
                            dismiss()
                        }))
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Account Settings", displayMode: .large)
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
