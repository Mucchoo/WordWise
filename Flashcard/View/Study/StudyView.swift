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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .frame(height: 120)
                        .overlay(
                            HStack {
                                Spacer().frame(width: 10)
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .fontWeight(.black)
                                    Text("\(learnedWords)")
                                        .font(.title)
                                        .foregroundColor(.black)
                                    Text("Learned")
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider().background(Color.gray)
                                    .frame(height: 80)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.red)
                                        .fontWeight(.black)
                                    Text("\(learningWords)")
                                        .font(.title)
                                        .foregroundColor(.black)
                                    Text("Learning")
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider().background(Color.gray)
                                    .frame(height: 80)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "star.circle.fill")
                                        .foregroundColor(.yellow)
                                        .fontWeight(.black)
                                    Text("\(newWords)")
                                        .font(.title)
                                        .foregroundColor(.black)
                                    Text("New")
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                Spacer().frame(width: 10)
                            }
                                .foregroundColor(.white)
                        )
                        .padding()
                    
                    
                    Button(action: {
                        // Action to start studying
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
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Study", displayMode: .large)
        }
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
