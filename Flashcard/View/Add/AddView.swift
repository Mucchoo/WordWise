//
//  AddView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct AddCardView: View {
    @State private var cardText = ""
    @State private var flashcards = [String]()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextEditor(text: $cardText)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                    .padding()
                
                Button(action: {
                    addCard()
                }) {
                    Text("Add \(cardText.split(separator: "\n").count) Cards")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(cardText.split(separator: "\n").count == 0)
            }
            .padding()
            .navigationBarTitle("Add Flashcards", displayMode: .large)
        }
    }
    
    func addCard() {
        if cardText != "" {
            flashcards.append(cardText)
            cardText = ""
        }
    }
}


struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
    }
}
