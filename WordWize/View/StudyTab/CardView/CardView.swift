//
//  CardView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI
import Combine
import StoreKit

struct CardView: View {
    @ObservedObject var viewModel: CardViewModel
    @Binding var showingCardView: Bool

    init(showingCardView: Binding<Bool>, studyingCards: [Card]) {
        _showingCardView = showingCardView
        self.viewModel = CardViewModel(studyingCards: studyingCards)
    }

    var body: some View {
        VStack {
            DismissBar()
            ProgressBar(learningCards: $viewModel.learningCards)
            WordInfoSection(viewModel: viewModel)
            BottomButtons(viewModel: viewModel, showingCardView: $showingCardView)
        }
        .padding([.leading, .trailing], 10)
        .background(Color(UIColor.systemBackground).ignoresSafeArea(.all, edges: .top))
        .onTapGesture {
            viewModel.isDefinitionVisible = true
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.speechText(viewModel.learningCards[0].card.text)
            }
            viewModel.setCategoryToPlayback()
        }
    }
}

#Preview {
    CardView(showingCardView: .constant(true), studyingCards: [])
        .injectMockDataViewModelForPreview()
}

// MARK: - DismissBar

private struct DismissBar: View {
    @Environment(\.dismiss) private var dismiss

    private let dismissGestureThreshold: CGFloat = 50
    private let loadingBarWidth: CGFloat = 60
    private let loadingBarHeight: CGFloat = 8
    
    var body: some View {
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
    }
}

// MARK: - ProgressBar

private struct ProgressBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var learningCards: [LearningCard]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width , height: geometry.size.height)
                    .foregroundColor(colorScheme == .dark ? .navy : .teal)

                let completedCards = learningCards.filter { !$0.isLearning }.count
                let totalCards = learningCards.count
                let progressBarWidth = min(CGFloat(Float(completedCards) / Float(totalCards)) * geometry.size.width, geometry.size.width)

                Rectangle()
                    .fill(LinearGradient(colors: colorScheme == .dark ? [.teal, .mint] : [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                    .frame(width: progressBarWidth, height: 10)
                    .animation(.spring(), value: completedCards)
            }
        }
        .cornerRadius(5)
        .frame(height: 10)
    }
}

// MARK: - WordInfoSection

private struct WordInfoSection: View {
    @ObservedObject var viewModel: CardViewModel
    
    var body: some View {
        ZStack(alignment: .center) {
            CompletionView(viewModel: viewModel)
            
            ScrollView {
                ScrollViewReader { value in
                    VStack {
                        Spacer().frame(height: 20).id("TopSpacer")
                        
                        WordSection(viewModel: viewModel)
                        DefinitionSection(viewModel: viewModel)
                        ImageSection(viewModel: viewModel)
                        
                        Spacer().frame(height: 20)
                    }
                    .onChange(of: viewModel.shouldScrollToTop) { _ in
                        value.scrollTo("TopSpacer", anchor: .top)
                        viewModel.shouldScrollToTop = false
                    }
                }
            }.opacity(viewModel.isFinished ? 0 : 1)
        }
    }
}

private struct CompletionView: View {
    @Environment(\.colorScheme) private var colorScheme
    let viewModel: CardViewModel
    
    var body: some View {
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
                Text("You've learned \(viewModel.learningCards.count) cards")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? Color.teal : Color.ocean)
                    .padding(.top)
            }
            .scaleEffect(viewModel.isFinished ? 1 : 0.1)
            .opacity(viewModel.isFinished ? 1 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: viewModel.isFinished)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

private struct WordSection: View {
    @ObservedObject var viewModel: CardViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer().frame(width: 50, height: 40)
            
            Spacer()
            
            VStack {
                Text(viewModel.currentCard.card.text ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(viewModel.currentCard.card.phoneticsArray.first(where: { $0.audio?.contains("us.mp3") ?? false })?.text ?? viewModel.currentCard.card.phoneticsArray.first?.text ?? "")
                    .foregroundColor(.primary)
            }
            .opacity(viewModel.isWordVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.3), value: viewModel.isWordVisible)
            .onTapGesture {
                viewModel.speechText(viewModel.currentCard.card.text)
            }
            
            Spacer()
            
