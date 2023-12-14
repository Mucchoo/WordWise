//
//  NoCardView.swift
//  WordWise
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct NoCardView: View {
    @StateObject var vm = NoCardViewModel()
    @Environment(\.colorScheme) private var colorScheme
    let image: String
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                slimeAnimationView
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
    
    private var slimeAnimationView: some View {
        Rectangle()
            .fill(.linearGradient(colors: colorScheme == .dark ? [.navy, .ocean] : [.sky, .cyan], startPoint: .top, endPoint: .bottom))
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
                            SlimeRoundedRectangle(offset: .randomOffset(), width: 100, height: 100, corner: 50)
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
                            SlimeRoundedRectangle(offset: offset, width: 350, height: 350, corner: 175)
                                .tag(index)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onAppear {
                DispatchQueue.main.async {
                    self.vm.animate = true
                }
            }
    }
    
    @ViewBuilder
    private func SlimeRoundedRectangle(offset: CGSize, width: CGFloat, height: CGFloat, corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.white)
            .frame(width: width, height: height)
            .offset(x: vm.animate ? offset.width : offset.width, y: vm.animate ? offset.height : offset.height)
            .animation(.easeInOut(duration: 20), value: vm.animate)
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

#Preview {
    NoCardView(image: "BoyLeft")
}
