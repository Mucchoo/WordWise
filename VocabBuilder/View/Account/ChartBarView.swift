//
//  ChartBarView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct ChartBarView: View {
    @ObservedObject var dataViewModel = DataViewModel.shared
    @State var status: Int
    var name: String
    var image: String
    var colors: [Color]
    
    @State private var progress: CGFloat = 0
    @State private var counter: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)

                    )
                    .frame(width: 60 + progress * (geometry.size.width - 60), height: 30)
                    .animation(.easeInOut(duration: 1))
                HStack(spacing: 2) {
                    Image(systemName: image)
                        .font(.system(size: 14))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .frame(width: 14)
                        .padding(.leading, 10)
                    Spacer()
                    Text("\(counter)   ")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(width: 55 + progress * (geometry.size.width - 55), height: 30)
                .animation(.easeInOut(duration: 1))
            }
            .onAppear {
                let cardCount = dataViewModel.cards.count
                let filteredCount = dataViewModel.cards.filter { $0.status == status }.count
                
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
        ChartBarView(status: 0, name: "Learned", image: "checkmark", colors: [.black, .blue])
    }
}
