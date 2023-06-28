//
//  TextFieldView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct TextFieldView: View {
    @ObservedObject private var viewModel = ViewModel()
    var title: String
    var text: Binding<String>
    var placeHolder: String
    var isSecure: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("FontColor"))
                .padding(.leading, 8)
            Spacer()
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
        if isSecure {
            SecureField(placeHolder, text: text)
                .font(.headline)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .frame(height: 50, alignment: .center)
                .cornerRadius(8)
                .textInputAutocapitalization(.none)
                .submitLabel(.done)
        } else {
            TextField(placeHolder, text: text)
                .font(.headline)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .frame(height: 50, alignment: .center)
                .cornerRadius(8)
                .textInputAutocapitalization(.none)
                .submitLabel(.done)
        }
    }
}

struct TextFieldView_Previews: PreviewProvider {
    @State static var textFieldValue: String = ""

    static var previews: some View {
        TextFieldView(title: "Title", text: $textFieldValue, placeHolder: "Placeholder", isSecure: false)
    }
}
