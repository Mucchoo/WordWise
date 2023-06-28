//
//  FormView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/21/23.
//

import SwiftUI

struct FormView: View {
    @State private var switchIsOn = false
    @State private var sliderValue = 0.5
    @State private var pickerSelected = 1
    @State private var stepperValue = 1
    @State private var date = Date()
    @State private var textFieldInput = ""
    @State private var secureFieldInput = ""
    @State private var textAreaInput = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Toggle Switch")) {
                    Toggle("Switch", isOn: $switchIsOn)
                }

                Section(header: Text("Slider")) {
                    Slider(value: $sliderValue, in: 0...1)
                }

                Section(header: Text("Picker")) {
                    Picker("Options", selection: $pickerSelected) {
                        Text("Option 1").tag(1)
                        Text("Option 2").tag(2)
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Stepper")) {
                    Stepper(value: $stepperValue, in: 1...10) {
                        Text("\(stepperValue) items")
                    }
                }

                Section(header: Text("Date Picker")) {
                    DatePicker("Select a date", selection: $date, displayedComponents: .date)
                }

                Section(header: Text("Text Field")) {
                    TextField("Placeholder", text: $textFieldInput)
                }

                Section(header: Text("Secure Field")) {
                    SecureField("Placeholder", text: $secureFieldInput)
                }

                Section(header: Text("Text Area")) {
                    TextEditor(text: $textAreaInput)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Form Components")
        }
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}
