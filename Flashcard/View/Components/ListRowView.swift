//
//  FormRowView.swift
//  MuscleRecord
//
//  Created by Musa Yazuju on 2022/03/29.
//

import SwiftUI

struct ListRowView: View {
    var icon: String
    var firstText: String
    var showDevider = true

    var body: some View {
        HStack{
            Spacer().frame(width: 20)
            ZStack{
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill()
                Image(systemName: icon)
                    .foregroundColor(Color.white)
            }
            .frame(width: 40, height: 40, alignment: .center)
            Text(firstText)
                .foregroundColor(.black)
            Spacer()
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(icon: "square.and.arrow.up", firstText: "Share App")
            .previewLayout(.fixed(width: 375, height: 60))
            .padding()
    }
}
