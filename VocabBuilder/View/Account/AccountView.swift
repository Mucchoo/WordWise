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
    @State private var mailData = Email(subject: "Feedback", recipients: ["yazujumusa@gmail.com"], message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line! Thank you!")
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("\(Image(systemName: "apple.logo")) yazujumusa") + Text("@icloud.com")
                        .foregroundColor(.primary)
                    VStack(spacing: 8) {
                        ChartBarView(status: 0, name: "Learned", image: "checkmark.circle.fill", color: .blue)
                        ChartBarView(status: 1, name: "Learning", image: "pencil.circle.fill", color: .red)
                        ChartBarView(status: 2, name: "New", image: "star.circle.fill", color: .yellow)
                    }
                }
                
                Section {
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

struct ChartBarView: View {
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @State var status: Int
    var name: String
    var image: String
    var color: Color
    
    @State private var progress: CGFloat = 0
    @State private var counter: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(color)
                    .frame(width: 55 + progress * (geometry.size.width - 55), height: 30)
                    .animation(.easeInOut(duration: 1))
                HStack(spacing: 2) {
                    Image(systemName: image)
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                    Text("\(counter)")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            .onAppear {
                let cardCount = cards.count
                let filteredCount = cards.filter { $0.status == status }.count
                
                progress = CGFloat(filteredCount) / CGFloat(cardCount)
                withAnimation(.easeInOut(duration: 2)) {
                    for i in 0...filteredCount {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) / 20.0) {
                            counter = i
                        }
                    }
                }
            }
        }
        .frame(height: 30)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
