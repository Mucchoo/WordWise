//
//  BlurBackground.swift
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
    var removeAllLayers = false
    func makeUIView(context: Context) -> TransparentBlurViewHelper {
        return TransparentBlurViewHelper(removeAllFilters: removeAllLayers)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if let backdropLayer = uiView.layer.sublayers?.first {
                if removeAllLayers {
                    backdropLayer.filters = []
                } else {
                    backdropLayer.filters?.removeAll(where: { filter in
                        String(describing: filter) != "gaussianBlur"
                    })
                }
            }
        }
    }
}

private class TransparentBlurViewHelper: UIVisualEffectView {
    init(removeAllFilters: Bool) {
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        if let backdropLayer = layer.sublayers?.first {
            if removeAllFilters {
                backdropLayer.filters = []
            } else {
                backdropLayer.filters?.removeAll(where: { filter in
                    String(describing: filter) != "gaussianBlur"
                })
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {}
}
