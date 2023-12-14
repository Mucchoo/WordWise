//
//  GradientBackground.swift
//  WordWise
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct GradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(
                colors: colorScheme == .light ? [.init(white: 0.9), .cyan] : [.black, .navy]),
                startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

extension View {
    func gradientBackground() -> some View {
        self.background(GradientBackground())
    }
}

#Preview {
    GradientBackground()
}
