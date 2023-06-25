//
//  ContentView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    var body: some View {
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
            
            CardListView()
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Cards")
                }
            
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Setting")
                }
                .tag(3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
