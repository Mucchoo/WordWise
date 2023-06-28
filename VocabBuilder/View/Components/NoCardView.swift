//
//  NoCardView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct NoCardView: View {
    let image: String
    @State private var initialAnimation = false
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                ClubbedView(initialAnimation: $initialAnimation)
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
            .onAppear {
                initialAnimation = true
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    func ClubbedView(initialAnimation: Binding<Bool>) -> some View {
        Rectangle()
            .fill(.linearGradient(colors: [Color("purple"), Color("orange")], startPoint: .top, endPoint: .bottom))
            .mask {
                TimelineView(.animation(minimumInterval: 5, paused: false)) { _ in
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
                                let offset = CGSize(width: .random(in: -300...300), height: .random(in: -500...500))
                                ClubbedRoundedRectangle(offset: offset, initialAnimation: $initialAnimation.wrappedValue, width: 100, height: 200, corner: 50)
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
                                ClubbedRoundedRectangle(offset: offset, initialAnimation: $initialAnimation.wrappedValue, width: 350, height: 350, corner: 175)
                                    .tag(index)
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
            .animation(.easeInOut(duration: 5), value: offset)
    }
}

struct NoCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoCardView(image: "BoyLeft")
    }
}
