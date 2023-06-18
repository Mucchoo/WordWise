//
//  CardView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct CardView: View {
    @Environment(\.managedObjectContext) var mock
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    
    @Binding var showingCardView: Bool
    @State private var isVStackVisible = false
    
    var learnedCards: Int {
        cards.filter { $0.status == 0 }.count
    }
    
    var totalCards: Int {
        cards.count
    }
    
    init(showingCardView: Binding<Bool>) {
        self._showingCardView = showingCardView
    }

    
    var body: some View {
        VStack {
            DragBar()
            ProgressView(learnedCards: learnedCards, totalCards: totalCards)
            
            ScrollView {
                Spacer().frame(height: 20)
                WordDefinitionView(word: "stick together", pronunciation: "stik ta'gedar")
                Spacer().frame(height: 20)
                
                ZStack {
                    DefinitionView(isVStackVisible: $isVStackVisible)
                        .opacity(isVStackVisible ? 1 : 0)
                        .animation(.easeIn(duration: 0.3), value: isVStackVisible)

                    Rectangle()
                        .fill(Color.white)
                        .opacity(isVStackVisible ? 0 : 1)
                        .animation(.easeIn(duration: 0.3), value: isVStackVisible)
                        .zIndex(1)
                }

                Spacer()
            }
            
            ControlButtons(isVStackVisible: $isVStackVisible)
        }
        .padding([.leading, .trailing])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onTapGesture {
            isVStackVisible = true
        }
    }
}

struct DismissableSheet: View {
    @Binding var showingSheet: Bool

    var body: some View {
        VStack {
            DragBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

struct DragBar: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color(.systemGray4))
            .frame(width: 60, height: 8)
            .padding()
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height > 50 {
                            dismiss()
                        }
                    }
            )
    }
}

struct ProgressView: View {
    @State var learnedCards: Int
    let totalCards: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.5))
                .frame(height: 20)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .frame(width: CGFloat(learnedCards) / CGFloat(totalCards) * UIScreen.main.bounds.width, height: 20)
            
            HStack {
                Text("\(learnedCards)")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(totalCards - learnedCards)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding([.leading, .trailing])
        }
    }
}

struct DefinitionView: View {
    @Binding var isVStackVisible: Bool
    
    var body: some View {
        VStack {
            DefinitionDetailView(title: "Meaning 1: noun", description: "to continue to support each other", sample: "we must stick together and work as a team")
            
            Divider()
            
            DefinitionDetailView(title: "Meaning 2: exclamation", description: "to continue to support each other", sample: "we must stick together and work as a team")
            
            Divider()
            
            DefinitionDetailView(title: "Meaning 3: verb", description: "to continue to support each other", sample: "we must stick together and work as a team")
            
            Divider()
            
            SynonymView(synonyms: "seal, agree, collaborate, comply with, conspire, contribute, coordinate, further, help, participate, unite, uphold, accompany, marry, tie, attach, catch, fix, glue, hold")
        }
        .opacity(isVStackVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3))
    }
}

struct WordDefinitionView: View {
    let word: String
    let pronunciation: String
    
    var body: some View {
        VStack {
            Text(word)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(pronunciation)
                .foregroundColor(.primary)
        }
    }
}

struct DefinitionDetailView: View {
    let title: String
    let description: String
    let sample: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Spacer().frame(height: 10)
            
            HStack {
                Text("Example")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack {
                Text(sample)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}

struct SynonymView: View {
    let synonyms: String
    
    var body: some View {
        VStack {
            HStack {
                Text("Synonym")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack {
                Text(synonyms)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}

struct ControlButtons: View {
    @Binding var isVStackVisible: Bool
    
    var body: some View {
        HStack {
            ToggleButton(title: "Easy", color: .blue, isVStackVisible: $isVStackVisible)
            
            ToggleButton(title: "Hard", color: .red, isVStackVisible: $isVStackVisible)
        }
    }
}

struct ToggleButton: View {
    let title: String
    let color: Color
    @Binding var isVStackVisible: Bool
    
    var body: some View {
        Button(action: {
            isVStackVisible = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isVStackVisible = true
            }
        }) {
            Text(title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    @State static var showingCardView = true

    static var previews: some View {
        CardView(showingCardView: $showingCardView)
    }
}
