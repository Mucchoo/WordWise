//
//  StudyView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @ObservedObject var studyViewModel = StudyViewModel()
    @EnvironmentObject var dataViewModel: DataViewModel

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
                            CategoryPicker(selectedCategory: $studyViewModel.selectedCategory, categories: dataViewModel.categories)
                            FilterPicker(value: $studyViewModel.maximumCards)
                        }
                        .blurBackground()
                        
                        MasteryRateInfo()
                        MasteryRateCountsView(category: $studyViewModel.selectedCategory)
                            .padding(.horizontal)
                        
                        StudyButton(studyCount: studyViewModel.studyingCards.count) {
                            studyViewModel.updateCards()
                            studyViewModel.showingCardView = true
                        }
                        .fullScreenCover(isPresented: $studyViewModel.showingCardView) {
                            CardView(showingCardView: $studyViewModel.showingCardView, studyingCards: studyViewModel.studyingCards)
                                .accessibilityIdentifier("CardView")
                        }
                        
                        if !studyViewModel.todaysCards.isEmpty {
                            NavigationLink(destination: CardsView(type: .todays)) {
                                Text("Todays Cards: \(studyViewModel.todaysCards.count) Cards")
                            }
                            .padding(.top, 20)
                        }
                        
                        if !studyViewModel.upcomingCards.isEmpty {
                            NavigationLink(destination: CardsView(type: .upcoming)) {
                                Text("Upcoming Cards: \(studyViewModel.upcomingCards.count) Cards")
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                .backgroundView()
                .navigationBarTitle("Study", displayMode: .large)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onReceive(dataViewModel.$cards) { _ in
                DispatchQueue.main.async {
                    self.studyViewModel.updateCards()
                }
            }
        }
    }
}

private struct FilterPicker: View {
    @Binding var value: Int

    var body: some View {
        VStack {
            Divider()

            HStack {
                Text("Maximum Cards")
                Spacer()
                Picker("", selection: $value) {
                    ForEach(PickerOptions.maximumCard, id: \.self) { i in
                        Text("\(i) cards").tag(i)
                    }
                }
                .accessibilityIdentifier("studyMaximumCardsPicker")
                .labelsHidden()
                .cornerRadius(15)
                .pickerStyle(MenuPickerStyle())
            }
            .frame(height: 30)
        }
    }
}

private struct CategoryPicker: View {
    @Binding var selectedCategory: String
    var categories: [CardCategory]

    var body: some View {
        HStack {
            Text("Category")
            Spacer()
            Picker("Options", selection: $selectedCategory) {
                ForEach(categories) { category in
                    let name = category.name ?? ""
                    Text(name).tag(name)
                }
            }
        }
        .frame(height: 30)
    }
}

private struct MasteryRateInfo: View {
    var body: some View {
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
    }
}

private struct StudyButton: View {
    var studyCount: Int
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(studyCount > 0 ? "Study \(studyCount) Cards" : "Finished Learning for Today!")
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(studyCount > 0 ?
                            LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                .foregroundColor(.white)
                .cornerRadius(10)
                .accessibilityIdentifier("StudyCardsButton")
        }
        .disabled(studyCount == 0)
        .padding()
        .accessibilityIdentifier("studyCardsButton")
    }
}


#Preview {
    StudyView()
        .injectMockDataViewModelForPreview()
}
