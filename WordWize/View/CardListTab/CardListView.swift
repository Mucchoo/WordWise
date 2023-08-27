//
//  CardListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI
import UIKit

struct CardListView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @State private var searchBarText = ""
    @State private var cardList: [Card] = []
    @State private var selectedCards: [Card] = []
    @State private var selectedCategory = ""
    @State private var selectedRate = ""
    @State var categoryName = ""
    @State private var selectMode = false {
        didSet {
            if !selectMode {
                selectedCards = []
            }
        }
    }

    @State private var showingChangeCategoryView = false
    @State private var showingChangeMasteryRateView = false
    @State private var showingDeleteCardsAlert = false
    
    var body: some View {
        VStack {
            SearchBar(text: $searchBarText)
            ScrollView {
                VStack {
                    LazyVStack {
                        ForEach(cardList, id: \.id) { card in
                            CardRowView(card: card, lastCardId: $cardList.last?.id, selectMode: $selectMode, selectedCards: $selectedCards) {
                                self.updateCardList()
                            }
                        }
                    }
                    .modifier(BlurBackground())
                }
            }
        }
        .background(BackgroundView())
        .background(PickerAlert(
            isPresented: $showingChangeCategoryView,
            title: "Change Category",
            message: "Select new category for the \(selectedCards.count) cards.",
            options: dataViewModel.categories.map { $0.name ?? "" },
            selectedValue: $selectedCategory
        ) {
                dataViewModel.changeCategory(of: selectedCards, newCategory: selectedCategory)
                selectMode = false
                updateCardList()
        })
        .background(PickerAlert(
            isPresented: $showingChangeMasteryRateView,
            title: "Change Mastery Rate",
            message: "Select Mastery Rate for the \(selectedCards.count) cards.",
            options: MasteryRate.allValues.map { $0.stringValue() + "%" },
            selectedValue: $selectedRate
        ) {
                dataViewModel.changeMasteryRate(of: selectedCards, rate: selectedRate)
                selectMode = false
                updateCardList()
        })
        .navigationBarTitle(categoryName, displayMode: .large)
        .navigationBarItems(leading:
            Group {
                if selectMode {
                    if selectedCards.count == 0 {
                        Text("Select Cards")
                            .foregroundStyle(Color.white)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .frame(width: 120, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.gray)
                            )
                    } else {
                        Menu("Actions...") {
                            Button(action: {
                                showingChangeCategoryView = true
                            }) {
                                Label("Change Category", systemImage: "folder.fill")
                            }

                            Button(action: {
                                showingChangeMasteryRateView = true
                            }) {
                                Label("Change Mastery Rate", systemImage: "chart.bar.fill")
                            }

                            Button(action: {
                                showingDeleteCardsAlert = true
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
                    }
                } else {
                    EmptyView()
                }
            },
            trailing: Button(action: {
                selectMode.toggle()
            }) {
                Text(selectMode ? "Cancel" : "Select")
                    .foregroundStyle(Color.white)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .frame(width: 80, height: 30)
                    .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color.blue))
            }
        )
        .onReceive(dataViewModel.$cards) { _ in
            updateCardList()
        }
        .onChange(of: searchBarText) { _ in
            updateCardList()
        }
        .alert("Do you want to delete the \(selectedCards.count) cards?", isPresented: $showingDeleteCardsAlert) {
            Button("Delete", role: .destructive) {
                dataViewModel.deleteCards(selectedCards)
                selectMode = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This operation cannot be undone.")
        }
    }
    
    private func updateCardList() {
        let filteredCards = dataViewModel.cards.filter { card in
            let categoryFilter = card.category == categoryName
            let cardText = card.text ?? ""
            let searchTextFilter = cardText.contains(searchBarText) || searchBarText.isEmpty
            return categoryFilter && searchTextFilter
        }
        cardList = filteredCards
    }
}

#Preview {
    CardListView()
        .injectMockDataViewModelForPreview()
}

private struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search...", text: $text)
                .onChange(of: text) { newValue in
                    text = newValue.lowercased()
                }
                .padding(7)
                .modifier(BlurBackground())
                .cornerRadius(8)
        }
        .padding(.top, 10)
    }
}

