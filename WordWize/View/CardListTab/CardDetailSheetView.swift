//
//  CardDetailSheetView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/14/23.
//

import SwiftUI

struct CardDetailSheetView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @Binding var cardText: String
    @Binding var categoryName: String
    @Binding var masteryRate: Int16
    var cardId: UUID?
    let deleteAction: () -> Void
    let updateAction: () -> Void
    
    private let masteryRates: [MasteryRate]  = [.zero, .twentyFive, .fifty, .seventyFive, .oneHundred]

    var body: some View {
        VStack {
            VStack(spacing: 4) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(cardText)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
                
                HStack {
                    Text("Category")
                    Spacer()
                    Picker("Category", selection: $categoryName) {
                        ForEach(dataViewModel.categories) { category in
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
                    Picker("Mastery Rate", selection: $masteryRate) {
                        ForEach(masteryRates, id: \.self) { rate in
                            Text(rate.stringValue() + "%").tag(rate.rawValue)
                        }
                    }
                }
                .padding(.leading)
            }
            .padding()
            .padding(.top)
            
            Button {
                deleteAction()
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
            updateAction()
        }
    }
}
