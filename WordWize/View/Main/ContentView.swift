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
    @State private var showTabBar = true

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                StudyView()
                    .tag("book.closed")
                    .accessibilityIdentifier("StudyView")
                AddCardView(showTabBar: $showTabBar)
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
                if showTabBar {
                    CustomTabBar(selectedTab: $selectedTab)
                    Spacer().frame(height: 20)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            dataViewModel.retryFetchingImages()
            
            guard CommandLine.arguments.contains("SETUP_DATA_FOR_TESTING") else { return }
            print("SETUP_DATA_FOR_TESTING")
            
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


#Preview {
    ContentView()
}
