//
//  CardListRowView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import CoreData
import SwiftUI

struct CardListRowView: View {
    @ObservedObject var card: Card
    
    var body: some View {
        HStack{
            Spacer().frame(width: 20)
            ZStack{
                switch card.status {
                case 0:  // Learned
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill()
                        .foregroundColor(.blue)
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.white)
                        .font(.system(size: 10))
                        .fontWeight(.black)
                        .frame(width: 14, height: 14)
                case 1: // Learning
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill()
                        .foregroundColor(.red)
                    Image(systemName: "pencil")
                        .foregroundColor(Color.white)
                        .font(.system(size: 10))
                        .fontWeight(.black)
                        .frame(width: 14, height: 14)
                case 2: // New
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill()
                        .foregroundColor(.yellow)
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.white)
                        .font(.system(size: 10))
                        .fontWeight(.black)
                default:
                    EmptyView()
                }
            }
            .frame(width: 20, height: 20, alignment: .center)
            Text(card.text ?? "Unknown")
                .foregroundColor(.black)
            Spacer()
        }
    }
}

struct WordListRowView_Previews: PreviewProvider {
    static var previews: some View {
        let card = Card(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        card.text = "Apple"
        card.status = 0
        return CardListRowView(card: card)
    }
}
