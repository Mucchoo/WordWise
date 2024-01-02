//
//  StudyView.swift
//  WordWise
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI
import SwiftData

struct StudyView: View {
    @StateObject private var vm: StudyViewModel
    @Query private var cards: [Card]
    @Query private var categories: [CardCategory]
    @Query(filter: #Predicate<Card> { $0.isTodayOrBefore }) private var todaysCards: [Card]
    @Query(filter: #Predicate<Card> { $0.isUpcoming }) private var upcomingCards: [Card]
    private var studyingCards: [Card] {
        return Array(todaysCards.prefix(vm.maximumCards))
    }

    init(vm: StudyViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        if cards.isEmpty {
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
                        
                        if !todaysCards.isEmpty {
                            todaysCardsButton
                        }
                        
                        if !upcomingCards.isEmpty {
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
                Picker("", selection: $vm.maximumCards) {
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
            Picker("Options", selection: $vm.selectedCategory) {
                ForEach(categories) { category in
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
            vm.showingCardView = true
        } label: {
            Text(vm.studyButtonTitle)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(studyingCards.count > 0 ?
                            LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                .foregroundColor(.white)
                .cornerRadius(10)
                .accessibilityIdentifier("StudyCardsButton")
        }
        .disabled(studyingCards.count == 0)
        .padding()
        .accessibilityIdentifier("studyCardsButton")
        .fullScreenCover(isPresented: $vm.showingCardView) {
            CardView(vm: .init(container: vm.container, maximumCards: vm.maximumCards),
                     showingCardView: $vm.showingCardView)
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
            Text("\(vm.rateBarCardCount(rate: rate))")
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
        .background(LinearGradient(colors: vm.getRateBarColors(rate: rate), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    private var todaysCardsButton: some View {
        return NavigationLink(destination: CardsView(vm: .init(container: vm.container, type: .todays))) {
            Text("Todays Cards: \(todaysCards.count) Cards")
        }.padding(.top, 20)
    }
    
    private var upcomingCardsButton: some View {
        return NavigationLink(destination: CardsView(vm: .init(container: vm.container, type: .upcoming))) {
            Text("Upcoming Cards: \(upcomingCards.count) Cards")
        }.padding(.top, 20)
    }
}

#Preview {
    StudyView(vm: .init(container: .mock()))
}
