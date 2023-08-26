//
//  BottomButtons.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/26/23.
//

import SwiftUI

struct BottomButtons: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @State private var isButtonEnabled = true
    @State private var showReviewAlert = false
    
    @Binding var isDefinitionVisible: Bool
    @Binding var showingCardView: Bool
    @Binding var isWordVisible: Bool
    @Binding var showTranslations: Bool
    @Binding var shouldScrollToTop: Bool
    @Binding var isFinished: Bool
    @Binding var index: Int
    @Binding var learningCards: [LearningCard]
    
    let audioViewModel: AudioViewModel

    var body: some View {
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
                            audioViewModel.speechText(card.text)
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
                                    audioViewModel.speechText(learningCards[index].card.text)
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
}
