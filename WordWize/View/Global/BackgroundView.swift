//
//  BackgroundView.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(
                colors: colorScheme == .light ? [.init(white: 0.9), .mint] : [.black, .navy]),
                startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

extension View {
    func backgroundView() -> some View {
        self.background(BackgroundView())
    }
}

#Preview {
    BackgroundView()
}
