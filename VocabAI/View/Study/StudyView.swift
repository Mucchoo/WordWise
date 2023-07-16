//
//  StudyView.swift
//  VocabAI
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @ObservedObject var filterViewModel = FilterViewModel.shared
    @State private var showingCardView = false
    @AppStorage("learnedButton") private var learnedButton = true
    @AppStorage("learningButton") private var learningButton = true
    @AppStorage("newButton") private var newButton = true
    @State private var showingCategorySheet = false
    @AppStorage("maximumCards") private var maximumCards = 10
    @AppStorage("failedTimes") private var failedTimes = 0
    @State private var isFirstAppearance = true
        
    var body: some View {
        if dataViewModel.cards.isEmpty {
            NoCardView(image: "BoyLeft")
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        StatusFilterView(filterStatus: $filterViewModel.filterStatus)
                        
                        VStack {
                            HStack {
                                Text("Category")
                                Spacer()
                                
                                Button {
                                    showingCategorySheet.toggle()
                                } label: {
                                    Text(filterViewModel.selectedCategories.map { $0 }.joined(separator: ", "))
                                }
                                .accessibilityIdentifier("filterButton")
                                .padding([.leading, .trailing])
                                .sheet(isPresented: $showingCategorySheet) {
                                    CategoryList(categories: $filterViewModel.selectedCategories)
                                }
                            }
                            .frame(height: 30)
                            
                            SettingsRow(description: "Maximum Cards", value: $maximumCards, labelText: "cards", options: Global.maximumCardOptions)
                            SettingsRow(description: "Failed Times", value: $failedTimes, labelText: "or more times", options: Global.failedTimeOptions)
                                .accessibilityIdentifier("failedTimesPicker")
                        }
                        .modifier(BlurBackground())
                        
                        Button(action: {
                            guard dataViewModel.cardsToStudy.count > 0 else { return }
                            showingCardView = true
                        }) {
                            Text(dataViewModel.cardsToStudy.count > 0 ? "Study \(dataViewModel.cardsToStudy.count) Cards" : "No Cards Available")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(dataViewModel.cardsToStudy.count > 0 ? LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(dataViewModel.cardsToStudy.count == 0)
                        .padding()
                        .accessibilityIdentifier("studyCardsButton")
                        .fullScreenCover(isPresented: $showingCardView) {
                            CardView(showingCardView: $showingCardView, cardsToStudy: dataViewModel.cardsToStudy)
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
                filterViewModel.selectedCategories = dataViewModel.categories.map { $0.name ?? "" }
                isFirstAppearance = false
            }
            .onReceive(dataViewModel.$cards) { _ in
                DispatchQueue.main.async {
                    self.updateCardsToStudy()
                }
            }
            .onChange(of: failedTimes) { _ in
                updateCardsToStudy()
            }
            .onChange(of: filterViewModel.selectedCategories) { _ in
                updateCardsToStudy()
            }
            .onChange(of: maximumCards) { _ in
                updateCardsToStudy()
            }
            .onChange(of: filterViewModel.filterStatus) { _ in
                updateCardsToStudy()
            }
        }
    }
    
    private func updateCardsToStudy() {
        let filteredCards = dataViewModel.cards.filter { card in
            let statusFilter = filterViewModel.filterStatus.contains { $0 == card.status }
            let failedTimesFilter = card.failedTimes >= failedTimes
            let categoryFilter = filterViewModel.selectedCategories.contains { $0 == card.category }
            return statusFilter && failedTimesFilter && categoryFilter
        }
        dataViewModel.cardsToStudy = Array(filteredCards.prefix(maximumCards))
    }
}
