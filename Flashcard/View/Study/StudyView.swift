//
//  StudyView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @State private var learnedWords = Mock.words.filter { $0.status == .learned }.count
    @State private var learningWords = Mock.words.filter { $0.status == .learning }.count
    @State private var newWords = Mock.words.filter { $0.status == .new }.count
    @State private var totalWords = Mock.words.count
    @State private var showingCardView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .frame(height: 120)
                        .overlay(
                            HStack {
                                InfoCard(systemName: "checkmark.circle.fill", count: learnedWords, title: "Learned", color: .blue)
                                
                                Divider().background(Color.gray)
                                    .frame(height: 80)
                                
                                InfoCard(systemName: "pencil.circle.fill", count: learningWords, title: "Learning", color: .red)
                                
                                Divider().background(Color.gray)
                                    .frame(height: 80)
                                
                                InfoCard(systemName: "star.circle.fill", count: newWords, title: "New", color: .yellow)
                            }
                            .foregroundColor(.white)
                        )
                        .padding()
                    
                    StartStudyingButton(showingCardView: $showingCardView)
                    
                    WordsSection(totalWords: totalWords)
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Study", displayMode: .large)
        }
    }
}

struct InfoCard: View {
    var systemName: String
    var count: Int
    var title: String
    var color: Color
    
    var body: some View {
        Spacer().frame(width: 10)
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .foregroundColor(color)
                .fontWeight(.black)
            Text("\(count)")
                .font(.title)
                .foregroundColor(.black)
            Text(title)
                .font(.footnote)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
}


struct StartStudyingButton: View {
    @Binding var showingCardView: Bool
    
    var body: some View {
        Button(action: {
            showingCardView = true
        }) {
            Text("Start Studying")
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
        .fullScreenCover(isPresented: $showingCardView) {
            CardView(showingCardView: $showingCardView)
        }
    }
}

struct WordsSection: View {
    var totalWords: Int
    
    var body: some View {
        Divider()
            .padding()
        
        HStack {
            Spacer().frame(width: 20)
            Text("\(totalWords) Words")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }
        
        VStack(spacing: 8) {
            ForEach(Mock.words) { word in
                WordListRowView(word: word)
            }
        }
    }
}


struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
