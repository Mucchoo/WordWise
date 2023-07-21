//
//  AccountView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @State private var isActive = false
    @State private var isShowingAlert = false
    @State var isShowingReauthenticate = false
    @State var isShowingTutorial = false
    @State var isShowingMail = false
    @State var showingResetAlert = false
    @State var showingShareSheet = false
    @State private var mailData = Email(subject: "Feedback", recipients: ["yazujumusa@gmail.com"], message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line! Thank you!")
    private var productURL = URL(string: "https://itunes.apple.com/jp/app/id1628829703?mt=8")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("\(Image(systemName: "apple.logo")) yazujumusa") + Text("@icloud.com")
                            .foregroundColor(.primary)
                            .accessibilityLabel("emailAddressText")
                        Spacer()
                    }
                    .modifier(BlurBackground())
                    
                    VStack {
                        VStack(spacing: 8) {
                            ChartBarView(status: 0, image: "checkmark", colors: [.black, .navy])
                            ChartBarView(status: 1, image: "flame.fill", colors: [.navy, .ocean])
                            ChartBarView(status: 2, image: "star.fill", colors: [.ocean, .teal])
                        }
                    }
                    .modifier(BlurBackground())
                    
                    VStack {
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            HStack {
                                Text("\(Image(systemName: "square.and.arrow.up")) Share App")
                                Spacer()
                            }
                        }
                        .accessibilityIdentifier("shareButton")
                        .sheet(isPresented: $showingShareSheet) {
                            ActivityViewController(shareItems: [productURL])
                        }

                        Divider()
                            .padding(.horizontal)
                        
                        Button {
                            isShowingMail = true
                        } label: {
                            HStack {
                                Text("\(Image(systemName: "envelope")) Feedback")
                                Spacer()
                            }
                        }
                        .accessibilityIdentifier("feedbackButton")
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
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
