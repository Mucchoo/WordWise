//
//  CardView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI
import Combine
import StoreKit

private struct LearningCard {
    let card: Card
    var isLearning = true
}

struct CardView: View {
    private let audioViewModel = AudioViewModel()
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
            DismissBar()
            ProgressBar(learningCards: $learningCards)
            
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
                    .fill(
                        LinearGradient(colors: colorScheme == .dark ? [.teal, .mint] : [.navy, .ocean], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: progressBarWidth, height: 10)
                    .animation(.spring(), value: completedCards)
            }
        }
        .cornerRadius(5)
        .frame(height: 10)
    }
}

private struct WordInfoSection: View {
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

private struct BottomButtons: View {
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

private struct AppStoreReviewModifier: ViewModifier {
    @Binding var showReviewRequest: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: showReviewRequest) { newValue in
                if newValue, let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    DispatchQueue.main.async {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
                showReviewRequest = false
            }
    }
}

private extension View {
    func appStoreReviewModifier(showReviewRequest: Binding<Bool>) -> some View {
        self.modifier(AppStoreReviewModifier(showReviewRequest: showReviewRequest))
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
                                        
                    if let example = definition.example, !example.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Example: " + example)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    if let synonyms = definition.synonyms, !synonyms.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Synonyms: " + synonyms)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    if let antonyms = definition.antonyms, !antonyms.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Antonyms: " + antonyms)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
