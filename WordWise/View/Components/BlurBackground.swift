//
//  BlurBackground.swift
//  WordWise
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
                TransparentBlurView()
                    .blur(radius: 9, opaque: true)
                    .background(Color.init(white: colorScheme == .dark ? 0.25 : 1)).opacity(0.5)
            }
            .cornerRadius(10)
            .clipped()
            .padding()
    }
}

extension View {
    func blurBackground() -> some View {
        modifier(BlurBackground())
    }
}

private struct TransparentBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> TransparentBlurViewHelper {
        return TransparentBlurViewHelper()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if let backdropLayer = uiView.layer.sublayers?.first {
                backdropLayer.filters = []
            }
        }
    }
}

private class TransparentBlurViewHelper: UIVisualEffectView {
    init() {
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        if let backdropLayer = layer.sublayers?.first {
            backdropLayer.filters = []
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {}
}
