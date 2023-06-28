//
//  NoCardView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct NoCardView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No Cards")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Image(systemName: "square.filled.on.square")
                .resizable()
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
            Text("You have no cards yet.\nGo to the 'Add' tab \nto create your first one!")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top)
            Spacer()
        }
    }
}

struct NoCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoCardView()
    }
}
