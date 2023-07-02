//
//  ContentView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dataViewModel = DataViewModel.shared
    @State var selectedTab = "book.closed"

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                StudyView()
                    .tag("book.closed")
                AddCardView()
                    .tag("plus.square")
                CardListView()
                    .tag("rectangle.stack")
                AccountView()
                    .tag("person")
            }
            .onAppear {
                dataViewModel.cards.forEach { card in
                    AudioViewModel.shared.downloadAudio(card: card)
                }
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
