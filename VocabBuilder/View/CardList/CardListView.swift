//
//  CardListView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct CardListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<CardCategory>
    @FocusState var isFocused: Bool
    
    @State private var VocabBuilders = [String]()
    @State private var isEditing = false
    @State private var cardText = ""
    @State private var isLoading = false
    @State private var progress: Float = 0.0
    @State private var pickerSelected = ""
    @State private var showingAlert = false
    @State private var textFieldInput = ""
    @State private var showingFetchFailedAlert = false
    @State private var fetchFailedWords: [String] = []
    @State private var navigateToCardDetail: Bool = false
    @State private var failedTimes = 0
    @State private var selectedCardId: UUID?
    @State private var selectedStatus: Int16 = 0
    @State private var selectedCategory = ""
    @State private var selectedFailedTimes = 0
    @Binding var initialAnimation: Bool

    let failedTimeOptions = CardManager.shared.failedTimeOptions
    private let initialPlaceholder = "You can add cards using dictionary data. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
    @ObservedObject var fetcher = WordFetcher()
    
    var body: some View {
        NavigationView {
            if cards.isEmpty {
                NoCardView(image: "BoyRight")
            } else {
                VStack {
                    ScrollView {
                        VStack {
                            VStack(spacing: 4) {
                                HStack {
                                    Text("Category")
                                    Spacer()
                                    Picker("Category", selection: $pickerSelected) {
                                        ForEach(categories) { category in
                                            let name = category.name ?? ""
                                            Text(name).tag(name)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Failed Times")
                                    Spacer()
                                    NumberPicker(value: $failedTimes, labelText: "or more times", options: failedTimeOptions)
                                }
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
                            
                            VStack {
                                ForEach(cards.indices) { index in
                                    VStack {
                                        Button(action: {
                                            selectedCardId = cards[index].id
                                            cardText = cards[index].text ?? ""
                                            selectedStatus = cards[index].status
                                            selectedCategory = cards[index].category ?? ""
                                            selectedFailedTimes = Int(cards[index].failedTimes)
                                            navigateToCardDetail = true
                                        }) {
                                            HStack{
                                                Image(systemName: cards[index].status == 0 ? "checkmark.circle.fill" : cards[index].status == 1 ? "pencil.circle.fill" : "star.circle.fill")
                                                    .foregroundColor(cards[index].status == 0 ? .blue : cards[index].status == 1 ? .red : .yellow)
                                                    .font(.system(size: 16))
                                                    .fontWeight(.black)
                                                    .frame(width: 20, height: 20, alignment: .center)
                                                
                                                Text(cards[index].text ?? "Unknown")
                                                    .foregroundColor(Color(UIColor(.primary)))
                                                Spacer()
                                            }
                                        }
                                        if index < cards.count - 1 {
                                            Divider()
                                        }
                                    }
                                    .sheet(isPresented: $navigateToCardDetail) {
                                        List {
                                            HStack {
                                                Text("Name")
                                                Spacer()
                                                Text("\(cards.first { $0.id == selectedCardId }?.text ?? "")")
                                            }
                                            Picker("Category", selection: $selectedCategory) {
                                                ForEach(categories) { category in
                                                    let name = category.name ?? ""
                                                    Text(name).tag(name)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            
                                            Picker("Status", selection: $selectedStatus) {
                                                ForEach(CardManager.shared.statusArray, id: \.self) { status in
                                                    Text("\(status.text)").tag(status.value)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            
                                            HStack {
                                                Text("Failed Times")
                                                Spacer()
                                                NumberPicker(value: $selectedFailedTimes, labelText: "times", options: failedTimeOptions)
                                            }
                                        }
                                        .presentationDetents([.medium])
                                    }
                                    .onChange(of: navigateToCardDetail) { newValue in
                                        if !newValue, let selectedCardId = selectedCardId {
                                            CardManager.shared.updateCard(id: selectedCardId, text: cardText, category: selectedCategory, status: selectedStatus, failedTimesIndex: Int(selectedFailedTimes))
                                        }
                                    }
                                }
                                .onDelete(perform: CardManager.shared.deleteCard)
                            }
                            .padding()
                            .background {
                                TransparentBlurView(removeAllLayers: true)
                                    .blur(radius: 9, opaque: true)
                                    .background(.white.opacity(0.5))
                            }
                            .cornerRadius(10)
                            .clipped()
                            .padding()
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
                .navigationBarTitle("Cards", displayMode: .large)
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

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView(initialAnimation: .constant(true))
    }
}
