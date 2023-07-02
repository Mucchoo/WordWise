//
//  NoCardView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct NoCardView: View {
    let image: String
    @Binding var initialAnimation: Bool
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                ClubbedView(isNoCardView: true)
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
            .onAppear {
                initialAnimation = true
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct NoCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoCardView(image: "BoyLeft", initialAnimation: .constant(true))
    }
}
