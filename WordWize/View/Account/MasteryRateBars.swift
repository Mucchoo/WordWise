//
//  MasteryRateBars.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct MasteryRateBars: View {
    var body: some View {
        VStack(spacing: 8) {
            MasteryRateBar(.oneHundred)
            MasteryRateBar(.seventyFive)
            MasteryRateBar(.fifty)
            MasteryRateBar(.twentyFive)
            MasteryRateBar(.zero)
        }
    }
}

#Preview {
    MasteryRateBars()
}
