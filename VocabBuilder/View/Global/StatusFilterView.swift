//
//  StatusFilterView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct StatusFilterView: View {
    @Binding var filterStatus: [Int16]
    
    var body: some View {
        HStack(spacing: 0) {
            StatusButton(systemName: "checkmark.circle.fill", status: 0, title: "Learned", colors: [.black, .navy], filterStatus: $filterStatus)
            StatusButton(systemName: "flame.circle.fill", status: 1, title: "Learning", colors: [.navy, .ocean], filterStatus: $filterStatus)
            StatusButton(systemName: "star.circle.fill", status: 2, title: "New", colors: [.ocean, .teal], filterStatus: $filterStatus)
        }
        .cornerRadius(20)
        .clipped()
        .padding()
    }
}

struct StatusFilterView_Previews: PreviewProvider {
    static var previews: some View {
        StatusFilterView(filterStatus: .constant([]))
    }
}
