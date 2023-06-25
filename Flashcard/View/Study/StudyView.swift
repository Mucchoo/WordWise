//
//  StudyView.swift
//  Flashcard
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
    @State private var maximumCardsToStudy = 10
    @State private var failedTimesMoreThan = 0
    @State private var isFirstAppearance = true
    @State private var filterStatus: [Int16]  = [0, 1, 2]
    @State private var cardsToStudy: [Card] = []
    
    let maximumCardOptions = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000]
    let failedTimeOptions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    
    private func updateCardsToStudy() {
        let filteredCards = cards.filter { card in
            let statusFilter = filterStatus.contains { $0 == card.status }
            let failedTimesFilter = card.failedTimes >= failedTimesMoreThan
            let categoryFilter = selectedCategories.contains { $0 == card.category }
            return statusFilter && failedTimesFilter && categoryFilter
        }
        cardsToStudy = Array(filteredCards.prefix(maximumCardsToStudy))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .frame(height: 120)
                        .overlay(
                            HStack {
                                InfoCard(systemName: "checkmark.circle.fill", count: cards.filter { $0.status == 0 }.count, title: "Learned", color: .blue)
                                
                                Divider().background(.gray)
                                    .frame(height: 80)
                                
                                InfoCard(systemName: "pencil.circle.fill", count: cards.filter { $0.status == 1 }.count, title: "Learning", color: .red)
                                
                                Divider().background(.gray)
                                    .frame(height: 80)
                                
                                InfoCard(systemName: "star.circle.fill", count: cards.filter { $0.status == 2 }.count, title: "New", color: .yellow)
                            }
                            .foregroundColor(.white)
                        )
                        .padding()
                    
                    VStack {
                        Divider()
                            .padding()
                        
                        HStack {
                            Spacer().frame(width: 20)
                            Text("Filter")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        HStack {
                            StatusFilterButton(status: 0, text: "Learned", filterStatus: $filterStatus)
                            StatusFilterButton(status: 1, text: "Learning", filterStatus: $filterStatus)
                            StatusFilterButton(status: 2, text: "New", filterStatus: $filterStatus)
                        }
                        .padding([.leading, .trailing, .bottom])
                        
                        Button {
                            showingCategorySheet.toggle()
                        } label: {
                            Text(selectedCategories.map { $0 }.joined(separator: ", "))
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
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
                        
                        HStack {
                            Text("Maximum Cards to Study")
                                .fontWeight(.bold)
                            Spacer()
                            NumberPicker(value: $maximumCardsToStudy, labelText: "cards", options: maximumCardOptions)
                        }
                        .padding([.leading, .trailing])
                        
                        HStack {
                            Text("Failed Times more than")
                                .fontWeight(.bold)
                            Spacer()
                            NumberPicker(value: $failedTimesMoreThan, labelText: "or more times", options: failedTimeOptions)
                        }
                        .padding([.leading, .trailing])
                    }
                    
                    Button(action: {
                        guard cardsToStudy.count > 0 else { return }
                        showingCardView = true
                    }) {
                        Text(cardsToStudy.count > 0 ? "Start Studying \(cardsToStudy.count) Cards" : "No Cards Available")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(cardsToStudy.count > 0 ? .blue : .gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(cardsToStudy.count == 0)
                    .padding()
                    .fullScreenCover(isPresented: $showingCardView) {
                        CardView(showingCardView: $showingCardView, cardsToStudy: cardsToStudy)
                    }

                    VStack {
                        Divider()
                            .padding()
                        
                        HStack {
                            Spacer().frame(width: 20)
                            Text("\(cards.count) Cards")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        VStack {
                            ForEach(cards) { card in
                                CardListRowView(card: card)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Study", displayMode: .large)
        }
        .onAppear {
            cards.forEach { card in
                guard card.category == nil else { return }
                card.category = cardCategories.first?.name
                PersistenceController.shared.saveContext()
            }
            
            guard isFirstAppearance else { return }
            selectedCategories = cardCategories.map { $0.name ?? "" }
            isFirstAppearance = false
        }
        .onChange(of: failedTimesMoreThan) { _ in
            updateCardsToStudy()
        }
        .onChange(of: selectedCategories) { _ in
            updateCardsToStudy()
        }
        .onChange(of: maximumCardsToStudy) { _ in
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

struct InfoCard: View {
    var systemName: String
    var count: Int
    var title: String
    var color: Color
    
    var body: some View {
        Spacer().frame(width: 10)
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .foregroundColor(color)
                .fontWeight(.black)
            Text("\(count)")
                .font(.title)
                .foregroundColor(.black)
            Text(title)
                .font(.footnote)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatusFilterButton: View {
    var status: Int16
    var text: String
    @Binding var filterStatus: [Int16]
    @State var isOn = true

    var body: some View {
        Button(action: {
            isOn.toggle()
            print("\(text) isOn :\(isOn)")
            
            if isOn {
                filterStatus.append(status)
            } else {
                filterStatus.removeAll(where: { $0 == status })
            }
        }) {
            Text(text)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(isOn ? .white : .blue)
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(isOn ? .blue : .clear))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 2))
        .buttonStyle(PlainButtonStyle())
    }
}

struct NumberPicker: View {
    @Binding var value: Int
    var labelText: String
    var options: [Int]
    
    var body: some View {
        Picker(
            selection: $value,
            label:
                HStack {
                    Text("Picker")
                        .fontWeight(.bold)
                }
            ,
            content: {
                ForEach(options, id: \.self) { i in
                    Text("\(i) \(labelText)").tag(i)
                }
            }
        )
        .labelsHidden()
        .cornerRadius(15)
        .pickerStyle(MenuPickerStyle())
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
