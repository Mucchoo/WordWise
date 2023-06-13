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
    var showDevider = true

    var body: some View {
        VStack {
            HStack{
                Spacer().frame(width: 20)
                ZStack{
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill()
                    Image(systemName: icon)
                        .foregroundColor(Color.white)
                }
                .frame(width: 40, height: 40, alignment: .center)
                Text(firstText)
                Spacer()
            }
            
            if showDevider {
                Divider()
            }
        }
    }
}

struct FormRowView_Previews: PreviewProvider {
    static var previews: some View {
        FormRowView(icon: "square.and.arrow.up", firstText: "Share App")
            .previewLayout(.fixed(width: 375, height: 60))
            .padding()
    }
}
