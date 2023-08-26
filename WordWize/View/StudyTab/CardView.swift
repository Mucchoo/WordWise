//
//  CardView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI
import Combine

struct LearningCard {
    let card: Card
    var isLearning = true
}

struct CardView: View {
    
    private let dismissGestureThreshold: CGFloat = 50
    private let loadingBarWidth: CGFloat = 60
    private let loadingBarHeight: CGFloat = 8
    private let audioViewModel = AudioViewModel()

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataViewModel: DataViewModel

    @Binding var showingCardView: Bool

    @State private var isDefinitionVisible = false
    @State private var isWordVisible = true
    @State private var learningCards: [LearningCard]
    @State private var index = 0
    @State private var isFinished = false
    @State private var shouldScrollToTop = false
    @State private var showTranslations = false
    @State private var translating = false

    init(showingCardView: Binding<Bool>, studyingCards: [Card]) {
        _showingCardView = showingCardView
        let cards = studyingCards.map { LearningCard(card: $0) }.shuffled()
        _learningCards = State(initialValue: cards)
    }

    var body: some View {
        VStack {
            // Dismiss bar
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(.systemGray4))
                .frame(width: loadingBarWidth, height: loadingBarHeight)
                .padding()
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.height > dismissGestureThreshold {
                                dismiss()
                            }
                        }
                )
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width , height: geometry.size.height)
                        .foregroundColor(colorScheme == .dark ? .navy : .teal)

                    let completedCards = learningCards.filter { !$0.isLearning }.count
                    let totalCards = learningCards.count
                    let progressBarWidth = min(CGFloat(Float(completedCards) / Float(totalCards)) * geometry.size.width, geometry.size.width)

                    Rectangle()
                        .fill(
                            LinearGradient(colors: colorScheme == .dark ? [.teal, .mint] : [.navy, .ocean], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: progressBarWidth, height: 10)
                        .animation(.spring(), value: completedCards)
                }
            }
            .cornerRadius(5)
            .frame(height: 10)
            
            WordInfoSection(
                learningCards: $learningCards,
                isFinished: $isFinished,
                isWordVisible: $isWordVisible,
                showTranslations: $showTranslations,
                translating: $translating,
                isDefinitionVisible: $isDefinitionVisible,
                shouldScrollToTop: $shouldScrollToTop,
                index: $index,
                audioViewModel: audioViewModel)
            
            BottomButtons(
                isDefinitionVisible: $isDefinitionVisible,
                showingCardView: $showingCardView,
                isWordVisible: $isWordVisible,
                showTranslations: $showTranslations,
                shouldScrollToTop: $shouldScrollToTop,
                isFinished: $isFinished,
                index: $index,
                learningCards: $learningCards,
                audioViewModel: audioViewModel)
        }
        .padding([.leading, .trailing], 10)
        .background(Color(UIColor.systemBackground).ignoresSafeArea(.all, edges: .top))
        .onTapGesture {
            isDefinitionVisible = true
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                audioViewModel.speechText(learningCards[0].card.text)
            }
            audioViewModel.setCategoryToPlayback()
        }
    }
}

#Preview {
    CardView(showingCardView: .constant(true), studyingCards: [])
        .injectMockDataViewModelForPreview()
}
