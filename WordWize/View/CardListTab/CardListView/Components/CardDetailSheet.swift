//
//  CardDetailSheet.swift
//  WordWize
//
//  Created by Musa Yazici on 9/11/23.
//

import SwiftUI

struct CardDetailSheet: View {
    @Binding var selectedCard: Card?
    @Binding var categoryName: String
    @Binding var selectedRate: Int16
    let container: DIContainer
    let updateCard: () -> Void
    let deleteCard: () -> Void
    
    var body: some View {
        VStack {
            VStack(spacing: 4) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(selectedCard?.text ?? "")
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
                
                HStack {
                    Text("Category")
                    Spacer()
                    Picker("Category", selection: $categoryName) {
                        ForEach(container.appState.categories) { category in
                            let name = category.name ?? ""
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.leading)
                
                Divider()
                
                HStack {
                    Text("Mastery Rate")
                    Spacer()
                    Picker("Mastery Rate", selection: $selectedRate) {
                        ForEach(MasteryRate.allValues, id: \.self) { rate in
                            Text(rate.stringValue() + "%").tag(rate.rawValue)
                        }
                    }
                }
                .padding(.leading)
            }
            .padding()
            .padding(.top)
            
            Button {
                deleteCard()
            } label: {
                Text("Delete Card")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            
            Spacer()
        }
        .presentationDetents([.medium])
        .onDisappear {
            print("onDisappear")
            updateCard()
        }
    }
}
