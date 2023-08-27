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
    @StateObject private var keyboardResponder = KeyboardResponder()
    @EnvironmentObject private var dataViewModel: DataViewModel
    @FocusState var isFocused: Bool
    @Binding var showTabBar: Bool
    
    @State private var generatingCards = false
    @State private var showPlaceholder = true
    @State private var cardText = ""
    @State private var selectedCategory = ""
    @State private var showingAddCategoryAlert = false
    @State private var textFieldInput = ""
    @State private var showingFetchFailedAlert = false
    @State private var showingFetchSucceededAlert = false

    private let initialPlaceholder = "pineapple\nstrawberry\ncherry\nblueberry\npeach"
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    if !isFocused {
                        HStack(spacing: 0) {
                            Picker("", selection: $selectedCategory) {
                                ForEach(dataViewModel.categories) { category in
                                    let name = category.name ?? ""
                                    Text(name).tag(name)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 26)
                            .modifier(BlurBackground())
                            .accessibilityIdentifier("addCardViewCategoryPicker")
                            
                            Button(action: {
                                showingAddCategoryAlert = true
                            }) {
                                Text("Add Category")
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                    .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .accessibilityIdentifier("addCategoryButton")
                        }
                        .padding(.trailing)
                    }

                    TextEditor(text: Binding(
                        get: { showPlaceholder ? initialPlaceholder : cardText },
                        set: { cardText = $0 }
                    ))
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .foregroundColor(showPlaceholder ? .secondary : .primary)
                    .onChange(of: cardText) { newValue in
                        cardText = newValue.lowercased()
                        if cardText.isEmpty && !isFocused {
                            showPlaceholder = true
                        }
                    }
                    .onChange(of: isFocused) { newValue in
                        showPlaceholder = !newValue && (cardText.isEmpty || cardText == initialPlaceholder)
                    }
                    .modifier(BlurBackground())
                    .accessibilityIdentifier("addCardViewTextEditor")
                    .padding(.bottom, keyboardResponder.currentHeight == 0 ? 0 : keyboardResponder.currentHeight - 90)
                    
                    Button(action: {
                        dataViewModel.addCardPublisher(text: cardText, category: selectedCategory)
                            .sink { [self] in
                                print("add card completion")
                                generatingCards = false
                                showTabBar = true
                                
                                if dataViewModel.fetchFailedWords.isEmpty {
                                    showingFetchSucceededAlert = true
                                } else {
                                    showingFetchFailedAlert = true
                                }
                            }
                            .store(in: &dataViewModel.cancellables)
                        
                        cardText = ""
                        isFocused = false
                        generatingCards = true
                        showTabBar = false
                    }) {
                        Text("Add \(cardText.split(separator: "\n").count) Cards")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .bold()
                            .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .accessibilityIdentifier("addCardsButton")
                    .disabled(cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cardText == initialPlaceholder)
                    .padding([.horizontal, .bottom])
                }
                .padding(.bottom, 90)
                .background(BackgroundView())
                .navigationBarTitle("Add Cards", displayMode: .large)
                .navigationBarHidden(isFocused)
                .ignoresSafeArea(edges: .bottom)
                
                if isFocused {
                    VStack {
                        Spacer()
                        Button(action: {
                            isFocused = false
                        }) {
                            Text("Done")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .bold()
                                .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
                
                ZStack {
                    if generatingCards {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.thickMaterial)
                            .frame(width: 250, height: 100)
                            .transition(.scale)
                        VStack {
                            Text("Generating Cards...")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("\(dataViewModel.fetchedWordCount) / \(dataViewModel.requestedWordCount) Completed")
                                .font(.footnote)
                                .padding(.bottom)
                            ProgressView(value: Float(dataViewModel.fetchedWordCount), total: Float(dataViewModel.requestedWordCount))
                        }
                        .frame(width: 210)
                        .transition(.scale)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if let defaultCategory = dataViewModel.categories.first?.name {
                selectedCategory = defaultCategory
            }
        }
        
        .alert("Add Category", isPresented: $showingAddCategoryAlert) {
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

#Preview {
    AddCardView(showTabBar: .constant(true))
        .injectMockDataViewModelForPreview()
}

private class KeyboardResponder: ObservableObject {
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
