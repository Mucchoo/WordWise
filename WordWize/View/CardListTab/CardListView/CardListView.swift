//
//  CardListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI
import UIKit

struct CardListView: View {
    @StateObject private var viewModel: CardListViewModel
    
    init(categoryName: String) {
        _viewModel = StateObject(wrappedValue: CardListViewModel(categoryName: categoryName))
    }
    
    var body: some View {
        searchBar
        ScrollView {
            VStack {
                LazyVStack {
                    ForEach(viewModel.cardList, id: \.id) { card in
                        cardRow(card)
                    }
                }
                .blurBackground()
            }
        }
        .gradientBackground()
        .background(PickerAlert(viewModel: viewModel, type: .category))
        .background(PickerAlert(viewModel: viewModel, type: .masteryRate))
        .navigationBarTitle(viewModel.categoryName, displayMode: .large)
        .navigationBarItems(leading: navigationLeadingItems, trailing: selectModeButton)
        .onReceive(viewModel.dataViewModel.$cards) { _ in
            viewModel.updateCardList()
        }
        .onChange(of: viewModel.searchBarText) { _ in
            viewModel.updateCardList()
        }
    }
    
    private var navigationLeadingItems: some View {
        Group {
            if viewModel.selectMode {
                if viewModel.selectedCards.count == 0 {
                    Text("Select Cards")
                        .foregroundStyle(Color.white)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(width: 120, height: 30)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray))
                } else {
                    Menu("Actions...") {
                        Button(action: {
                            viewModel.showingPickerAlert = true
                        }) {
                            Label("Change Category", systemImage: "folder.fill")
                        }
                        
                        Button(action: {
                            viewModel.showingChangeMasteryRateView = true
                        }) {
                            Label("Change Mastery Rate", systemImage: "chart.bar.fill")
                        }
                        
                        Button(action: {
                            viewModel.showingDeleteCardsAlert = true
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
                    .alert("Do you want to delete the \(viewModel.selectedCards.count) cards?", isPresented: $viewModel.showingDeleteCardsAlert) {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteSelectedCards()
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
            viewModel.selectMode.toggle()
        }) {
            Text(viewModel.selectMode ? "Cancel" : "Select")
                .foregroundStyle(Color.white)
                .font(.footnote)
                .fontWeight(.bold)
                .frame(width: 80, height: 30)
                .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color.blue))
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search...", text: $viewModel.searchBarText)
                .onChange(of: viewModel.searchBarText) { newValue in
                    viewModel.searchBarText = newValue.lowercased()
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
                if viewModel.selectMode {
                    viewModel.selectCard(card)
                } else {
                    viewModel.setupDetailView(card)
                }
            }) {
                HStack {
                    if viewModel.selectMode {
                        Image(systemName: viewModel.selectedCards.contains(where: { $0 == card }) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                            .fontWeight(viewModel.selectedCards.contains(where: { $0 == card }) ? .black : .regular)
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
            if card.id != viewModel.lastCardId {
                Divider()
            }
        }
        .sheet(isPresented: $viewModel.navigateToCardDetail) {
            cardDetailSheet(card)
        }
        .onChange(of: viewModel.navigateToCardDetail) { newValue in
            guard !newValue else { return }
            viewModel.updateCard(card)
        }
    }
    
    private func cardDetailSheet(_ card: Card) -> some View {
        VStack {
            VStack(spacing: 4) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(viewModel.cardText)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
                
                HStack {
                    Text("Category")
                    Spacer()
                    Picker("Category", selection: $viewModel.categoryName) {
                        ForEach(viewModel.dataViewModel.categories) { category in
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
                    Picker("Mastery Rate", selection: $viewModel.masteryRate) {
                        ForEach(MasteryRate.allValues, id: \.self) { rate in
                            Text(rate.stringValue() + "%").tag(rate.rawValue)
                        }
                    }
                }
                .padding(.leading)
            }
            .padding()
            .padding(.top)
            
            Button {
                viewModel.deleteCard(card)
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
            viewModel.updateCard(card)
        }
    }
}

#Preview {
    CardListView(categoryName: "")
        .injectMockDataViewModelForPreview()
}

private struct PickerAlert: UIViewControllerRepresentable {
    enum ViewType {
        case category, masteryRate
    }
    
    @ObservedObject var viewModel: CardListViewModel
    var title: String?
    var message: String?
    var options: [String] = []
    var onConfirm: (() -> ())?
    
    init(viewModel: CardListViewModel, type: ViewType) {
        self.viewModel = viewModel
        
        if type == .category {
            title = "Change Category"
            message = "Select new category for the \(viewModel.selectedCards.count) cards."
            options = viewModel.dataViewModel.categories.map { $0.name ?? "" }
            onConfirm = viewModel.changeCategory
        } else {
            title = "Change Mastery Rate"
            message = "Select Mastery Rate for the \(viewModel.selectedCards.count) cards."
            options = MasteryRate.allValues.map { $0.stringValue() + "%" }
            onConfirm = viewModel.changeMasteryRate
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if viewModel.showingPickerAlert, context.coordinator.alertController == nil {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let pickerView = UIPickerView()
            pickerView.dataSource = context.coordinator
            pickerView.delegate = context.coordinator
            
            let pickerViewController = UIViewController()
            pickerViewController.view = pickerView
            pickerViewController.preferredContentSize = CGSize(width: 250, height: 150)
            
            alert.setValue(pickerViewController, forKey: "contentViewController")
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                viewModel.showingPickerAlert = false
                context.coordinator.alertController = nil
                onConfirm?()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                viewModel.showingPickerAlert = false
                context.coordinator.alertController = nil
            })
            
            context.coordinator.alertController = alert
            uiViewController.present(alert, animated: true) {
                context.coordinator.alertController = nil
            }
        } else if !viewModel.showingPickerAlert, let alertController = context.coordinator.alertController, alertController.isBeingPresented {
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
            parent.viewModel.pickerAlertValue = parent.options[row]
        }
    }
}
