//
//  WordInfoSection.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/26/23.
//

import SwiftUI

struct WordInfoSection: View {
    @EnvironmentObject private var dataViewModel: DataViewModel
    @Environment(\.colorScheme) private var colorScheme

    @Binding var learningCards: [LearningCard]
    @Binding var isFinished: Bool
    @Binding var isWordVisible: Bool
    @Binding var showTranslations: Bool
    @Binding var translating: Bool
    @Binding var isDefinitionVisible: Bool
    @Binding var shouldScrollToTop: Bool
    @Binding var index: Int
    

    let audioViewModel: AudioViewModel
    private let gridSize = (UIScreen.main.bounds.width - 21) / 2
    
    var body: some View {
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
                                audioViewModel.speechText(learningCards[index].card.text)
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
                                    
                                    Text("Powered by Pixabay")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
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
    }
}
