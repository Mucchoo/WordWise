//
//  SettingView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    @State private var isShowingAlert = false
    @State var isShowingReauthenticate = false
    @State var isShowingTutorial = false
    @State var isShowingMail = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Header 1")) {
                        Text("Row 1")
                        Text("Row 2")
                        Text("Row 3")
                    }
                    
                    Section(header: Text("Header 2"), footer: Text("Footer 2")){
                        Button(action: {
                            isShowingTutorial = true
                        }) {
                            Text("Show Tutorial")
                        }
                        
                        Button(action: {
                            // Action here
                        }) {
                            Text("Button 2")
                        }
                        
                        Button(action: {
                            isShowingMail = true
                        }) {
                            Text("Show Mail")
                        }
                        
                        Button(action: {
                            isShowingReauthenticate = true
                        }) {
                            Text("Reauthenticate")
                        }
                        
                        Button(action: {
                            isShowingAlert = true
                        }) {
                            Text("Show Alert")
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
