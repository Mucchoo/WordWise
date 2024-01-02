//
//  CardListView.swift
//  WordWise
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI
import UIKit
import SwiftData

struct CardListView: View {
    @StateObject private var vm: CardListViewModel
    @Query private var cards: [Card]
    
    init(vm: CardListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                searchBar
                LazyVStack {
                    ForEach(vm.cardList, id: \.id) { card in
                        cardRow(card)
                    }
                }
                .blurBackground()
            }
        }
        .gradientBackground()
        .background(PickerAlert(vm: vm))
        .navigationBarTitle(vm.categoryName, displayMode: .large)
        .navigationBarItems(leading: navigationLeadingItems, trailing: selectModeButton)
        .onChange(of: cards) { _ in
            vm.updateCardList()
        }
        .onChange(of: vm.searchBarText) { _ in
            vm.updateCardList()
        }
        .sheet(isPresented: $vm.navigateToCardDetail) {
            CardDetailSheet(
                selectedCard: $vm.selectedCard,
                categoryName: $vm.categoryName,
                selectedRate: $vm.selectedRate,
                container: vm.container,
                updateCard: vm.updateCard,
                deleteCard: vm.deleteCard
            )
        }
    }
    
    private var navigationLeadingItems: some View {
        Group {
            if vm.multipleSelectionMode {
                if vm.selectedCards.count == 0 {
                    Text("Select Cards")
                        .foregroundStyle(Color.white)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(width: 120, height: 30)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray))
                } else {
                    Menu("Actions...") {
                        Button(action: {
                            vm.pickerAlertType = .category
                        }) {
                            Label("Change Category", systemImage: "folder.fill")
                        }
                        
                        Button(action: {
                            vm.pickerAlertType = .masteryRate
                        }) {
                            Label("Change Mastery Rate", systemImage: "chart.bar.fill")
                        }
                        
                        Button(action: {
                            vm.showingDeleteCardsAlert = true
                        }) {
                            Label("Delete Cards", systemImage: "trash.fill")
                                .foregroundColor(Color.red)
                        }
                    }
                    .foregroundStyle(Color.white)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .frame(width: 120, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(Color.blue)
                    )
                    .alert("Do you want to delete the \(vm.selectedCards.count) cards?", isPresented: $vm.showingDeleteCardsAlert) {
                        Button("Delete", role: .destructive) {
                            vm.deleteSelectedCards()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This operation cannot be undone.")
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var selectModeButton: some View {
        Button(action: {
            vm.multipleSelectionMode.toggle()
        }) {
            Text(vm.multipleSelectionMode ? "Cancel" : "Select")
                .foregroundStyle(Color.white)
                .font(.footnote)
                .fontWeight(.bold)
                .frame(width: 80, height: 30)
                .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color.blue))
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search...", text: $vm.searchBarText)
                .onChange(of: vm.searchBarText) { newValue in
                    vm.searchBarText = newValue.lowercased()
                }
                .padding(7)
                .blurBackground()
                .cornerRadius(8)
        }
        .padding(.top, 10)
    }
    
    private func cardRow(_ card: Card) -> some View {
        VStack {
            Button(action: {
                if vm.multipleSelectionMode {
                    vm.selectCard(card)
                } else {
                    vm.selectedCard = card
                    vm.selectedRate = card.masteryRate
                    vm.showCardDetail(card)
                }
            }) {
                HStack {
                    if vm.multipleSelectionMode {
                        Image(systemName: vm.selectedCards.contains(where: { $0 == card }) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                            .fontWeight(vm.selectedCards.contains(where: { $0 == card }) ? .black : .regular)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    
                    Text(card.text ?? "")
                        .foregroundColor(.primary)
                    Spacer()
                    Text((MasteryRate(rawValue: card.masteryRate) ?? .zero).stringValue() + "%")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.ocean)
                        .foregroundStyle(Color.white)
                        .bold()
                        .cornerRadius(8)
                }
                .padding(.top, 2)
            }
            if card.id != vm.cardList.last?.id {
                Divider()
            }
        }
    }
}

#Preview {
    CardListView(vm: .init(container: .mock(), categoryName: MockHelper.shared.mockCategory))
}
