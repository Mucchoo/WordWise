//
//  StudyView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @StateObject private var viewModel: StudyViewModel
    
    init(viewModel: StudyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        if !viewModel.container.appState.isDataLoaded {
            Text("Loading...")
        } else if viewModel.container.appState.cards.isEmpty {
            NoCardView(image: "BoyLeft")
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        VStack {
                            categoryPicker
                            maximumCardsPicker
                        }
                        .blurBackground()
                        
                        masteryRateTitleAndInfo
                        masteryRateCounts
                        studyButton
                        
                        if !viewModel.container.appState.todaysCards.isEmpty {
                            todaysCardsButton
                        }
                        
                        if !viewModel.container.appState.upcomingCards.isEmpty {
                            upcomingCardsButton
                        }
                    }
                }
                .gradientBackground()
                .navigationBarTitle("Study", displayMode: .large)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private var maximumCardsPicker: some View {
        VStack {
            Divider()

            HStack {
                Text("Maximum Cards")
                Spacer()
                Picker("", selection: $viewModel.maximumCards) {
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
    
    private var categoryPicker: some View {
        HStack {
            Text("Category")
            Spacer()
            Picker("Options", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.container.appState.categories) { category in
                    let name = category.name ?? ""
                    Text(name).tag(name)
                }
            }
        }
        .frame(height: 30)
    }
    
    private var masteryRateTitleAndInfo: some View {
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
    
    private var studyButton: some View {
        Button {
            viewModel.updateCards()
            viewModel.showingCardView = true
        } label: {
            Text(viewModel.studyButtonTitle)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.container.appState.studyingCards.count > 0 ?
                            LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                .foregroundColor(.white)
                .cornerRadius(10)
                .accessibilityIdentifier("StudyCardsButton")
        }
        .disabled(viewModel.container.appState.studyingCards.count == 0)
        .padding()
        .accessibilityIdentifier("studyCardsButton")
        .fullScreenCover(isPresented: $viewModel.showingCardView) {
            CardView(container: viewModel.container,
                     showingCardView: $viewModel.showingCardView,
                     studyingCards: viewModel.container.appState.studyingCards)
                .accessibilityIdentifier("CardView")
        }
    }
    
    private var masteryRateCounts: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                rateBar(rate: .zero)
                rateBar(rate: .twentyFive)
            }
            HStack(spacing: 0) {
                rateBar(rate: .fifty)
                rateBar(rate: .seventyFive)
            }
        }
        .cornerRadius(20)
        .clipped()
        .padding(.horizontal)
    }
    
    private func rateBar(rate: MasteryRate) -> some View {
        return HStack(alignment: .center, spacing: 4) {
            Text(rate.stringValue() + "%:")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 2)
            Text("\(viewModel.rateBarCardCount(rate: rate))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("cards")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 6)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: viewModel.getRateBarColors(rate: rate), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    private var todaysCardsButton: some View {
        return NavigationLink(destination: CardsView(container: viewModel.container, type: .todays)) {
            Text("Todays Cards: \(viewModel.container.appState.todaysCards.count) Cards")
        }.padding(.top, 20)
    }
    
    private var upcomingCardsButton: some View {
        return NavigationLink(destination: CardsView(container: viewModel.container, type: .upcoming)) {
            Text("Upcoming Cards: \(viewModel.container.appState.upcomingCards.count) Cards")
        }.padding(.top, 20)
    }
}

#Preview {
    let viewModel = StudyViewModel(container: .mock())
    viewModel.selectedCategory = "Category 1"
    
    return StudyView(viewModel: viewModel)
}
