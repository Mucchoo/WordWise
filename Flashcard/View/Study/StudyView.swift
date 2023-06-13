//
//  StudyView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @State private var learnedWords = 30
    @State private var learningWords = 20
    @State private var newWords = 50
    @State private var totalWords = 100
    let words: [String] = [
        "ability", "absence", "academy", "accuracy", "achievement",
        "acknowledgment", "activity", "addition", "administration", "admission",
        "advantage", "advice", "agreement", "alternative", "analysis",
        "announcement", "application", "appointment", "appreciation", "approach",
        "assessment", "assistance", "assumption", "attention", "attitude",
        "authority", "awareness", "behaviour", "benefit", "capacity",
        "challenge", "character", "circumstance", "collection", "combination",
        "communication", "community", "comparison", "competition", "complaint",
        "complexity", "compromise", "concentration", "concept", "conclusion",
        "condition", "confidence", "confirmation", "conflict", "connection",
        "consideration", "consistency", "content", "contribution", "conversation",
        "cooperation", "courage", "creation", "criticism", "decision",
        "definition", "department", "description", "determination", "development",
        "difference", "difficulty", "direction", "discussion", "distinction",
        "distribution", "education", "efficiency", "emergency", "emotion",
        "emphasis", "employment", "enjoyment", "environment", "equipment",
        "evaluation", "examination", "expectation", "experience", "explanation",
        "expression", "extension", "formation", "foundation", "function",
        "generation", "government", "guidance", "happiness", "identification",
        "imagination", "impression", "improvement", "independence", "information"
    ]
    
    var body: some View {
        NavigationView {
            VStack {

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .frame(height: 120)
                    .overlay(
                        HStack {
                            Spacer().frame(width: 10)
                            VStack {
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
                            
                            VStack {
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
                            
                            VStack {
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
                
                Spacer()
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
