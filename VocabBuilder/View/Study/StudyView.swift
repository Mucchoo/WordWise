//
//  StudyView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @ObservedObject var dataViewModel = DataViewModel.shared
    @State private var showingCardView = false
    @State private var learnedButton = true
    @State private var learningButton = true
    @State private var newButton = true
    @State private var showingCategorySheet = false
    @State private var selectedCategories: [String] = []
    @State private var maximumCards = 10
    @State private var failedTimes = 0
    @State private var isFirstAppearance = true
    @State private var filterStatus: [Int16]  = [0, 1, 2]
    @State private var cardsToStudy: [Card] = []
    
    private func updateCardsToStudy() {
        let filteredCards = dataViewModel.cards.filter { card in
            let statusFilter = filterStatus.contains { $0 == card.status }
            let failedTimesFilter = card.failedTimes >= failedTimes
            let categoryFilter = selectedCategories.contains { $0 == card.category }
            return statusFilter && failedTimesFilter && categoryFilter
        }
        cardsToStudy = Array(filteredCards.prefix(maximumCards))
    }
    
    var body: some View {
        if dataViewModel.cards.isEmpty {
            NoCardView(image: "BoyLeft")
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        HStack(spacing: 0) {
                            StatusButton(systemName: "checkmark.circle.fill", status: 0, title: "Learned", colors: [.black, Color("Navy")], filterStatus: $filterStatus)
                            StatusButton(systemName: "flame.circle.fill", status: 1, title: "Learning", colors: [Color("Navy"), Color("Blue")], filterStatus: $filterStatus)
                            StatusButton(systemName: "star.circle.fill", status: 2, title: "New", colors: [Color("Blue"), Color("Teal")], filterStatus: $filterStatus)
                        }
                        .cornerRadius(20)
                        .clipped()
                        .padding()
                        
                        VStack {
                            HStack {
                                Text("Category")
                                Spacer()
                                
                                Button {
                                    showingCategorySheet.toggle()
                                } label: {
                                    Text(selectedCategories.map { $0 }.joined(separator: ", "))
                                }
                                .padding([.leading, .trailing])
                                .sheet(isPresented: $showingCategorySheet) {
                                    List(dataViewModel.categories, id: \.self) { category in
                                        HStack {
                                            Text(category.name ?? "Unknown")
                                            Spacer()
                                            if selectedCategories.contains(category.name ?? "") {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            guard let categoryName = category.name else { return }
                                            if selectedCategories.contains(categoryName) {
                                                guard selectedCategories.count != 1 else { return }
                                                selectedCategories.removeAll { $0 == category.name }
                                            } else {
                                                selectedCategories.append(categoryName)
                                            }
                                        }
                                    }
                                    .environment(\.editMode, .constant(EditMode.active))
                                    .presentationDetents([.medium, .large])
                                }
                                
                            }
                            .frame(height: 30)
                            
                            Divider()
                            
                            HStack {
                                Text("Maximum Cards")
                                Spacer()
                                NumberPicker(value: $maximumCards, labelText: "cards", options: Global.maximumCardOptions)
                            }
                            .frame(height: 30)
                            
                            Divider()

                            HStack {
                                Text("Failed Times")
                                Spacer()
                                NumberPicker(value: $failedTimes, labelText: "or more times", options: Global.failedTimeOptions)
                            }
                            .frame(height: 30)
                        }
                        .modifier(BlurBackground())
                        
                        Button(action: {
                            guard cardsToStudy.count > 0 else { return }
                            showingCardView = true
                        }) {
                            Text(cardsToStudy.count > 0 ? "Study \(cardsToStudy.count) Cards" : "No Cards Available")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(cardsToStudy.count > 0 ? LinearGradient(colors: [Color("Navy"), Color("Blue")], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(cardsToStudy.count == 0)
                        .padding()
                        .fullScreenCover(isPresented: $showingCardView) {
                            CardView(showingCardView: $showingCardView, cardsToStudy: cardsToStudy)
                        }
                    }
                }
                .background(BackgroundView())
                .navigationBarTitle("Study", displayMode: .large)
            }
            .onAppear {
                dataViewModel.cards.forEach { card in
                    guard card.category == nil else { return }
                    card.category = dataViewModel.categories.first?.name
                    PersistenceController.shared.saveContext()
                }
                
                guard isFirstAppearance else { return }
                selectedCategories = dataViewModel.categories.map { $0.name ?? "" }
                isFirstAppearance = false
            }
            .onReceive(dataViewModel.$cards) { _ in
                updateCardsToStudy()
            }
        }
    }
}
