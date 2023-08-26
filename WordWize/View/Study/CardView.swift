//
//  CardView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI
import Combine

struct CardView: View {
    struct LearningCard {
        let card: Card
        var isLearning = true
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataViewModel: DataViewModel
    @Binding var showingCardView: Bool
    @State private var isDefinitionVisible = false
    @State private var isWordVisible = true
    @State private var learningCards: [LearningCard]
    @State private var index = 0
    @State private var isFinished = false
    @State private var isButtonEnabled = true
    @State private var shouldScrollToTop: Bool = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showTranslations = false
    @State private var translating = false
    @State private var showReviewAlert = false
    
    let gridSize = (UIScreen.main.bounds.width - 21) / 2
    
    init(showingCardView: Binding<Bool>, studyingCards: [Card]) {
        _showingCardView = showingCardView
        let cards = studyingCards.map { LearningCard(card: $0) }.shuffled()
        _learningCards = State(initialValue: cards)
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
                        .animation(.spring(), value: learningCards.filter { !$0.isLearning }.count)
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
                    .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: isFinished)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                
                ScrollView {
                    ScrollViewReader { value in
                        VStack {
                            Spacer().frame(height: 20).id("TopSpacer")
                            
                            HStack(alignment: .center, spacing: 0) {
                                Spacer().frame(width: 50, height: 40)
                                
                                Spacer()
                                
                                VStack {
                                    Text(learningCards[index].card.text ?? "")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Text(learningCards[index].card.phoneticsArray.first(where: { $0.audio?.contains("us.mp3") ?? false })?.text ?? learningCards[index].card.phoneticsArray.first?.text ?? "")
                                        .foregroundColor(.primary)
                                }
                                .opacity(isWordVisible ? 1 : 0)
                                .animation(.easeIn(duration: 0.3), value: isWordVisible)
                                .onTapGesture {
                                    AudioViewModel.shared.speechText(learningCards[index].card.text)
                                }
                                
                                Spacer()
                                
                                Button {
                                    if showTranslations {
                                        showTranslations = false
                                    } else {
                                        translating = true
                                        dataViewModel.translateDefinitions(learningCards[index].card) {
                                            self.translating = false
                                            self.showTranslations = true
                                        }
                                    }
                                    
                                } label: {
                                    if translating {
                                        ProgressView()
                                            .scaleEffect(1, anchor: .center)
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color.deepL))
                                            .padding()
                                    } else {
                                        Image("DeepL")
                                            .resizable()
                                            .frame(width: 25, height: 25, alignment: .center)
                                            .tint(showTranslations ? Color.white : Color.deepL)
                                    }
                                }
                                .frame(width: 40, height: 40)
                                .background(showTranslations ? Color.deepL : Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .opacity(isDefinitionVisible ? 1 : 0)
                                .padding(.trailing, 10)
                                .animation(.easeIn(duration: 0.3), value: isDefinitionVisible)
                            }
                            
                            ZStack {
                                VStack {
                                    ForEach(learningCards[index].card.meaningsArray.indices, id: \.self) { idx in
                                        if idx != 0 {
                                            Divider()
                                            Spacer().frame(height: 20)
                                        }
                                        DefinitionDetailView(meaning: learningCards[index].card.meaningsArray[idx], index: idx, showTranslations: $showTranslations)
                                    }
                                    
                                    Spacer().frame(height: 20)
                                    
                                    if learningCards[index].card.imageDatasArray.count > 0 {
                                        VStack(spacing: 2) {
                                            HStack(spacing: 2) {
                                                GridImage(card: learningCards[index].card, index: 0, size: gridSize)
                                                GridImage(card: learningCards[index].card, index: 1, size: gridSize)
                                            }
                                            if learningCards[index].card.imageDatasArray.count > 2 {
                                                HStack(spacing: 2) {
                                                    GridImage(card: learningCards[index].card, index: 2, size: gridSize)
                                                    GridImage(card: learningCards[index].card, index: 3, size: gridSize)
                                                }
                                            }
                                        }
                                        .frame(height: gridSize * 2 + 2)
                                    }
                                    
                                    Text("Powered by Pixabay")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Rectangle()
                                    .fill(Color(UIColor.systemBackground))
                                    .opacity(isDefinitionVisible ? 0 : 1)
                                    .animation(.easeIn(duration: 0.3), value: isDefinitionVisible)
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
                        isDefinitionVisible = false
                        isWordVisible = false
                        showTranslations = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.none) {
                                let card = learningCards.remove(at: index)
                                learningCards.append(card)
                            }
                            
                            isButtonEnabled = true
                            isWordVisible = true
                            shouldScrollToTop = true
                            
                            let card = learningCards[index].card
                            card.lastHardDate = Date()
                            card.masteryRate = 0
                            dataViewModel.persistence.saveContext()
                            dataViewModel.loadData()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                AudioViewModel.shared.speechText(card.text)
                            }
                        }
                    }) {
                        Text("Hard")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        guard isButtonEnabled else { return }
                        
                        isButtonEnabled = false
                        isDefinitionVisible = false
                        isWordVisible = false
                        showTranslations = false

                        learningCards[index].isLearning = false

                        var nextLearningDate = 0
                        if let date = learningCards[index].card.lastHardDate, Calendar.current.isDateInToday(date) {
                            nextLearningDate = 1
                        } else {
                            switch learningCards[index].card.rate {
                            case .zero:
                                nextLearningDate = 2
                            case .twentyFive:
                                nextLearningDate = 4
                            case .fifty:
                                nextLearningDate = 7
                            case .seventyFive:
                                nextLearningDate = 14
                            default:
                                break
                            }
                            
                            learningCards[index].card.nextLearningDate = Calendar.current.date(byAdding: .day, value: nextLearningDate, to: Date())
                            learningCards[index].card.masteryRate += 1
                        }
                        
                        dataViewModel.persistence.saveContext()
                        dataViewModel.loadData()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                            withAnimation(.none) {
                                if index + 1 == learningCards.count {
                                    isFinished = true
                                    
                                    if learningCards.count > 20 {
                                        showReviewAlert = true
                                    }
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
                    .appStoreReviewModifier(showReviewRequest: $showReviewAlert)
                }.opacity(isFinished ? 0 : 1)
                
            }
        }
        .padding([.leading, .trailing], 10)
        .background(Color(UIColor.systemBackground).ignoresSafeArea(.all, edges: .top))
        .onTapGesture {
            isDefinitionVisible = true
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AudioViewModel.shared.speechText(learningCards[0].card.text)
            }
            
            AudioViewModel.shared.setCategoryToPlayback()
        }
    }
}

#Preview {
    CardView(showingCardView: .constant(true), studyingCards: [])
        .injectMockDataViewModelForPreview()
}
