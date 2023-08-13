//
//  MasteryRateBars.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct MasteryRateBars: View {
    @State var categoryName = ""
    
    var body: some View {
        VStack(spacing: 8) {
            MasteryRateBar(.oneHundred, categoryName: categoryName)
            MasteryRateBar(.seventyFive, categoryName: categoryName)
            MasteryRateBar(.fifty, categoryName: categoryName)
            MasteryRateBar(.twentyFive, categoryName: categoryName)
            MasteryRateBar(.zero, categoryName: categoryName)
        }
    }
}

#Preview {
    MasteryRateBars()
}
