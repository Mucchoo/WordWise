//
//  SimpleNavigationView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import SwiftUI

struct SimpleNavigationView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let content: Content
    var title: String
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        content
        .navigationTitle(title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "arrow.backward")
                    }
                ).tint(.white)
            }
        }
    }
}
struct SimpleNavigationView_Previews: PreviewProvider {
    @State static var title: String = ""

    static var previews: some View {
        SimpleNavigationView(title: title) {
            Text("text")
        }
    }
}
