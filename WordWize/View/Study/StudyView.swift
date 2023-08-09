//
//  StudyView.swift
//  WordWize
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
    @AppStorage("maximumCards") private var maximumCards = 1000

    var body: some View {
        if dataViewModel.cards.isEmpty {
            NoCardView(image: "BoyLeft")
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        MasteryRateCountsView()
                        
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
                            
                            FilterPicker(description: "Maximum Cards", value: $maximumCards, labelText: "cards", options: PickerOptions.maximumCard, id: "studyMaximumCardsPicker")
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
            .navigationViewStyle(StackNavigationViewStyle())
            .onReceive(dataViewModel.$cards) { _ in
                DispatchQueue.main.async {
                    self.updateCardsToStudy()
                }
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
            let categoryFilter = filterViewModel.selectedCategories.contains { $0 == card.category }
            return statusFilter && categoryFilter
        }
        dataViewModel.cardsToStudy = Array(filteredCards.prefix(maximumCards))
    }
}
