//
//  ClubbedView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct ClubbedView: View {
    @Binding var initialAnimation: Bool
    var isNoCardView = false
    
    var body: some View {
        Rectangle()
            .fill(.linearGradient(colors: [Color("Teal"), Color("Mint")], startPoint: .top, endPoint: .bottom))
            .mask {
                TimelineView(.animation(minimumInterval: 20, paused: false)) { _ in
                    ZStack {
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.5, color: .yellow))
                            context.addFilter(.blur(radius: 30))
                            context.drawLayer { ctx in
                                for index in 1...30 {
                                    if let resolvedView = context.resolveSymbol(id: index) {
                                        ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                    }
                                }
                            }
                        } symbols: {
                            ForEach(1...30, id: \.self) { index in
                                ClubbedRoundedRectangle(offset: .randomOffset(), initialAnimation: initialAnimation, width: 100, height: 100, corner: 50)
                                    .tag(index)
                            }
                        }
                        
                        if isNoCardView {
                            Canvas { context, size in
                                context.addFilter(.alphaThreshold(min: 0.5, color: .yellow))
                                context.addFilter(.blur(radius: 30))
                                context.drawLayer { ctx in
                                    for index in 1...5 {
                                        if let resolvedView = context.resolveSymbol(id: index) {
                                            ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                        }
                                    }
                                }
                            } symbols: {
                                ForEach(1...5, id: \.self) { index in
                                    let offset = CGSize(width: .random(in: -50...50), height: .random(in: -50...50))
                                    ClubbedRoundedRectangle(offset: offset, initialAnimation: $initialAnimation.wrappedValue, width: 350, height: 350, corner: 175)
                                        .tag(index)
                                }
                            }
                        }
                    }
                }
            }
            .contentShape(Rectangle())
    }
    
    @ViewBuilder
    func ClubbedRoundedRectangle(offset: CGSize, initialAnimation: Bool, width: CGFloat, height: CGFloat, corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.white)
            .frame(width: width, height: height)
            .offset(x: initialAnimation ? offset.width : 0, y: initialAnimation ? offset.height : 0)
            .animation(.easeInOut(duration: 20), value: offset)
    }
}

@ViewBuilder
func ClubbedRoundedRectangle(offset: CGSize, initialAnimation: Bool, width: CGFloat, height: CGFloat, corner: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: corner, style: .continuous)
        .fill(.white)
        .frame(width: width, height: height)
        .offset(x: initialAnimation ? offset.width : 0, y: initialAnimation ? offset.height : 0)
        .animation(.easeInOut(duration: 5), value: offset)
}
extension CGSize {
    static func randomOffset() -> CGSize {
        return CGSize(width: .random(in: -300...300), height: .random(in: -500...500))
    }
}

struct ClubbedView_Previews: PreviewProvider {
    static var previews: some View {
        ClubbedView(initialAnimation: .constant(true))
    }
}
