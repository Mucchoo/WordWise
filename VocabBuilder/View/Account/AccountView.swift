//
//  AccountView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI

struct AccountView: View {
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
            List {
                Section {
                    Text("\(Image(systemName: "apple.logo")) yazujumusa") + Text("@icloud.com")
                        .foregroundColor(.primary)
                }
                
                Button {
                    viewModel.shareApp()
                } label: {
                    Text("\(Image(systemName: "square.and.arrow.up")) Share App")
                }
                
                Button {
                    isShowingMail = true
                } label: {
                    Text("\(Image(systemName: "envelope")) Feedback")
                }
                .sheet(isPresented: $isShowingMail) {
                    MailView(data: $mailData) { result in }
                }
                
                Section {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        Text("\(Image(systemName: "trash")) Reset Leaning Data")
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                    .alert("Are you sure to reset all the learning data?", isPresented: $showingResetAlert) {
                        Button("Reset", role: .destructive, action: resetLearningData)
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Failed times and the status of all cards will be reset.")
                    }
                }
            }
            .navigationBarTitle("Account", displayMode: .large)
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

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
