//
//  CardListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI
import UIKit

struct CardListView: View {
    @StateObject private var vm: CardListViewModel
    
    init(vm: CardListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        searchBar
        ScrollView {
            VStack {
                LazyVStack {
                    ForEach(vm.cardList, id: \.id) { card in
                        cardRow(card)
                    }
                }
                .blurBackground()
            }
        }
        .gradientBackground()
        .background(PickerAlert(vm: vm, type: .category))
        .background(PickerAlert(vm: vm, type: .masteryRate))
        .navigationBarTitle(vm.categoryName, displayMode: .large)
        .navigationBarItems(leading: navigationLeadingItems, trailing: selectModeButton)
        .onChange(of: vm.container.appState.cards) { _ in
            vm.updateCardList()
        }
        .onChange(of: vm.searchBarText) { _ in
            vm.updateCardList()
        }
    }
    
    private var navigationLeadingItems: some View {
        Group {
            if vm.selectMode {
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
                            vm.showingPickerAlert = true
                        }) {
                            Label("Change Category", systemImage: "folder.fill")
                        }
                        
                        Button(action: {
                            vm.showingChangeMasteryRateView = true
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
            vm.selectMode.toggle()
        }) {
            Text(vm.selectMode ? "Cancel" : "Select")
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
                if vm.selectMode {
                    vm.selectCard(card)
                } else {
                    vm.setupDetailView(card)
                }
            }) {
                HStack {
                    if vm.selectMode {
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
            if card.id != vm.lastCardId {
                Divider()
            }
        }
        .sheet(isPresented: $vm.navigateToCardDetail) {
            cardDetailSheet(card)
        }
        .onChange(of: vm.navigateToCardDetail) { newValue in
            guard !newValue else { return }
            vm.updateCard(card)
        }
    }
    
    private func cardDetailSheet(_ card: Card) -> some View {
        VStack {
            VStack(spacing: 4) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(vm.cardText)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
                
                HStack {
                    Text("Category")
                    Spacer()
                    Picker("Category", selection: $vm.categoryName) {
                        ForEach(vm.container.appState.categories) { category in
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
                    Picker("Mastery Rate", selection: $vm.masteryRate) {
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
                vm.deleteCard(card)
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
            vm.updateCard(card)
        }
    }
}

//#Preview {
//    CardListView(categoryName: "")
//        .injectMockDataViewModelForPreview()
//}

private struct PickerAlert: UIViewControllerRepresentable {
    enum ViewType {
        case category, masteryRate
    }
    
    @ObservedObject var vm: CardListViewModel
    var title: String?
    var message: String?
    var options: [String] = []
    var onConfirm: (() -> ())?
    
    init(vm: CardListViewModel, type: ViewType) {
        self.vm = vm
        
        if type == .category {
            title = "Change Category"
            message = "Select new category for the \(vm.selectedCards.count) cards."
            options = vm.container.appState.categories.map { $0.name ?? "" }
            onConfirm = vm.changeCategory
        } else {
            title = "Change Mastery Rate"
            message = "Select Mastery Rate for the \(vm.selectedCards.count) cards."
            options = MasteryRate.allValues.map { $0.stringValue() + "%" }
            onConfirm = vm.changeMasteryRate
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if vm.showingPickerAlert, context.coordinator.alertController == nil {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let pickerView = UIPickerView()
            pickerView.dataSource = context.coordinator
            pickerView.delegate = context.coordinator
            
            let pickerViewController = UIViewController()
            pickerViewController.view = pickerView
            pickerViewController.preferredContentSize = CGSize(width: 250, height: 150)
            
            alert.setValue(pickerViewController, forKey: "contentViewController")
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                vm.showingPickerAlert = false
                context.coordinator.alertController = nil
                onConfirm?()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                vm.showingPickerAlert = false
                context.coordinator.alertController = nil
            })
            
            context.coordinator.alertController = alert
            uiViewController.present(alert, animated: true) {
                context.coordinator.alertController = nil
            }
        } else if !vm.showingPickerAlert, let alertController = context.coordinator.alertController, alertController.isBeingPresented {
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
            parent.vm.pickerAlertValue = parent.options[row]
        }
    }
}
