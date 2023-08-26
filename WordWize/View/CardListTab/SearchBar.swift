//
//  SearchBar.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/14/23.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search...", text: $text)
                .onChange(of: text) { newValue in
                    text = newValue.lowercased()
                }
                .padding(7)
                .modifier(BlurBackground())
                .cornerRadius(8)
        }
        .padding(.top, 10)
    }
}

#Preview {
    SearchBar(text: .constant("text"))
}