            Button {
                viewModel.onTranslateButton()
            } label: {
                if viewModel.translating {
                    ProgressView()
                        .scaleEffect(1, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.deepL))
                        .padding()
                } else {
                    Image("DeepL")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                        .tint(viewModel.showTranslations ? Color.white : Color.deepL)
                }
            }
            .frame(width: 40, height: 40)
            .background(viewModel.showTranslations ? Color.deepL : Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .opacity(viewModel.isDefinitionVisible ? 1 : 0)
            .padding(.trailing, 10)
            .animation(.easeIn(duration: 0.3), value: viewModel.isDefinitionVisible)
        }
    }
}

private struct DefinitionSection: View {
    @ObservedObject var viewModel: CardViewModel
    
    var body: some View {
        ZStack {
            VStack {
                ForEach(viewModel.currentCard.card.meaningsArray.indices, id: \.self) { idx in
                    if idx != 0 {
                        Group {
                            Divider()
                            Spacer().frame(height: 20)
                        }
                    }
                    DefinitionDetailView(meaning: viewModel.currentCard.card.meaningsArray[idx], index: idx, showTranslations: $viewModel.showTranslations)
                }
                
                Spacer().frame(height: 20)
            }
            
            Rectangle()
                .fill(Color(UIColor.systemBackground))
                .opacity(viewModel.isDefinitionVisible ? 0 : 1)
                .animation(.easeIn(duration: 0.3), value: viewModel.isDefinitionVisible)
                .zIndex(1)
        }
    }
}

private struct ImageSection: View {
    @ObservedObject var viewModel: CardViewModel
    private let gridSize = (UIScreen.main.bounds.width - 21) / 2

    var body: some View {
        if viewModel.currentCard.card.imageDatasArray.count > 0 {
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    GridImage(card: viewModel.currentCard.card, index: 0, size: gridSize)
                    GridImage(card: viewModel.currentCard.card, index: 1, size: gridSize)
                }
                if viewModel.currentCard.card.imageDatasArray.count > 2 {
                    HStack(spacing: 2) {
                        GridImage(card: viewModel.currentCard.card, index: 2, size: gridSize)
                        GridImage(card: viewModel.currentCard.card, index: 3, size: gridSize)
                    }
                }
            }
            .frame(height: gridSize * 2 + 2)
            
            Text("Powered by Pixabay")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

private struct GridImage: View {
    let card: Card
    let index: Int
    let size: CGFloat

    var body: some View {
        Group {
            if let imageData = card.imageDatasArray[safe: index]?.data,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .background {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 10)
                    }
                    .clipped()
            } else {
                Text("No\nImage")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .frame(width: size, height: size)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.navy, .ocean]), startPoint: .leading, endPoint: .trailing)
                    )
            }
        }
    }
}

private struct DefinitionDetailView: View {
    let meaning: Meaning
    let index: Int
    @Binding var showTranslations: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(meaning.partOfSpeech ?? "Unknown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                    .padding(.top, 4)
                    .background(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
            }
            
            ForEach(meaning.definitionsArray.indices, id: \.self) { index in
                if index != 0 {
                    Spacer().frame(height: 24)
                }
                
                let definition = meaning.definitionsArray[index]
                
                VStack(alignment: .leading) {
                    Text("\(index + 1). \(showTranslations ? definition.translatedDefinition ?? "" : definition.definition ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                                        
                    InformationRow(label: "Example", content: definition.example)
                    InformationRow(label: "Synonyms", content: definition.synonyms)
                    InformationRow(label: "Antonyms", content: definition.antonyms)
                }
            }
        }
    }
}

private struct InformationRow: View {
    let label: String
    let content: String?
    
    var body: some View {
        if let content = content, !content.isEmpty {
            Spacer().frame(height: 8)
            Text("\(label): \(content)")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - BottomButtons

private struct BottomButtons: View {
    @Environment(\.colorScheme) private var colorScheme
    let viewModel: CardViewModel
    @Binding var showingCardView: Bool
    
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
            }.opacity(viewModel.isFinished ? 1 : 0)
            
            HStack {
                Button(action: {
                    viewModel.hardButtonPressed()
                }) {
                    Text("Hard")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.easyButtonPressed()
                }) {
                    Text("Easy")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .opacity(viewModel.isFinished ? 0 : 1)
            .onChange(of: viewModel.showReviewAlert) { newValue in
                viewModel.requestReviewIfNeeded(shouldRequest: newValue)
            }
        }
    }
}
