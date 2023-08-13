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
    @AppStorage("nativeLanguage") private var nativeLanguage = "JA"

    @State private var mailData = Email(subject: "Feedback", recipients: ["yazujumusa@gmail.com"], message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line! Thank you!")
    private var productURL = URL(string: "https://itunes.apple.com/jp/app/id1628829703?mt=8")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        MasteryRateBars()
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

#Preview {
    AccountView()
        .injectMockDataViewModelForPreview()
}
