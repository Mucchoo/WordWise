//
//  CardView.swift
//  VocabAI
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI
import Kingfisher

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataViewModel: DataViewModel
    @Binding var showingCardView: Bool
    @State private var isVStackVisible = false
    @State private var isWordVisible = true
    @State private var learningCards: [LearningCard]
    @State private var index = 0
    @State private var isFinished = false
    @State private var isButtonEnabled = true
    @State private var shouldScrollToTop: Bool = false
    
    let gridSize = (UIScreen.main.bounds.width - 21) / 2
    
    init(showingCardView: Binding<Bool>, cardsToStudy: [Card]) {
        _showingCardView = showingCardView
        _learningCards = State(initialValue: cardsToStudy.map { LearningCard(card: $0) })
    }
    
    var body: some View {
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
                    Rectangle()
                        .frame(width: geometry.size.width , height: geometry.size.height)
                        .foregroundColor(colorScheme == .dark ? .navy : .teal)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: colorScheme == .dark ? [.teal, .mint] : [.navy, .ocean], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: min(CGFloat(Float(learningCards.filter { !$0.isLearning }.count) / Float(learningCards.count))*geometry.size.width, geometry.size.width), height: 10)
                        .animation(.spring())
                }
            }
            .cornerRadius(5)
            .frame(height: 10)
            
            ZStack(alignment: .center) {
                GeometryReader { geometry in
                    VStack {
                        Text("Finished!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? Color.teal : Color.ocean)
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? Color.teal : Color.ocean)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                        Text("You've learned \(learningCards.count) cards")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? Color.teal : Color.ocean)
                            .padding(.top)
                    }
                    .scaleEffect(isFinished ? 1 : 0.1)
                    .opacity(isFinished ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                
                ScrollView {
                    ScrollViewReader { value in
                        VStack {
                            Spacer().frame(height: 20).id("TopSpacer")
                            
                            VStack {
                                Text(learningCards[index].card.text ?? "Unknown")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text(learningCards[index].card.phoneticsArray.first(where: { $0.audio?.contains("us.mp3") ?? false })?.text ?? learningCards[index].card.phoneticsArray.first?.text ?? "Unknown")
                                    .foregroundColor(.primary)
                            }
                            .opacity(isWordVisible ? 1 : 0)
                            .animation(.easeIn(duration: 0.3), value: isWordVisible)
                            .onTapGesture {
                                AudioViewModel.shared.speechText(learningCards[index].card.text)
                            }
                            
                            ZStack {
                                VStack {
                                    ForEach(learningCards[index].card.meaningsArray.indices, id: \.self) { idx in
                                        if idx != 0 {
                                            Divider()
                                            Spacer().frame(height: 20)
                                        }
                                        DefinitionDetailView(meaning: learningCards[index].card.meaningsArray[idx], index: idx)
                                    }
                                    
                                    Spacer().frame(height: 20)
                                    
                                    VStack(spacing: 2) {
                                        HStack(spacing: 2) {
                                            GridImage(card: learningCards[index].card, index: 0, size: gridSize)
                                            GridImage(card: learningCards[index].card, index: 1, size: gridSize)
                                        }
                                        HStack(spacing: 2) {
                                            GridImage(card: learningCards[index].card, index: 2, size: gridSize)
                                            GridImage(card: learningCards[index].card, index: 3, size: gridSize)
                                        }
                                    }
                                    .frame(height: gridSize * 2 + 2)
                                    
                                    Text("Powered by Pixabay")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Rectangle()
                                    .fill(Color(UIColor.systemBackground))
                                    .opacity(isVStackVisible ? 0 : 1)
                                    .animation(.easeIn(duration: 0.3), value: isVStackVisible)
                                    .zIndex(1)
                            }
                            
                            Spacer().frame(height: 20)
                        }
                        .onChange(of: shouldScrollToTop) { _ in
                            value.scrollTo("TopSpacer", anchor: .top)
                            shouldScrollToTop = false
                        }
                    }
                }.opacity(isFinished ? 0 : 1)
            }
            
            ZStack {
                Button(action: {
                    showingCardView = false
                }) {
                    Text("Go to Top Page")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: colorScheme == .dark ? [.ocean, .teal] : [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
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
                            shouldScrollToTop = true
                            
                            let card = learningCards[index].card
                            card.failedTimes += 1
                            card.status = 1
                            dataViewModel.persistence.saveContext()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                AudioViewModel.shared.speechText(card.text)
                            }
                        }
                    }) {
                        Text("Hard")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        guard isButtonEnabled else { return }
                        
                        isButtonEnabled = false
                        isVStackVisible = false
                        isWordVisible = false
                        
                        learningCards[index].isLearning = false
                        learningCards[index].card.status = 0
                        dataViewModel.persistence.saveContext()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.none) {
                                if index + 1 == learningCards.count {
                                    isFinished = true
                                } else {
                                    index += 1
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        AudioViewModel.shared.speechText(learningCards[index].card.text)
                                    }
                                }
                            }
                            
                            isButtonEnabled = true
                            isWordVisible = true
                            shouldScrollToTop = true
                        }
                    }) {
                        Text("Easy")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }.opacity(isFinished ? 0 : 1)
                
            }
        }
        .padding([.leading, .trailing], 10)
        .background(Color(UIColor.systemBackground).ignoresSafeArea(.all, edges: .top))
        .onTapGesture {
            isVStackVisible = true
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AudioViewModel.shared.speechText(learningCards[0].card.text)
            }
            
            AudioViewModel.shared.setCategoryToPlayback()
        }
    }
}

struct CardView_Previews: PreviewProvider {
    @State static var showingCardView = true

    static var previews: some View {
        CardView(showingCardView: $showingCardView, cardsToStudy: [])
            .environment(\.managedObjectContext, persistence.preview.container.viewContext)
    }
}
