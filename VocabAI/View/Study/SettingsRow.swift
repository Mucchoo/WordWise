//
//  SettingsRow.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/5/23.
//

import SwiftUI

struct SettingsRow: View {
    var description: String
    @Binding var value: Int
    var labelText: String
    var options: [Int]

    var body: some View {
        VStack {
            Divider()

            HStack {
                Text(description)
                Spacer()
                NumberPicker(value: $value, labelText: labelText, options: options)
            }
            .frame(height: 30)
        }
    }
}

struct SettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRow(description: "", value: .constant(0), labelText: "", options: [])
    }
}
