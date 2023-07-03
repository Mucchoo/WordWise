//
//  GroupedBackground.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct BlurBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                TransparentBlurView(removeAllLayers: true)
                    .blur(radius: 9, opaque: true)
                    .background(Color(UIColor.systemGroupedBackground).opacity(0.5))
            }
            .cornerRadius(10)
            .clipped()
            .padding()
    }
}
