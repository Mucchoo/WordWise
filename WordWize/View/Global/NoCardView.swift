//
//  NoCardView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct NoCardView: View {
    let image: String
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                SlimeAnimationView()
                VStack {
                    Image(image)
                        .resizable()
                        .fontWeight(.bold)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 320, height: 230)
                        .foregroundColor(.white)
                    Text("You have no cards yet.\nGo '\(Image(systemName: "plus.square"))' to add your first one!")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

private struct SlimeAnimationView: View {
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

private extension CGSize {
    static func randomOffset() -> CGSize {
        let horizontalRange = UIScreen.main.bounds.width / 2 + 100
        let verticalRange = UIScreen.main.bounds.height / 2 + 100
        return CGSize(
            width: .random(in: -horizontalRange...horizontalRange),
            height: .random(in: -verticalRange...verticalRange))
    }
}

#Preview {
    NoCardView(image: "BoyLeft")
}
