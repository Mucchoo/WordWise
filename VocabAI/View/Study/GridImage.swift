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
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .background {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 10)
                    }
                    .clipped()
            } else {
                Spacer()
                    .frame(width: size, height: size)
            }
        }
    }
}