private struct CardRowView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @State private var cardText = ""
    @State private var cardId: UUID?
    @State private var masteryRate: Int16 = 0
    @State private var cardCategory = ""
    @State private var navigateToCardDetail: Bool = false
    
    let card: Card
    let lastCardId: UUID?
    @Binding var selectMode: Bool
    @Binding var selectedCards: [Card]
    let updateCardList: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                if selectMode {
                    selectCard()
                } else {
                    setupDetailView(card)
                }
            }) {
                HStack {
                    if selectMode {
                        Image(systemName: selectedCards.contains(where: { $0 == card }) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                            .fontWeight(selectedCards.contains(where: { $0 == card }) ? .black : .regular)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    
                    Text(card.text ?? "Unknown")
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
            if card.id != lastCardId {
                Divider()
            }
        }
        .sheet(isPresented: $navigateToCardDetail) {
            CardDetailSheetView(
                cardText: $cardText,
                categoryName: $cardCategory,
                masteryRate: $masteryRate,
                cardId: cardId,
                deleteAction: {
                    dataViewModel.deleteCard(card)
                    navigateToCardDetail = false
                    updateCardList()
                },
                updateAction: {
                    if let cardId = cardId {
                        dataViewModel.updateCard(id: cardId, text: cardText, category: cardCategory, rate: masteryRate)
                        updateCardList()
                    }
                }
            )
        }
        .onChange(of: navigateToCardDetail) { newValue in
            if !newValue, let cardId = cardId {
                dataViewModel.updateCard(id: cardId, text: cardText, category: cardCategory, rate: masteryRate)
            }
        }
    }
    
    private func setupDetailView(_ card: Card) {
        cardId = card.id
        cardText = card.text ?? ""
        cardCategory = card.category ?? ""
        navigateToCardDetail = true
    }
    
    private func selectCard() {
        if !selectedCards.contains(where: { $0 == card }) {
            selectedCards.append(card)
        } else {
            selectedCards.removeAll(where: { $0 == card })
        }
    }
}

private struct CardDetailSheetView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @Binding var cardText: String
    @Binding var categoryName: String
    @Binding var masteryRate: Int16
    var cardId: UUID?
    let deleteAction: () -> Void
    let updateAction: () -> Void
    
    private let masteryRates: [MasteryRate]  = [.zero, .twentyFive, .fifty, .seventyFive, .oneHundred]

    var body: some View {
        VStack {
            VStack(spacing: 4) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(cardText)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
                
                HStack {
                    Text("Category")
                    Spacer()
                    Picker("Category", selection: $categoryName) {
                        ForEach(dataViewModel.categories) { category in
                            let name = category.name ?? ""
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.leading)
                
                Divider()
                
                HStack {
                    Text("Mastery Rate")
                    Spacer()
                    Picker("Mastery Rate", selection: $masteryRate) {
                        ForEach(masteryRates, id: \.self) { rate in
                            Text(rate.stringValue() + "%").tag(rate.rawValue)
                        }
                    }
                }
                .padding(.leading)
            }
            .padding()
            .padding(.top)
            
            Button {
                deleteAction()
            } label: {
                Text("Delete Card")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            
            Spacer()
        }
        .presentationDetents([.medium])
        .onDisappear {
            updateAction()
        }
    }
}

private struct PickerAlert: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String?
    let message: String?
    let options: [String]
    @Binding var selectedValue: String
    let onConfirm: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented, context.coordinator.alertController == nil {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let pickerView = UIPickerView()
            pickerView.dataSource = context.coordinator
            pickerView.delegate = context.coordinator

            let pickerViewController = UIViewController()
            pickerViewController.view = pickerView
            pickerViewController.preferredContentSize = CGSize(width: 250, height: 150)

            alert.setValue(pickerViewController, forKey: "contentViewController")
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                isPresented = false
                context.coordinator.alertController = nil
                onConfirm()
            })

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                isPresented = false
                context.coordinator.alertController = nil
            })

            context.coordinator.alertController = alert
            uiViewController.present(alert, animated: true) {
                context.coordinator.alertController = nil
            }
        } else if !isPresented, let alertController = context.coordinator.alertController, alertController.isBeingPresented {
            alertController.dismiss(animated: true) {
                context.coordinator.alertController = nil
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PickerAlert
        var alertController: UIAlertController?
        var pickerView: UIPickerView?

        init(_ parent: PickerAlert) {
            self.parent = parent
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.options.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            parent.options[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selectedValue = parent.options[row]
        }
    }
}
