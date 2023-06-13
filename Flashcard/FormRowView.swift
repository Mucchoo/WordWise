//
//  FormRowView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/29.
//

import SwiftUI

struct FormRowView: View {
    var icon: String
    var firstText: String
    var isHidden: Bool
    
    var body: some View {
        HStack{
            ZStack{
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill()
                Image(systemName: icon)
                    .foregroundColor(Color.white)
            }
            .frame(width: 36, height: 36, alignment: .center)
            Text(firstText)
            Spacer()
        }.opacity(isHidden ? 0.5 : 1)
    }
}
