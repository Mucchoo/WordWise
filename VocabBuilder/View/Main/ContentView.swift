//
//  ContentView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @State var selectedTab = "book.closed"
    @State var initialAnimation = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                StudyView(initialAnimation: $initialAnimation)
                    .tag("book.closed")
                AddCardView(initialAnimation: $initialAnimation)
                    .tag("plus.square")
                CardListView(initialAnimation: $initialAnimation)
                    .tag("rectangle.stack")
                AccountView(initialAnimation: $initialAnimation)
                    .tag("person")
            }
            .onAppear {
                initialAnimation = true
                cards.forEach { card in
                    AudioManager.shared.downloadAudio(card: card)
                }
            }
            .onChange(of: selectedTab) { _ in
                initialAnimation = true
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                Spacer().frame(height: 20)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
