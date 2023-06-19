//
//  CardView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct CardView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    
    @Binding var showingCardView: Bool
    @State private var isVStackVisible = false
    @State private var isWordVisible = true
    @State private var learningCards: [LearningCard]
    @State private var index = 0
    
    init(showingCardView: Binding<Bool>, cardsToLearn: FetchedResults<Card>?) {
        self._showingCardView = showingCardView
        
        var cards = [Card]()
        if let unwrappedCards = cardsToLearn {
            cards = Array(unwrappedCards)
        }
        
        self._learningCards = State(initialValue: cards.map { LearningCard(card: $0) })
        print("cardsToLearn: \(cardsToLearn), learningCards: \(learningCards)")
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
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
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                        .frame(width: CGFloat(learningCards.filter { $0.isLearning }.count) / CGFloat(learningCards.count) * geometry.size.width, height: 20)
                    
                    HStack {
                        Text("\(learningCards.filter { $0.isLearning }.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(learningCards.count - learningCards.filter { $0.isLearning }.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding([.leading, .trailing])
                }
                
                ScrollView {
                    Spacer().frame(height: 20)
                    
                    VStack {
                        Text(cards[index].text ?? "Unknown")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text(cards[index].phoneticsArray.first?.text ?? "Unknown")
                            .foregroundColor(.primary)
                    }
                    .opacity(isWordVisible ? 1 : 0)
                    .animation(.easeIn(duration: 0.3), value: isWordVisible)
                    Spacer().frame(height: 20)
                    
                    ZStack {
                        DefinitionView()
                        Rectangle()
                            .fill(Color.white)
                            .opacity(isVStackVisible ? 0 : 1)
                            .animation(.easeIn(duration: 0.3), value: isVStackVisible)
                            .zIndex(1)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Button(action: {
                        isVStackVisible = false
                        isWordVisible = false
                        
                        print("index: \(index) cards: \(learningCards)")
                        learningCards[index].isLearning = false
                        index += 1
                        
                        if index == learningCards.count {
                            // show complete view
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isWordVisible = true
                        }
                    }) {
                        Text("Easy")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isVStackVisible = false
                        isWordVisible = false
                        
                        print("index: \(index) cards: \(learningCards)")
                        let card = learningCards.remove(at: index)
                        learningCards.append(card)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isWordVisible = true
                        }
                    }) {
                        Text("Hard")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding([.leading, .trailing])
        .background(Color.white.ignoresSafeArea(.all, edges: .top))
        .onTapGesture {
            isVStackVisible = true
        }
    }
}

struct DefinitionView: View {
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

struct CardView_Previews: PreviewProvider {
    @State static var showingCardView = true

    static var previews: some View {
        CardView(showingCardView: $showingCardView, cardsToLearn: nil)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
