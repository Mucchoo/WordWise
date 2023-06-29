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
            VStack {
                Spacer().frame(height: 20)
                
                VStack(spacing: 8) {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Color("orange"), Color("purple")]), startPoint: .top, endPoint: .bottom)
                            .cornerRadius(10)
                            .clipped()

                        HStack {
                            Spacer().frame(width: 15)
                            Image(systemName: "person.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            HStack {
                                Text("yazujumusa") + Text("@icloud.com")
                            }
                            .foregroundColor(.white)
                            .font(.body)
                            .fontWeight(.bold)
                            
                            Spacer()
                        }
                    }
                    .frame(height: 70)
                    .padding(.horizontal)
                    
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
