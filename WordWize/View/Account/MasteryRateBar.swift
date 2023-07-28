//
//  ChartBarView.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct MasteryRateBar: View {
    @EnvironmentObject var dataViewModel: DataViewModel

    @State private var progress: CGFloat = 0
    @State private var isLoaded = false
    @State private var countText = ""
    
    let rateText: String
    let colors: [Color]
    let rate: MasteryRate
    
    init(_ rate: MasteryRate) {
        self.rate = rate
        
        switch rate {
        case .zero:
            rateText = "0%"
            colors = [.black, .black, .navy]
        case .twentyFive:
            rateText = "25%"
            colors = [.black, .navy, .navy]
        case .fifty:
            rateText = "50%"
            colors = [.navy, .ocean, .ocean]
        case .seventyFive:
            rateText = "75%"
            colors = [.ocean, .ocean, .teal]
        case .oneHundred:
            rateText = "100%"
            colors = [.ocean, .teal, .teal]
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 90 + progress * (geometry.size.width - 90), height: 30)
                    .animation(.easeInOut(duration: 1), value: progress)
                HStack(spacing: 2) {
                    Text(rateText)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font(.footnote)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    Text(isLoaded ? countText : "")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .animation(isLoaded ? .easeInOut(duration: 1) : .none)
                    
                    Spacer()
                        .frame(width: 6)
                }
                .frame(width: 85 + progress * (geometry.size.width - 85), height: 30)
                .animation(isLoaded ? .easeInOut(duration: 1) : .none, value: isLoaded)
            }
            .onAppear {
                isLoaded = false
                countText = "\(dataViewModel.cards.filter { $0.rate == rate }.count)"
                progress = dataViewModel.maxStatusCount > 0 ? CGFloat(dataViewModel.cards.filter { $0.rate == rate }.count) / CGFloat(dataViewModel.maxStatusCount) : 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isLoaded = true
                }
            }
        }
        .frame(height: 30)
        .accessibilityIdentifier("chartBar\(rate)")
    }
}

#Preview {
    MasteryRateBar(.oneHundred)
}
