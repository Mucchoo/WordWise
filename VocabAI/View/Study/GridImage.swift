//
//  GridImage.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/16/23.
//

import SwiftUI
import Kingfisher

struct GridImage: View {
    let card: Card
    let index: Int
    let size: CGFloat

    var body: some View {
        Group {
            if let urlString = card.imageUrlsArray[safe: index]?.urlString,
               let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipped()
            } else {
                Spacer()
                    .frame(width: size, height: size)
            }
        }
    }
}
