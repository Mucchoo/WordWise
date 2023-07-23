//
//  ContentView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var filterViewModel = FilterViewModel.shared
    @EnvironmentObject var dataViewModel: DataViewModel
    @State var selectedTab = "book.closed"

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                StudyView()
                    .tag("book.closed")
                    .accessibilityIdentifier("StudyView")
                AddCardView()
                    .tag("plus.square")
                    .accessibilityIdentifier("AddCardView")
                CardListView()
                    .tag("rectangle.stack")
                    .accessibilityIdentifier("CardListView")
                AccountView()
                    .tag("person")
                    .accessibilityIdentifier("AccountView")
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                Spacer().frame(height: 20)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            dataViewModel.addDefaultCategory {
                guard CommandLine.arguments.contains("SETUP_DATA_FOR_TESTING") else { return }

                for i in 0..<Int.random(in: 1..<100) {
                    let testCard = dataViewModel.makeTestCard(text: "test card \(i)")
                    dataViewModel.cards.append(testCard)
                    print("add card: \(i)")
                }

                dataViewModel.persistence.saveContext()
                dataViewModel.loadData()

                dataViewModel.cards.forEach { card in
                    if card.category == nil {
                        card.category = dataViewModel.categories.first?.name
                        dataViewModel.persistence.saveContext()
                    }
                }
            }
        }
        .onChange(of: dataViewModel.categories) { newValue in
            guard filterViewModel.selectedCategories.isEmpty else { return }
            filterViewModel.selectedCategories = dataViewModel.categories.map { $0.name ?? "" }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
