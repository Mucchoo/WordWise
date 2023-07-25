//
//  AddCardView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import CoreData
import Combine
import SwiftUI

struct AddCardView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @FocusState var isFocused: Bool
    @State private var WordWizes = [String]()
    @State private var showPlaceholder = true
    @State private var cardText = ""
    @State private var selectedCategory = ""
    @State private var showingAlert = false
    @State private var textFieldInput = ""
    @State private var showingFetchFailedAlert = false
    @State private var showingFetchSucceededAlert = false
    @State private var cancellables = Set<AnyCancellable>()
    @StateObject private var keyboardResponder = KeyboardResponder()

    private let initialPlaceholder = "pineapple\nstrawberry\ncherry\nblueberry\npeach"
    
    var body: some View {
        NavigationView {
            VStack {
                
                if !isFocused {
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
                                Picker("Options", selection: $selectedCategory) {
                                    ForEach(dataViewModel.categories) { category in
                                        let name = category.name ?? ""
                                        Text(name).tag(name)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accessibilityIdentifier("addCardViewCategoryPicker")
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
                        .accessibilityIdentifier("addCategoryButton")
                    }
                    .padding(.horizontal)
                }

                TextEditor(text: Binding(
                    get: { showPlaceholder ? initialPlaceholder : cardText },
                    set: { cardText = $0 }
                ))
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(action: {
                            isFocused = false
                        }) {
                            Text("Done").bold()
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .foregroundColor(showPlaceholder ? .secondary : .primary)
                .onChange(of: cardText) { newValue in
                    cardText = newValue.lowercased()
                    if cardText.isEmpty && !isFocused {
                        print("show placeholder 1")
                        showPlaceholder = true
                    }
                }
                .onChange(of: isFocused) { newValue in
                    print("show placeholder: \(!newValue && (cardText.isEmpty || cardText == initialPlaceholder))")
                    showPlaceholder = !newValue && (cardText.isEmpty || cardText == initialPlaceholder)
                }
                .modifier(BlurBackground())
                .padding(.bottom, keyboardResponder.currentHeight == 0 ? 0 : keyboardResponder.currentHeight - 160)
                .accessibilityIdentifier("addCardViewTextEditor")
                
                Button(action: {
                    dataViewModel.addCardPublisher(text: cardText, category: selectedCategory)
                        .sink { [self] in
                            print("add card completion")
                            if dataViewModel.fetchFailedWords.isEmpty {
                                showingFetchSucceededAlert = true
                            } else {
                                showingFetchFailedAlert = true
                            }
                        }
                        .store(in: &cancellables)
                    
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
                .accessibilityIdentifier("addCardsButton")
                .disabled(cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cardText == initialPlaceholder)
                .padding([.horizontal, .bottom])

            }
            .padding(.bottom, 90)
            .onTapGesture {
                isFocused = false
            }
            .background(BackgroundView())
            .navigationBarTitle("Add Cards", displayMode: .large)
            .navigationBarHidden(isFocused)
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if let defaultCategory = dataViewModel.categories.first?.name {
                selectedCategory = defaultCategory
            }
        }
        
        .alert("Add Category", isPresented: $showingAlert) {
            TextField("category name", text: $textFieldInput)
            Button("Add", role: .none) {
                dataViewModel.addCategory(name: textFieldInput)
                selectedCategory = textFieldInput
                textFieldInput = ""
            }
            .disabled(textFieldInput.isEmpty)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enter the new category name.")
        }
        
        .alert("Failed to add cards", isPresented: $showingFetchFailedAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text("Failed to find these wards on the dictionary.\n\n\(dataViewModel.fetchFailedWords.joined(separator: "\n"))")
        }
        
        .alert("Added Cards", isPresented: $showingFetchSucceededAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text("Added \(dataViewModel.addedCardCount) cards successfully.")
        }
    }
}

final class KeyboardResponder: ObservableObject {
    @Published private(set) var currentHeight: CGFloat = 0

    private var cancellable: AnyCancellable?

    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }

        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .assign(to: \.currentHeight, on: self)
    }
}

private extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
