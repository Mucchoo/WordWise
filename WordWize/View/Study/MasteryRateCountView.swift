//
//  StatusButton.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct MasteryRateCountView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    var masteryRate: MasteryRate
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(masteryRate.stringValue() + "%:")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 2)
            Text("\(dataViewModel.cards.filter({ $0.masteryRate == masteryRate.rawValue }).count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("cards")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 6)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: getColors(), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    func getColors() -> [Color] {
        switch masteryRate {
        case .zero:
            return [.black, .navy]
        case .twentyFive:
            return [.navy, .ocean]
        case .fifty:
            return [.navy, .ocean]
        case .seventyFive:
            return [.ocean, .teal]
        case .oneHundred:
            return []
        }
    }
}

#Preview {
    MasteryRateCountView(masteryRate: .zero)
}
