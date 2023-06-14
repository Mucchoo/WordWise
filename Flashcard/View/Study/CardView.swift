//
//  CardView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct CardView: View {
    @Binding var showingCardView: Bool
    @State private var learnedWords = Mock.words.filter { $0.status == .learned }.count
    @State private var totalWords = Mock.words.count
    @State private var isVStackVisible = true

    var body: some View {
        VStack {
            DragBar()
            ProgressView(learnedWords: $learnedWords, totalWords: totalWords)
            
            ScrollView {
                if isVStackVisible {
                    DefinitionView(isVStackVisible: $isVStackVisible)
                }
                
                Spacer()
            }
            
            ControlButtons(isVStackVisible: $isVStackVisible)
        }
        .padding([.leading, .trailing])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

struct DismissableSheet: View {
    @Binding var showingSheet: Bool

    var body: some View {
        VStack {
            DragBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

struct DragBar: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
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
    }
}

struct ProgressView: View {
    @Binding var learnedWords: Int
    let totalWords: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.5))
                .frame(height: 20)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .frame(width: CGFloat(learnedWords) / CGFloat(totalWords) * UIScreen.main.bounds.width, height: 20)
            
            HStack {
                Text("\(learnedWords)")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(totalWords - learnedWords)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding([.leading, .trailing])
        }
    }
}

struct DefinitionView: View {
    @Binding var isVStackVisible: Bool
    
    var body: some View {
        VStack {
            Spacer().frame(height: 20)
            WordDefinitionView(word: "stick together", pronunciation: "stik ta'gedar")
            Spacer().frame(height: 20)
            
            DefinitionDetailView(title: "Meaning 1: noun", description: "to continue to support each other", sample: "we must stick together and work as a team")
            
            Divider()
            
            DefinitionDetailView(title: "Meaning 2: exclamation", description: "to continue to support each other", sample: "we must stick together and work as a team")
            
            Divider()
            
            DefinitionDetailView(title: "Meaning 3: verb", description: "to continue to support each other", sample: "we must stick together and work as a team")
            
            Divider()
            
            SynonymView(synonyms: "seal, agree, collaborate, comply with, conspire, contribute, coordinate, further, help, participate, unite, uphold, accompany, marry, tie, attach, catch, fix, glue, hold")
        }
        .opacity(isVStackVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3))
    }
}

struct WordDefinitionView: View {
    let word: String
    let pronunciation: String
    
    var body: some View {
        VStack {
            Text(word)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(pronunciation)
                .foregroundColor(.primary)
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

struct ControlButtons: View {
    @Binding var isVStackVisible: Bool
    
    var body: some View {
        HStack {
            ToggleButton(title: "Easy", color: .blue, isVStackVisible: $isVStackVisible)
            
            ToggleButton(title: "Hard", color: .red, isVStackVisible: $isVStackVisible)
        }
    }
}

struct ToggleButton: View {
    let title: String
    let color: Color
    @Binding var isVStackVisible: Bool
    
    var body: some View {
        Button(action: {
            isVStackVisible = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isVStackVisible = true
            }
        }) {
            Text(title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    @State static var showingCardView = true

    static var previews: some View {
        CardView(showingCardView: $showingCardView)
    }
}
