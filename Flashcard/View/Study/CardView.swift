//
//  CardView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct CardView: View {
    @State private var learnedWords = Mock.words.filter { $0.status == .learned }.count
    @State private var learningWords = Mock.words.filter { $0.status == .learning }.count
    @State private var newWords = Mock.words.filter { $0.status == .new }.count
    @State private var totalWords = Mock.words.count
    @State private var progress: Float = 0.0

    var body: some View {
        VStack {
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
            
            Spacer().frame(height: 20)
            Text("stick together")
                .font(.headline)
            Text("stik ta'gedar")
            Spacer().frame(height: 20)
            
            
            VStack {
                Divider()
                
                VStack {
                    HStack {
                        Text("Meaning 1")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    HStack {
                        Text("to continue to support each other")
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    Spacer().frame(height: 10)
                    
                    HStack {
                        Text("Sample Sentence")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    HStack {
                        Text("we must stick together and work as a team")
                            .font(.subheadline)
                        Spacer()
                    }
                }
                
                Divider()
                
                VStack {
                    HStack {
                        Text("Meaning 2")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    HStack {
                        Text("to continue to support each other")
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    Spacer().frame(height: 10)
                    
                    HStack {
                        Text("Sample Sentence")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    HStack {
                        Text("we must stick together and work as a team")
                            .font(.subheadline)
                        Spacer()
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Synonym")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                HStack {
                    Text("seal, agree, collaborate, comply with, conspire, contribute, coordinate, further, help, participate, unite, uphold, accompany, marry, tie, attach, catch, fix, glue, hold")
                        .font(.subheadline)
                    Spacer()
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    //
                }) {
                    Text("Not OK")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    //
                }) {
                    Text("OK")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding([.leading, .trailing])
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
    }
}
