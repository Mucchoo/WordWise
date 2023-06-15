//
//  CardListRowView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct CardListRowView: View {
    var card: Card
    
    var body: some View {
        HStack{
            Spacer().frame(width: 20)
            ZStack{
                
                
                switch card.status {
                case .learned:
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill()
                        .foregroundColor(.blue)
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.white)
                        .font(.system(size: 10))
                        .fontWeight(.black)
                        .frame(width: 14, height: 14)
                case .learning:
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill()
                        .foregroundColor(.red)
                    Image(systemName: "pencil")
                        .foregroundColor(Color.white)
                        .font(.system(size: 10))
                        .fontWeight(.black)
                        .frame(width: 14, height: 14)
                case .new:
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill()
                        .foregroundColor(.yellow)
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.white)
                        .font(.system(size: 10))
                        .fontWeight(.black)
                }
            }
            .frame(width: 20, height: 20, alignment: .center)
            Text(card.text)
                .foregroundColor(.black)
            Spacer()
        }
    }
}

struct WordListRowView_Previews: PreviewProvider {
    static var previews: some View {
        CardListRowView(card: Card(text: "text", status: .new))
    }
}
