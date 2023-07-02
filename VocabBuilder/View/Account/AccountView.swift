//
//  AccountView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI

struct AccountView: View {
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @ObservedObject private var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    @State private var isShowingAlert = false
    @State var isShowingReauthenticate = false
    @State var isShowingTutorial = false
    @State var isShowingMail = false
    @State var showingResetAlert = false
    @Binding var initialAnimation: Bool
    @State private var mailData = Email(subject: "Feedback", recipients: ["yazujumusa@gmail.com"], message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line! Thank you!")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("\(Image(systemName: "apple.logo")) yazujumusa") + Text("@icloud.com")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background {
                        TransparentBlurView(removeAllLayers: true)
                            .blur(radius: 9, opaque: true)
                            .background(.white.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    VStack {
                        VStack(spacing: 8) {
                            ChartBarView(status: 0, name: "Learned", image: "checkmark", colors: [.black, Color("Navy")])
                            ChartBarView(status: 1, name: "Learning", image: "flame.fill", colors: [Color("Navy"), Color("Blue")])
                            ChartBarView(status: 2, name: "New", image: "star.fill", colors: [Color("Blue"), Color("Teal")])
                        }
                    }
                    .padding()
                    .background {
                        TransparentBlurView(removeAllLayers: true)
                            .blur(radius: 9, opaque: true)
                            .background(.white.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    VStack {
                        Button {
                            viewModel.shareApp()
                        } label: {
                            HStack {
                                Text("\(Image(systemName: "square.and.arrow.up")) Share App")
                                Spacer()
                            }
                        }
                        .padding([.horizontal, .top])

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
                        .padding([.horizontal, .bottom])
                        .sheet(isPresented: $isShowingMail) {
                            MailView(data: $mailData) { result in }
                        }
                    }
                    .background {
                        TransparentBlurView(removeAllLayers: true)
                            .blur(radius: 9, opaque: true)
                            .background(.white.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    HStack {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            Text("\(Image(systemName: "trash")) Reset Leaning Data")
                                .foregroundColor(.red)
                                .cornerRadius(10)
                        }
                        .alert("Are you sure to reset all the learning data?", isPresented: $showingResetAlert) {
                            Button("Reset", role: .destructive, action: CardManager.shared.resetLearningData)
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Failed times and the status of all cards will be reset.")
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background {
                        TransparentBlurView(removeAllLayers: true)
                            .blur(radius: 9, opaque: true)
                            .background(.white.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
            }
            .background(BackgroundView(initialAnimation: $initialAnimation))
            .navigationBarTitle("Account", displayMode: .large)
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(initialAnimation: .constant(true))
    }
}
