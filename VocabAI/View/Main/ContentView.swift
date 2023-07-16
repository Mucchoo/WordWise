//
//  ContentView.swift
//  VocabAI
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
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
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
