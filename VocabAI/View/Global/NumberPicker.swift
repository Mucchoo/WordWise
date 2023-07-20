//
//  NumberPicker.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct NumberPicker: View {
    @Binding var value: Int
    var labelText: String
    var options: [Int]
    
    var body: some View {
        Picker(
            selection: $value,
            label:
                HStack {
                    Text("Picker")
                        .fontWeight(.bold)
                }
            ,
            content: {
                ForEach(options, id: \.self) { i in
                    Text("\(i) \(labelText)").tag(i)
                }
            }
        )
        .labelsHidden()
        .cornerRadius(15)
        .pickerStyle(MenuPickerStyle())
    }
}
