//
//  SettingsRow.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/5/23.
//

import SwiftUI

struct FilterPicker: View {
    var description: String
    @Binding var value: Int
    var labelText: String
    var options: [Int]
    var id: String

    var body: some View {
        VStack {
            Divider()

            HStack {
                Text(description)
                Spacer()
                NumberPicker(value: $value, labelText: labelText, options: options, id: id)
            }
            .frame(height: 30)
        }
    }
}
