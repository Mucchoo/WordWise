//
//  StatusButton.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct StatusButton: View {
    var systemName: String
    var status: Int
    var title: String
    var colors: [Color]
    @Binding var filterStatus: [Int16]
    @State private var isOn = true

    var body: some View {
        Button(action: {
            isOn.toggle()
            
            if isOn {
                filterStatus.append(Int16(status))
            } else {
                filterStatus.removeAll(where: { $0 == status })
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: systemName)
                    .foregroundColor(isOn ? .white : .black)
                    .fontWeight(.black)
                Text(title)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(isOn ? .white : .black)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(isOn ? LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom))
        }
        .onAppear {
            isOn = filterStatus.contains(Int16(status))
            print("title: \(title) isOn: \(isOn)")
        }
    }
}

struct StatusButton_Previews: PreviewProvider {
    static var previews: some View {
        StatusButton(systemName: "checkmark.circle.fill", status: 0, title: "Learned", colors: [.black, .navy], filterStatus: .constant([0]))
    }
}
