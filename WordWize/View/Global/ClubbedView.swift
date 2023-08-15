//
//  ClubbedView.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct ClubbedView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animate = false
    
    let timer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()

    var body: some View {
        Rectangle()
            .fill(.linearGradient(colors: colorScheme == .dark ? [.navy, .ocean] : [.teal, .mint], startPoint: .top, endPoint: .bottom))
            .mask {
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
                            ClubbedRoundedRectangle(offset: .randomOffset(), width: 100, height: 100, corner: 50)
                                .tag(index)
                        }
                    }
                    
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
                            ClubbedRoundedRectangle(offset: offset, width: 350, height: 350, corner: 175)
                                .tag(index)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onAppear {
                DispatchQueue.main.async {
                    self.animate = true
                }
            }
            .onReceive(timer) { _ in
                animate.toggle()
            }
    }
    
    @ViewBuilder
    func ClubbedRoundedRectangle(offset: CGSize, width: CGFloat, height: CGFloat, corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.white)
            .frame(width: width, height: height)
            .offset(x: animate ? offset.width : offset.width, y: animate ? offset.height : offset.height)
            .animation(.easeInOut(duration: 20), value: animate)
    }
}

extension CGSize {
    static func randomOffset() -> CGSize {
        let horizontalRange = UIScreen.main.bounds.width / 2 + 100
        let verticalRange = UIScreen.main.bounds.height / 2 + 100
        return CGSize(
            width: .random(in: -horizontalRange...horizontalRange),
            height: .random(in: -verticalRange...verticalRange))
    }
}

struct ClubbedView_Previews: PreviewProvider {
    static var previews: some View {
        ClubbedView()
    }
}
