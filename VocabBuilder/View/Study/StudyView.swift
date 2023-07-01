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
    
    let maximumCardOptions = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000]
    let failedTimeOptions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    
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
                            StatusButton(systemName: "checkmark.circle.fill", status: 0, title: "Learned", color: .blue, filterStatus: $filterStatus, cards: cards)
                            StatusButton(systemName: "pencil.circle.fill", status: 1, title: "Learning", color: .red, filterStatus: $filterStatus, cards: cards)
                            StatusButton(systemName: "star.circle.fill", status: 2, title: "New", color: .yellow, filterStatus: $filterStatus, cards: cards)
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
                                NumberPicker(value: $maximumCards, labelText: "cards", options: maximumCardOptions)
                            }
                            .frame(height: 30)
                            
                            Divider()

                            HStack {
                                Text("Failed Times")
                                Spacer()
                                NumberPicker(value: $failedTimes, labelText: "or more times", options: failedTimeOptions)
                            }
                            .frame(height: 30)
                        }
                        .padding()
                        .background(.white)
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
                .navigationBarTitle("Study", displayMode: .large)
                .background(Color(UIColor.systemGroupedBackground))
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
}

struct StatusButton: View {
    var systemName: String
    var status: Int
    var title: String
    var color: Color
    @Binding var filterStatus: [Int16]
    @State private var isOn = true
    var cards: FetchedResults<Card>

    var body: some View {
        Button(action: {
            isOn.toggle()
            
            if isOn {
                filterStatus.append(Int16(status))
            } else {
                filterStatus.removeAll(where: { $0 == status })
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: systemName)
                    .foregroundColor(isOn ? .white : color)
                    .fontWeight(.black)
                Text("\(cards.filter { $0.status == status }.count)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(isOn ? .white : .primary)
                Text(title)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(isOn ? .white : .primary)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(isOn ? color : .white)
        }
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

//struct StudyView_Previews: PreviewProvider {
//    static var previews: some View {
//        StudyView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
