//
//  AddView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/13/23.
//

import CoreData
import SwiftUI

struct AddCardView: View {
    @ObservedObject var dataViewModel = DataViewModel.shared
    @FocusState var isFocused: Bool
    @State private var VocabBuilders = [String]()
    @State private var isEditing = false
    @State private var cardText = ""
    @State private var pickerSelected = ""
    @State private var showingAlert = false
    @State private var textFieldInput = ""
    @State private var showingFetchFailedAlert = false
    @State private var fetchFailedWords: [String] = []

    private let initialPlaceholder = "Write whatever wards you want to add. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemGroupedBackground).opacity(0.5))
                            .overlay(
                                TransparentBlurView(removeAllLayers: true)
                                .blur(radius: 9, opaque: true)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                        
                        HStack {
                            Picker("Options", selection: $pickerSelected) {
                                ForEach(dataViewModel.categories) { category in
                                    let name = category.name ?? ""
                                    Text(name).tag(name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                        }
                    }
                    .frame(height: 44)
                                        
                    Button(action: {
                        showingAlert = true
                    }) {
                        Text("Add Category")
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.leading, 10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)

                TextEditor(text: Binding(
                    get: { isEditing ? cardText : initialPlaceholder },
                    set: { cardText = $0 }
                ))
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .foregroundColor(isEditing ? .primary : .secondary)
                .onTapGesture {
                    isEditing = true
                }
                .onChange(of: cardText) { newValue in
                    cardText = newValue.lowercased()
                }
                .modifier(BlurBackground())
                
                Button(action: {
                    DataViewModel.shared.addCard(text: cardText) { [self] failedWords in
                        cardText = ""
                        
                        fetchFailedWords = failedWords
                        if !fetchFailedWords.isEmpty {
                            showingFetchFailedAlert = true
                        }
                    }
                    cardText = ""
                    isFocused = false
                }) {
                    Text("Add \(cardText.split(separator: "\n").count) Cards")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cardText == initialPlaceholder)
                .padding([.horizontal, .bottom])

            }
            .padding(.bottom)
            .onTapGesture {
                isFocused = false
            }
            .background(BackgroundView())
            .navigationBarTitle("Add Cards", displayMode: .large)
        }
        .onAppear {
            PersistenceController.shared.addDefaultCategory()
        }
        
        .alert("Add Category", isPresented: $showingAlert) {
            TextField("category name", text: $textFieldInput)
            Button("Add", role: .none) {
                DataViewModel.shared.addCategory(name: textFieldInput)
                pickerSelected = textFieldInput
                textFieldInput = ""
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enter the new category name.")
        }
        
        .alert("Failed to add cards", isPresented: $showingFetchFailedAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text("Failed to find these wards on the dictionary.\n\n\(fetchFailedWords.joined(separator: "\n"))")
        }
        
        .overlay(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }
        )
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
