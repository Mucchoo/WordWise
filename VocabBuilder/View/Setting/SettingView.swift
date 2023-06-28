//
//  SettingView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @ObservedObject private var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    @State private var isShowingAlert = false
    @State var isShowingReauthenticate = false
    @State var isShowingTutorial = false
    @State var isShowingMail = false
    @State var showingResetAlert = false
    @State private var mailData = Email(subject: "Feedback", recipients: ["yazujumusa@gmail.com"], message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line! Thank you!")
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 20)
                
                VStack(spacing: 8) {
                    Button {
                        viewModel.shareApp()
                    } label: {
                        SettingListRowView(icon: "square.and.arrow.up", firstText: "Share App")
                    }
                    
                    Button {
                        isShowingMail = true
                    } label: {
                        SettingListRowView(icon: "envelope", firstText: "Feedback")
                    }
                    .sheet(isPresented: $isShowingMail) {
                        MailView(data: $mailData) { result in }
                    }
                    
                    Button(action: {
                        isShowingAlert = true
                    }) {
                        SettingListRowView(icon: "rectangle.portrait.and.arrow.right", firstText: "Log out", showDevider: false)
                    }
                    .alert(isPresented: $isShowingAlert) {
                        return Alert(title: Text("Are you sure?"), message: Text(""), primaryButton: .cancel(), secondaryButton: .destructive(Text("Log out"), action: {
                            dismiss()
                        }))
                    }
                    
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        Text("Reset Leaning Data")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .alert("Are you sure to reset all the learning data?", isPresented: $showingResetAlert) {
                        Button("Reset", role: .destructive, action: resetLearningData)
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Failed times and the status of all cards will be reset.")
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Account Settings", displayMode: .large)
        }
    }
    
    private func resetLearningData() {
        cards.forEach { card in
            card.failedTimes = 0
            card.status = 2
        }
        PersistenceController.shared.saveContext()
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
