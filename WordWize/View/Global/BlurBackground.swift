//
//  GroupedBackground.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct BlurBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                TransparentBlurView(removeAllLayers: true)
                    .blur(radius: 9, opaque: true)
                    .background(Color.init(white: colorScheme == .dark ? 0.2 : 1)).opacity(0.5)
            }
            .cornerRadius(10)
            .clipped()
            .padding()
    }
}
