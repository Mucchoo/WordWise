//
//  ContentView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var mock
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    var body: some View {
//        VStack {
//            List(cards)  { card in
//                Text(card.text ?? "Unknown")
//            }
//
//            Button("add") {
//                let texts = ["Apple", "Pinapple", "strobberry", "blueberry"]
//                let chosenText = texts.randomElement()!
//
//                let card = Card(context: mock)
//                card.id = UUID()
//                card.text = chosenText
//                card.status = 0
//
//                try? mock.save()
//            }
//        }
        TabView {
            StudyView()
                .tabItem {
                    Image(systemName: "square.filled.on.square")
                    Text("Study")
                }
                .tag(0)
            
            AddCardView()
                .tabItem {
                    Image(systemName: "plus.square.fill")
                    Text("Add")
                }
                .tag(1)
            
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Setting")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
