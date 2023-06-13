//
//  StudyView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @State private var learnedWords = 30
    @State private var totalWords = 100
    
    var body: some View {
        VStack {
            Text("Study Status")
                .font(.largeTitle)
                .padding()

            HStack {
                VStack {
                    Text("\(learnedWords)")
                        .font(.headline)
                    Text("Learned Words")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("\(totalWords - learnedWords)")
                        .font(.headline)
                    Text("Unlearned Words")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .frame(height: 20)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width: CGFloat(learnedWords) / CGFloat(totalWords) * UIScreen.main.bounds.width, height: 20)
            }
            .padding([.leading, .trailing])

            Button(action: {
                // Action to start studying
            }) {
                Text("Start Studying")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
