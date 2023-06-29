//
//  ContentView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
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
                cards.forEach { card in
                    AudioManager.shared.downloadAudio(card: card)
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
