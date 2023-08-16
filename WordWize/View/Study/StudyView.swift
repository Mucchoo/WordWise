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
                                
                                Picker("Options", selection: $selectedCategory) {
                                    ForEach(dataViewModel.categories) { category in
                                        let name = category.name ?? ""
                                        Text(name).tag(name)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
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
            .onChange(of: selectedCategory) { _ in
                updateCardsToStudy()
            }
            .onChange(of: maximumCards) { _ in
                updateCardsToStudy()
            }
            .onChange(of: dataViewModel.categories) { newValue in
                guard selectedCategory.isEmpty else { return }
                selectedCategory = dataViewModel.categories.first?.name ?? ""
            }
        }
    }
    
    private func updateCardsToStudy() {
        let filteredCards = dataViewModel.cards.filter { card in
            let categoryFilter = selectedCategory == card.category
            return categoryFilter
        }
        dataViewModel.cardsToStudy = Array(filteredCards.prefix(maximumCards))
    }
}

#Preview {
    StudyView()
        .injectMockDataViewModelForPreview()
}
