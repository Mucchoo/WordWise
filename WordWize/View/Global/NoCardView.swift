//
//  NoCardView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct NoCardView: View {
    let image: String
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                ClubbedView()
                VStack {
                    Image(image)
                        .resizable()
                        .fontWeight(.bold)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 320, height: 230)
                        .foregroundColor(.white)
                    Text("You have no cards yet.\nGo '\(Image(systemName: "plus.square"))' to add your first one!")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    NoCardView(image: "BoyLeft")
}
