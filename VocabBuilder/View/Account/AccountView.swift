//
//  AccountView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/25.
//

import SwiftUI

struct AccountView: View {
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @ObservedObject private var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    @State private var isShowingAlert = false
    @State var isShowingReauthenticate = false
    @State var isShowingTutorial = false
    @State var isShowingMail = false
    @State var showingResetAlert = false
    @State private var initialAnimation = false
    @State private var mailData = Email(subject: "Feedback", recipients: ["yazujumusa@gmail.com"], message: "\n\n\n\n\nーーーーーーーーーーーーーーーーー\nPlease write your feedback above this line! Thank you!")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("\(Image(systemName: "apple.logo")) yazujumusa") + Text("@icloud.com")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background {
                        TransparentBlurView(removeAllLayers: true)
                            .blur(radius: 9, opaque: true)
                            .background(.white.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding()
                    
                    VStack {
                        VStack(spacing: 8) {
                            ChartBarView(status: 0, name: "Learned", image: "checkmark.circle.fill", color: .blue)
                            ChartBarView(status: 1, name: "Learning", image: "pencil.circle.fill", color: .red)
                            ChartBarView(status: 2, name: "New", image: "star.circle.fill", color: .yellow)
                        }
                    }
                    .padding()
                    .background {
                        TransparentBlurView(removeAllLayers: true)
                            .blur(radius: 9, opaque: true)
                            .background(.white.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding()
                    
                    VStack {
                        Button {
                            viewModel.shareApp()
                        } label: {
                            HStack {
                                Text("\(Image(systemName: "square.and.arrow.up")) Share App")
                                Spacer()
                            }
                        }
                        .padding([.horizontal, .top])

                        Divider()
                            .padding(.horizontal)
                        
                        Button {
                            isShowingMail = true
                        } label: {
                            HStack {
                                Text("\(Image(systemName: "envelope")) Feedback")
                                Spacer()
                            }
                        }
                        .padding([.horizontal, .bottom])
                        .sheet(isPresented: $isShowingMail) {
                            MailView(data: $mailData) { result in }
                        }
                    }
                    .background {
                        TransparentBlurView(removeAllLayers: true)
                            .blur(radius: 9, opaque: true)
                            .background(.white.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding()

                    HStack {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            Text("\(Image(systemName: "trash")) Reset Leaning Data")
                                .foregroundColor(.red)
                                .cornerRadius(10)
                        }
                        .alert("Are you sure to reset all the learning data?", isPresented: $showingResetAlert) {
                            Button("Reset", role: .destructive, action: CardManager.shared.resetLearningData)
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Failed times and the status of all cards will be reset.")
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background {
                        TransparentBlurView(removeAllLayers: true)
                            .blur(radius: 9, opaque: true)
                            .background(.white.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding()
                }
            }
            .background {
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                        .edgesIgnoringSafeArea(.all)
                    ClubbedView(initialAnimation: $initialAnimation)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .onAppear {
                initialAnimation = true
            }
            .navigationBarTitle("Account", displayMode: .large)
        }
    }
    
    @ViewBuilder
    func ClubbedView(initialAnimation: Binding<Bool>) -> some View {
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
                                let offset = CGSize(width: .random(in: -300...300), height: .random(in: -500...500))
                                ClubbedRoundedRectangle(offset: offset, initialAnimation: $initialAnimation.wrappedValue, width: 100, height: 100, corner: 50)
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
            .animation(.easeInOut(duration: 20), value: offset)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
