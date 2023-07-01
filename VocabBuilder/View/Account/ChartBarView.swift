//
//  ChartBarView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct ChartBarView: View {
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @State var status: Int
    var name: String
    var image: String
    var color: Color
    
    @State private var progress: CGFloat = 0
    @State private var counter: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(color)
                    .frame(width: 55 + progress * (geometry.size.width - 55), height: 30)
                    .animation(.easeInOut(duration: 1))
                HStack(spacing: 2) {
                    Image(systemName: image)
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                    Text("\(counter)")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            .onAppear {
                let cardCount = cards.count
                let filteredCount = cards.filter { $0.status == status }.count
                
                progress = CGFloat(filteredCount) / CGFloat(cardCount)
                withAnimation(.easeInOut(duration: 2)) {
                    for i in 0...filteredCount {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) / 20.0) {
                            counter = i
                        }
                    }
                }
            }
        }
        .frame(height: 30)
    }
}

struct ChartBarView_Previews: PreviewProvider {
    static var previews: some View {
        ChartBarView(status: 0, name: "Learned", image: "checkmark.circle.fill", color: .blue)
    }
}
