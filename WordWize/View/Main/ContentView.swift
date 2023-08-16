//
//  ContentView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @State var selectedTab = "book.closed"
    @State var generatingCards = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                StudyView()
                    .tag("book.closed")
                    .accessibilityIdentifier("StudyView")
                AddCardView(generatingCards: $generatingCards)
                    .tag("plus.square")
                    .accessibilityIdentifier("AddCardView")
                CategoryListView()
                    .tag("rectangle.stack")
                    .accessibilityIdentifier("CategoryListView")
                AccountView()
                    .tag("person")
                    .accessibilityIdentifier("AccountView")
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                    .opacity(generatingCards ? 0.5 : 1)
                    .disabled(generatingCards)
                Spacer().frame(height: 20)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            dataViewModel.retryFetchingImages()
            
            guard CommandLine.arguments.contains("SETUP_DATA_FOR_TESTING") else { return }
            
            dataViewModel.addDefaultCategory {
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
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
