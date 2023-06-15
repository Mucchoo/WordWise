//
//  AddView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct AddCardView: View {
    @State private var flashcards = [String]()
    @State private var isEditing = false
    private let initialPlaceholder = "Multiple cards can be added by adding new lines. Both words and phrases are available.\n\npineapple\nstrawberry\ncherry\nblueberry\npeach\nplum\nRome was not built in a day\nAll that glitters is not gold\nEvery cloud has a silver lining"
    @State private var cardText: String

    init() {
        _cardText = State(initialValue: initialPlaceholder)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $cardText)
                        .opacity(isEditing ? 1 : 0)
                        .onTapGesture {
                            if cardText == initialPlaceholder {
                                cardText = ""
                            }
                            withAnimation(.easeIn, { self.isEditing = true })
                        }
                    if !isEditing {
                        Text(initialPlaceholder)
                            .foregroundColor(.gray)
                            .padding(.all, 8)
                            .onTapGesture {
                                withAnimation(.easeIn, { self.isEditing = true })
                                if cardText == initialPlaceholder {
                                    cardText = ""
                                }
                            }
                    }
                }
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
            .navigationBarTitle("Add Cards", displayMode: .large)
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
