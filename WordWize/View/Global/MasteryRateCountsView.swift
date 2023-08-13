//
//  MasteryRateCountsView.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct MasteryRateCountsView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                MasteryRateCountView(masteryRate: .zero)
                MasteryRateCountView(masteryRate: .twentyFive)
            }
            HStack(spacing: 0) {
                MasteryRateCountView(masteryRate: .fifty)
                MasteryRateCountView(masteryRate: .seventyFive)
            }
        }
        .cornerRadius(20)
        .clipped()
        .padding()
    }
}

#Preview {
    MasteryRateCountsView()
}
