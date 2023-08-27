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
    @StateObject var viewModel = AddCardViewModel()
    @FocusState var isFocused: Bool
    @Binding var showTabBar: Bool
    
    private let initialPlaceholder = "pineapple\nstrawberry\ncherry\nblueberry\npeach"
    @State private var showPlaceholder = true
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    if !isFocused {
                        HStack(spacing: 0) {
                            Picker("", selection: $viewModel.selectedCategory) {
                                ForEach(viewModel.dataViewModel.categories) { category in
                                    let name = category.name ?? ""
                                    Text(name).tag(name)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 26)
                            .modifier(BlurBackground())
                            .accessibilityIdentifier("addCardViewCategoryPicker")
                            
                            Button(action: {
                                viewModel.showingAddCategoryAlert = true
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
                        get: { showPlaceholder ? initialPlaceholder : viewModel.cardText },
                        set: { viewModel.cardText = $0 }
                    ))
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .foregroundColor(showPlaceholder ? .secondary : .primary)
                    .onChange(of: viewModel.cardText) { newValue in
                        viewModel.cardText = newValue.lowercased()
                        if viewModel.cardText.isEmpty && !isFocused {
                            showPlaceholder = true
                        }
                    }
                    .onChange(of: isFocused) { newValue in
                        showPlaceholder = !newValue && (viewModel.cardText.isEmpty || viewModel.cardText == initialPlaceholder)
                    }
                    .modifier(BlurBackground())
                    .accessibilityIdentifier("addCardViewTextEditor")
                    .padding(.bottom, keyboardResponder.currentHeight == 0 ? 0 : keyboardResponder.currentHeight - 90)

                    Button(action: {
                        let cancellable = viewModel.addCardPublisher()
                        cancellable.store(in: &viewModel.dataViewModel.cancellables)

                        viewModel.cardText = ""
                        isFocused = false
                        viewModel.generatingCards = true
                        showTabBar = false
                    }) {
                        Text("Add \(viewModel.cardText.split(separator: "\n").count) Cards")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .bold()
                            .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .accessibilityIdentifier("addCardsButton")
                    .disabled(viewModel.shouldDisableAddCardButton())
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
                    if viewModel.generatingCards {
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
                            Text("\(viewModel.dataViewModel.fetchedWordCount) / \(viewModel.dataViewModel.requestedWordCount) Completed")
                                .font(.footnote)
                                .padding(.bottom)
                            ProgressView(value: Float(viewModel.dataViewModel.fetchedWordCount), total: Float(viewModel.dataViewModel.requestedWordCount))
                        }
                        .frame(width: 210)
                        .transition(.scale)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if let defaultCategory = viewModel.dataViewModel.categories.first?.name {
                viewModel.selectedCategory = defaultCategory
            }
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
