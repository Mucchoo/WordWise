//
//  MasteryRateCountsView.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct MasteryRateCountsView: View {
    @Binding var category: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                MasteryRateCountView(masteryRate: .zero, category: $category)
                MasteryRateCountView(masteryRate: .twentyFive, category: $category)
            }
            HStack(spacing: 0) {
                MasteryRateCountView(masteryRate: .fifty, category: $category)
                MasteryRateCountView(masteryRate: .seventyFive, category: $category)
            }
        }
        .cornerRadius(20)
        .clipped()
    }
}

#Preview {
    MasteryRateCountsView(category: .constant(""))
        .injectMockDataViewModelForPreview()
}
