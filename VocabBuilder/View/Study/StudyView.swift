//
//  StudyView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct StudyView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @FetchRequest(sortDescriptors: []) var cardCategories: FetchedResults<CardCategory>
    @State private var showingCardView = false
    @State private var learnedButton = true
    @State private var learningButton = true
    @State private var newButton = true
    @State private var showingCategorySheet = false
    @State private var selectedCategories: [String] = []
    @State private var maximumCards = 10
    @State private var failedTimes = 0
    @State private var isFirstAppearance = true
    @State private var filterStatus: [Int16]  = [0, 1, 2]
    @State private var cardsToStudy: [Card] = []
    @State private var initialAnimation = false
    
    private func updateCardsToStudy() {
        let filteredCards = cards.filter { card in
            let statusFilter = filterStatus.contains { $0 == card.status }
            let failedTimesFilter = card.failedTimes >= failedTimes
            let categoryFilter = selectedCategories.contains { $0 == card.category }
            return statusFilter && failedTimesFilter && categoryFilter
        }
        cardsToStudy = Array(filteredCards.prefix(maximumCards))
    }
    
    var body: some View {
        if cards.isEmpty {
            NoCardView(image: "BoyLeft")
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        HStack(spacing: 0) {
                            StatusButton(systemName: "checkmark.circle.fill", status: 0, title: "Learned", colors: [.black, Color("Navy")], filterStatus: $filterStatus)
                            StatusButton(systemName: "flame.circle.fill", status: 1, title: "Learning", colors: [Color("Navy"), Color("Blue")], filterStatus: $filterStatus)
                            StatusButton(systemName: "star.circle.fill", status: 2, title: "New", colors: [Color("Blue"), Color("Teal")], filterStatus: $filterStatus)
                        }
                        .cornerRadius(20)
                        .clipped()
                        .padding()
                        
                        VStack {
                            HStack {
                                Text("Category")
                                Spacer()
                                
                                Button {
                                    showingCategorySheet.toggle()
                                } label: {
                                    Text(selectedCategories.map { $0 }.joined(separator: ", "))
                                }
                                .padding([.leading, .trailing])
                                .sheet(isPresented: $showingCategorySheet) {
                                    List(cardCategories, id: \.self) { category in
                                        HStack {
                                            Text(category.name ?? "Unknown")
                                            Spacer()
                                            if selectedCategories.contains(category.name ?? "") {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            guard let categoryName = category.name else { return }
                                            if selectedCategories.contains(categoryName) {
                                                guard selectedCategories.count != 1 else { return }
                                                selectedCategories.removeAll { $0 == category.name }
                                            } else {
                                                selectedCategories.append(categoryName)
                                            }
                                        }
                                    }
                                    .environment(\.editMode, .constant(EditMode.active))
                                    .presentationDetents([.medium, .large])
                                }
                                
                            }
                            .frame(height: 30)
                            
                            Divider()
                            
                            HStack {
                                Text("Maximum Cards")
                                Spacer()
                                NumberPicker(value: $maximumCards, labelText: "cards", options: CardManager.shared.maximumCardOptions)
                            }
                            .frame(height: 30)
                            
                            Divider()

                            HStack {
                                Text("Failed Times")
                                Spacer()
                                NumberPicker(value: $failedTimes, labelText: "or more times", options: CardManager.shared.failedTimeOptions)
                            }
                            .frame(height: 30)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background {
                            TransparentBlurView(removeAllLayers: true)
                                .blur(radius: 9, opaque: true)
                                .background(.white.opacity(0.5))
                        }
                        .cornerRadius(10)
                        .clipped()
                        .padding()
                        
                        Button(action: {
                            guard cardsToStudy.count > 0 else { return }
                            showingCardView = true
                        }) {
                            Text(cardsToStudy.count > 0 ? "Study \(cardsToStudy.count) Cards" : "No Cards Available")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(cardsToStudy.count > 0 ? LinearGradient(colors: [Color("Navy"), Color("Blue")], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(cardsToStudy.count == 0)
                        .padding()
                        .fullScreenCover(isPresented: $showingCardView) {
                            CardView(showingCardView: $showingCardView, cardsToStudy: cardsToStudy)
                        }
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
                .navigationBarTitle("Study", displayMode: .large)
            }
            .onAppear {
                initialAnimation = true
                
                cards.forEach { card in
                    guard card.category == nil else { return }
                    card.category = cardCategories.first?.name
                    PersistenceController.shared.saveContext()
                }
                
                guard isFirstAppearance else { return }
                selectedCategories = cardCategories.map { $0.name ?? "" }
                isFirstAppearance = false
            }
            .onChange(of: failedTimes) { _ in
                updateCardsToStudy()
            }
            .onChange(of: selectedCategories) { _ in
                updateCardsToStudy()
            }
            .onChange(of: maximumCards) { _ in
                updateCardsToStudy()
            }
            .onChange(of: filterStatus) { _ in
                updateCardsToStudy()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: viewContext)) { _ in
                updateCardsToStudy()
                
                if selectedCategories.isEmpty {
                    selectedCategories = Array(cardCategories).map { $0.name ?? "" }
                }
            }
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
