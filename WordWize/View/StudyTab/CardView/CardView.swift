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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: CardViewModel
    @Binding private var showingCardView: Bool
    private let gridSize = (UIScreen.main.bounds.width - 21) / 2

    init(vm: CardViewModel, showingCardView: Binding<Bool>) {
        _vm = StateObject(wrappedValue: vm)
        _showingCardView = showingCardView
    }

    var body: some View {
        VStack {
            dismissBar
            progressBar
            wordSection
            wordInfoSection
            bottomButtons
        }
        .padding([.leading, .trailing], 10)
        .background(Color(UIColor.systemBackground).ignoresSafeArea(.all, edges: .top))
        .onTapGesture {
            vm.isDefinitionVisible = true
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                vm.speechText(vm.learningCards[safe: 0]?.card.text)
            }
        }
    }
    
    private var dismissBar: some View {
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
            .accessibilityIdentifier("dismissBar")
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width , height: geometry.size.height)
                    .foregroundColor(colorScheme == .dark ? .navy : .sky)
                    .accessibilityIdentifier("progressBarBackgroundRectangle")

                let completedCards = vm.learningCards.filter { !$0.isLearning }.count
                let totalCards = vm.learningCards.count
                let progressBarWidth = min(CGFloat(Float(completedCards) / Float(totalCards)) * geometry.size.width, geometry.size.width)

                Rectangle()
                    .fill(LinearGradient(colors: colorScheme == .dark ? [.sky, .cyan] : [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                    .frame(width: progressBarWidth, height: 10)
                    .animation(.spring(), value: completedCards)
                    .accessibilityIdentifier("progressBarForegroundRectangle")
            }
        }
        .cornerRadius(5)
        .frame(height: 10)
    }
    
    private var wordInfoSection: some View {
        ZStack(alignment: .center) {
            completionView
            
            ScrollView {
                ScrollViewReader { value in
                    VStack {
                        Spacer().frame(height: 20).id("TopSpacer")
                        
                        ZStack {
                            VStack {
                                definitionSection
                                
                                if vm.currentCard.card.imageDatasArray.count > 0 {
                                    imageSection
                                }
                            }
                            
                            Rectangle()
                                .fill(Color(UIColor.systemBackground))
                                .opacity(vm.isDefinitionVisible ? 0 : 1)
                                .animation(.easeIn(duration: 0.3), value: vm.isDefinitionVisible)
                                .zIndex(1)
                                .accessibilityIdentifier("coverRectangle")
                        }
                        
                        Spacer().frame(height: 20)
                    }
                    .onChange(of: vm.shouldScrollToTop) { _ in
                        value.scrollTo("TopSpacer", anchor: .top)
                        vm.shouldScrollToTop = false
                    }
                }
            }
            .opacity(vm.isFinished ? 0 : 1)
        }
    }
    
    private var completionView: some View {
        GeometryReader { geometry in
            VStack {
                Text("Finished!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? Color.sky : Color.ocean)
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? Color.sky : Color.ocean)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                Text("You've learned \(vm.learningCards.count) cards")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? Color.sky : Color.ocean)
                    .padding(.top)
            }
            .scaleEffect(vm.isFinished ? 1 : 0.1)
            .opacity(vm.isFinished ? 1 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: vm.isFinished)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    private var wordSection: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer().frame(width: 50, height: 40)
            
            Spacer()
            
            VStack {
                Text(vm.currentCard.card.text ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(vm.currentCard.card.phoneticsArray.first?.text ?? "")
                    .foregroundColor(.primary)
            }
            .opacity(vm.isWordVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.3), value: vm.isWordVisible)
            .onTapGesture {
                vm.speechText(vm.currentCard.card.text)
            }
            
            Spacer()
            
            Button {
                vm.onTranslateButton()
            } label: {
                if vm.translating {
                    ProgressView()
                        .scaleEffect(1, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.deepL))
                        .padding()
                } else {
                    Image("DeepL")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                        .tint(vm.showTranslations ? Color.white : Color.deepL)
                }
            }
            .frame(width: 40, height: 40)
            .background(vm.showTranslations ? Color.deepL : Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .opacity(vm.isDefinitionVisible ? 1 : 0)
            .padding(.trailing, 10)
            .animation(.easeIn(duration: 0.3), value: vm.isDefinitionVisible)
        }
        .padding(.top, 10)
    }
    
    private var definitionSection: some View {
        VStack {
            ForEach(vm.currentCard.card.meaningsArray.indices, id: \.self) { idx in
                if idx != 0 {
                    Group {
                        Divider()
                        Spacer().frame(height: 20)
                    }
                }
                definitionDetailView(index: idx)
            }
            
            Spacer().frame(height: 20)
        }
    }
    
    private var imageSection: some View {
        VStack {
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    gridImage(card: vm.currentCard.card, index: 0, size: gridSize)
                    gridImage(card: vm.currentCard.card, index: 1, size: gridSize)
                }
                if vm.currentCard.card.imageDatasArray.count > 2 {
                    HStack(spacing: 2) {
                        gridImage(card: vm.currentCard.card, index: 2, size: gridSize)
                        gridImage(card: vm.currentCard.card, index: 3, size: gridSize)
                    }
                }
            }
            .frame(height: vm.currentCard.card.imageDatasArray.count > 2 ?
                   gridSize * 2 + 2 : gridSize)
            
            Text("Powered by Pixabay")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .onAppear {
            print("card images: \(vm.currentCard.card.imageDatasArray)")
            
        }
    }
    
    private func gridImage(card: Card, index: Int, size: CGFloat) -> some View {
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
    
    private func definitionDetailView(index: Int) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(vm.currentCard.card.meaningsArray[index].partOfSpeech ?? "")
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
            
            ForEach(vm.currentCard.card.meaningsArray[index].definitionsArray.indices, id: \.self) { idx in
                if idx != 0 {
                    Spacer().frame(height: 24)
                }
                
                let definition = vm.currentCard.card.meaningsArray[index].definitionsArray[idx]
                
                VStack(alignment: .leading) {
                    Text("\(idx + 1). \(vm.showTranslations ? definition.translatedDefinition ?? "" : definition.definition ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    if let content = definition.example, !content.isEmpty {
                        informationRow(label: "Example", content: content)
                    }
                    
                    if let content = definition.synonyms, !content.isEmpty {
                        informationRow(label: "Synonyms", content: content)
                    }
                    
                    if let content = definition.antonyms, !content.isEmpty {
                        informationRow(label: "Antonyms", content: content)
                    }
                }
            }
        }
    }
    
    private func informationRow(label: String, content: String) -> some View {
        Group {
            Spacer().frame(height: 8)
            Text("\(label): \(content)")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
    
    private var bottomButtons: some View {
        ZStack {
            Button(action: {
                showingCardView = false
            }) {
                Text("Go to Top Page")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: colorScheme == .dark ? [.ocean, .sky] : [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.opacity(vm.isFinished ? 1 : 0)
            
            HStack {
                Button(action: {
                    vm.hardButtonPressed()
                }) {
                    Text("Hard")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    vm.easyButtonPressed()
                }) {
                    Text("Easy")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .opacity(vm.isFinished ? 0 : 1)
            .onChange(of: vm.showReviewAlert) { newValue in
                let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                vm.requestReviewIfNeeded(shouldRequest: newValue, in: scene)
            }
        }
    }
}

#Preview {
    let container: DIContainer = .mock()
    container.appState.studyingCards = container.appState.cards
    
    return CardView(vm: .init(container: container),
                    showingCardView: .constant(true))
}
