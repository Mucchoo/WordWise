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
    @State private var isFinished = false
    @State private var isButtonEnabled = true
    
    init(showingCardView: Binding<Bool>, cardsToLearn: FetchedResults<Card>?) {
        self._showingCardView = showingCardView
        
        var cards = [Card]()
        if let unwrappedCards = cardsToLearn {
            cards = Array(unwrappedCards)
        }
        
        self._learningCards = State(initialValue: cards.map { LearningCard(card: $0) })
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
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                            .opacity(0.2)
                            .foregroundColor(Color(UIColor.tintColor))

                        Rectangle()
                            .frame(width: min(CGFloat(Float(learningCards.filter { !$0.isLearning }.count) / Float(learningCards.count))*geometry.size.width, geometry.size.width), height: 10)
                            .foregroundColor(isFinished ? .green : Color(UIColor.tintColor))
                            .animation(.spring())
                    }
                }
                .cornerRadius(5)
                .frame(height: 10)
                
                ZStack {
                    GeometryReader { geometry in
                        VStack {
                            Text("Finished!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                            Text("You've learned \(learningCards.count) cards")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.top)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(isFinished ? 1 : 0.1)
                        .opacity(isFinished ? 1 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
                    }
                    
                    ScrollView {
                        Spacer().frame(height: 20)
                        
                        VStack {
                            Text(learningCards[index].card.text ?? "Unknown")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text(learningCards[index].card.phoneticsArray.first?.text ?? "Unknown")
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
                    }.opacity(isFinished ? 0 : 1)
                }
                
                ZStack {
                    Button(action: {
                        showingCardView = false
                    }) {
                        Text("Go to Top Page")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.opacity(isFinished ? 1 : 0)
                    
                    HStack {
                        Button(action: {
                            guard isButtonEnabled else { return }

                            isButtonEnabled = false
                            isVStackVisible = false
                            isWordVisible = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.none) {
                                    let card = learningCards.remove(at: index)
                                    learningCards.append(card)
                                }
                                
                                isButtonEnabled = true
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
                        
                        Button(action: {
                            guard isButtonEnabled else { return }
                            
                            isButtonEnabled = false
                            isVStackVisible = false
                            isWordVisible = false
                            learningCards[index].isLearning = false

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.none) {
                                    if index + 1 == learningCards.count {
                                        isFinished = true
                                    } else {
                                        index += 1
                                    }
                                }

                                isButtonEnabled = true
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
                    }.opacity(isFinished ? 0 : 1)

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
