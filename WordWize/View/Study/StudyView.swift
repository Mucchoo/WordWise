//
//  StudyView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @AppStorage("maximumCards") private var maximumCards = 1000
    @State private var showingCardView = false
    @State private var selectedCategory = ""

    var body: some View {
        if !dataViewModel.isDataLoaded {
            Text("")
        } else if dataViewModel.cards.isEmpty {
            NoCardView(image: "BoyLeft")
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        VStack {
                            HStack {
                                Text("Category")
                                Spacer()
                                
                                Picker("Options", selection: $selectedCategory) {
                                    ForEach(dataViewModel.categories) { category in
                                        let name = category.name ?? ""
                                        Text(name).tag(name)
                                    }
                                }
                            }
                            .frame(height: 30)
                            
                            FilterPicker(description: "Maximum Cards", value: $maximumCards, labelText: "cards", options: PickerOptions.maximumCard, id: "studyMaximumCardsPicker")
                        }
                        .modifier(BlurBackground())
                        
                        HStack {
                            Text("Mastery Rate")
                                .fontWeight(.bold)
                                .padding(.leading, 10)
                            
                            NavigationLink(destination: WhatIsMasteryRateView()) {
                                Image(systemName: "info.circle")
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        MasteryRateCountsView(category: $selectedCategory)
                            .padding(.horizontal)
                        
                        Button(action: {
                            guard dataViewModel.studyingCards.count > 0 else { return }
                            showingCardView = true
                        }) {
                            Text(dataViewModel.studyingCards.count > 0 ? "Study \(dataViewModel.studyingCards.count) Cards" : "Finished Learning for Today!")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(dataViewModel.studyingCards.count > 0 ? LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .accessibilityIdentifier("StudyCardsButton")
                        }
                        .disabled(dataViewModel.studyingCards.count == 0)
                        .padding()
                        .accessibilityIdentifier("studyCardsButton")
                        .fullScreenCover(isPresented: $showingCardView) {
                            CardView(showingCardView: $showingCardView, studyingCards: dataViewModel.studyingCards)
                                .accessibilityIdentifier("CardView")
                        }
                        
                        if !dataViewModel.todaysCards.isEmpty {
                            NavigationLink(destination: CardsView(type: .todays)) {
                                Text("Todays Cards: \(dataViewModel.todaysCards.count) Cards")
                            }
                            .padding(.top, 20)
                        }
                        
                        if !dataViewModel.upcomingCards.isEmpty {
                            NavigationLink(destination: CardsView(type: .upcoming)) {
                                Text("Upcoming Cards: \(dataViewModel.upcomingCards.count) Cards")
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                .background(BackgroundView())
                .navigationBarTitle("Study", displayMode: .large)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onReceive(dataViewModel.$cards) { _ in
                DispatchQueue.main.async {
                    self.updateCards()
                }
            }
            .onChange(of: selectedCategory) { _ in
                updateCards()
            }
            .onChange(of: maximumCards) { _ in
                updateCards()
            }
        }
    }
    
    private func updateCards() {
        updateStudyingCards()
        updateTodaysAndUpcomingCards()
    }
    
    private func updateStudyingCards() {
        if selectedCategory.isEmpty {
            selectedCategory = dataViewModel.categories.first?.name ?? ""
        }
        
        let filteredCards = dataViewModel.cards.filter { card in
            let categoryFilter = selectedCategory == card.category
            
            var nextLearningDateFilter = true
            if let date = card.nextLearningDate {
                nextLearningDateFilter = Calendar.current.isDateInToday(date) || Date() > date
            }
            
            let oneHundredRateFilter = card.rate != .oneHundred
            
            return categoryFilter && nextLearningDateFilter && oneHundredRateFilter
        }
        dataViewModel.studyingCards = Array(filteredCards.prefix(maximumCards))
    }
    
    private func updateTodaysAndUpcomingCards() {
        let filteredCards = dataViewModel.cards.filter { card in
            let categoryFilter = selectedCategory == card.category
            let oneHundredRateFilter = card.rate != .oneHundred
            return categoryFilter && oneHundredRateFilter
        }
        
        let upcomingCards = filteredCards.filter { card in
            var nextLearningDateFilter = false
            if let date = card.nextLearningDate {
                nextLearningDateFilter = !Calendar.current.isDateInToday(date) && Date() < date
            }
            return nextLearningDateFilter
        }
        
        let todaysCards = filteredCards.filter { card in
            var nextLearningDateFilter = true
            if let date = card.nextLearningDate {
                nextLearningDateFilter = Calendar.current.isDateInToday(date) || Date() > date
            }
            return nextLearningDateFilter
        }
        
        dataViewModel.upcomingCards = upcomingCards
        dataViewModel.todaysCards = todaysCards
    }
}

#Preview {
    StudyView()
        .injectMockDataViewModelForPreview()
}
