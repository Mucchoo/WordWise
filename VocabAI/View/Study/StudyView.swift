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
    @State private var showingCategorySheet = false

    @AppStorage("learnedButton") private var learnedButton = true
    @AppStorage("learningButton") private var learningButton = true
    @AppStorage("newButton") private var newButton = true
    @AppStorage("maximumCards") private var maximumCards = 10
    @AppStorage("failedTimes") private var failedTimes = 0
        
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
                                .accessibilityIdentifier("studyCategoryButton")
                                .padding(.horizontal)
                                .sheet(isPresented: $showingCategorySheet) {
                                    CategoryList(categories: $filterViewModel.selectedCategories)
                                        .accessibilityIdentifier("categoryListSheet")
                                }
                            }
                            .frame(height: 30)
                            
                            FilterPicker(description: "Maximum Cards", value: $maximumCards, labelText: "cards", options: Global.maximumCardOptions, id: "studyMaximumCardsPicker")
                            FilterPicker(description: "Failed Times", value: $failedTimes, labelText: "or more times", options: Global.failedTimeOptions, id: "studyFailedTimesPicker")
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
                                .accessibilityIdentifier("StudyCardsButton")
                        }
                        .disabled(dataViewModel.cardsToStudy.count == 0)
                        .padding()
                        .accessibilityIdentifier("studyCardsButton")
                        .fullScreenCover(isPresented: $showingCardView) {
                            CardView(showingCardView: $showingCardView, cardsToStudy: dataViewModel.cardsToStudy)
                                .accessibilityIdentifier("CardView")
                        }
                    }
                }
                .background(BackgroundView())
                .navigationBarTitle("Study", displayMode: .large)
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
