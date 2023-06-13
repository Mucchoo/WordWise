//
//  ContentView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
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
