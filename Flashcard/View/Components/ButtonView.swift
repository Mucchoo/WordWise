//
//  ButtonView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct ButtonView: View {
    @ObservedObject private var viewModel = ViewModel()
    var text: String

    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, alignment: .center)
            .foregroundColor(.white)
            .cornerRadius(20)
            .shadow(color: Color("FontColor").opacity(0.5), radius: 4, x: 0, y: 2)
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(text: "text")
    }
}
