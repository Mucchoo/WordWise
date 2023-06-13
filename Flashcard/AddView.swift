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
        VStack(spacing: 20) {
            Text("Add a New Flashcard")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter card text", text: $cardText)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                .padding()
            
            Button(action: {
                addCard()
            }) {
                Text("Add Card")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            List(flashcards, id: \.self) { card in
                Text(card)
            }
        }
        .padding()
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
