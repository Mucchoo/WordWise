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
    @State private var showingCardView = false
    
    let maximumCardsToStudy = 10
    let failedTimesMoreThan = 0
    
    var cardsToStudy: [Card] {
//        let failedCards = cards.filter { $0.failedTimes > failedTimesMoreThan }
//        return Array(failedCards.prefix(maximumCardsToStudy))
        return Array(cards)
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
                                
                                Divider().background(Color.gray)
                                    .frame(height: 80)
                                
                                InfoCard(systemName: "pencil.circle.fill", count: cards.filter { $0.status == 1 }.count, title: "Learning", color: .red)
                                
                                Divider().background(Color.gray)
                                    .frame(height: 80)
                                
                                InfoCard(systemName: "star.circle.fill", count: cards.filter { $0.status == 2 }.count, title: "New", color: .yellow)
                            }
                            .foregroundColor(.white)
                        )
                        .padding()
                    
                    FilterSection()
                    
                    Button(action: {
                        showingCardView = true
                    }) {
                        Text("Start Studying \(cardsToStudy.count) Cards")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .fullScreenCover(isPresented: $showingCardView) {
                        CardView(showingCardView: $showingCardView, cardsToLearn: cards)
                    }

                    CardsSection(totalCards: cards.count)
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Study", displayMode: .large)
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

struct FilterSection: View {
    @State private var learnedButton = false
    @State private var learningButton = false
    @State private var newButton = false
    let maximumCardOptions = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000]
    let failedTimeOptions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]

    var body: some View {
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
            FilterButton(text: "Learned", isOn: $learnedButton)
            FilterButton(text: "Learning", isOn: $learningButton)
            FilterButton(text: "New", isOn: $newButton)
        }
        .padding([.leading, .trailing, .bottom])

        HStack {
            Text("Maximum Cards to Study")
                .fontWeight(.bold)
            Spacer()
            NumberPicker(labelText: "cards", options: maximumCardOptions)
        }
        .padding([.leading, .trailing])
        HStack {
            Text("Failed Times more than")
                .fontWeight(.bold)
            Spacer()
            NumberPicker(labelText: "or more times", options: failedTimeOptions)
        }
        .padding([.leading, .trailing])
    }
}

struct FilterButton: View {
    var text: String
    @Binding var isOn: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                isOn.toggle()
            }
        }) {
            Text(text)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(isOn ? .white : .blue)
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(isOn ? Color.blue : Color.clear))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
        .buttonStyle(PlainButtonStyle())
    }
}

struct NumberPicker: View {
    @State var number: Int = 0
    var labelText: String
    var options: [Int]
    
    var body: some View {
        Picker(
            selection: $number,
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

struct CardsSection: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    var totalCards: Int
    
    var body: some View {
        Divider()
            .padding()
        
        HStack {
            Spacer().frame(width: 20)
            Text("\(totalCards) Cards")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }
        
        VStack(spacing: 8) {
            ForEach(cards) { card in
                CardListRowView(card: card)
            }
        }
    }
}


struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
