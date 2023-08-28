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
    @StateObject private var viewModel = AddCardViewModel()
    @FocusState private var isFocused: Bool
    @Binding var showTabBar: Bool
        
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    if !isFocused {
                        categoryPicker
                    }
                    
                    textEditorView
                    generateButton
                }
                .padding(.bottom, 90)
                .gradientBackground()
                .navigationBarTitle("Add Cards", displayMode: .large)
                .navigationBarHidden(isFocused)
                .ignoresSafeArea(edges: .bottom)
                
                if isFocused {
                    doneButton
                }
                
                generatingCardsOverlay
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if let defaultCategory = viewModel.dataViewModel.categories.first?.name {
                viewModel.selectedCategory = defaultCategory
            }
        }
    }
    
    private var categoryPicker: some View {
        HStack(spacing: 0) {
            Picker("", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.dataViewModel.categories) { category in
                    let name = category.name ?? ""
                    Text(name).tag(name)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 26)
            .blurBackground()
            .accessibilityIdentifier("addCardViewCategoryPicker")
            
            addCategoryButton
        }
        .padding(.trailing)
    }
    
    private var addCategoryButton: some View {
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
    
    private var generatingCardsOverlay: some View {
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
                    Text("\(viewModel.fetchedWordCount) / \(viewModel.requestedWordCount) Completed")
                        .font(.footnote)
                        .padding(.bottom)
                    ProgressView(value: Float(viewModel.fetchedWordCount), total: Float(viewModel.requestedWordCount))
                }
                .frame(width: 210)
                .transition(.scale)
            }
        }
    }
    
    private var textEditorView: some View {
        TextEditor(text: Binding(
            get: { viewModel.displayText },
            set: { viewModel.cardText = $0 }
        ))
        .scrollContentBackground(.hidden)
        .focused($isFocused)
        .foregroundColor(viewModel.showPlaceholder ? .secondary : .primary)
        .onChange(of: viewModel.cardText) { newValue in
            viewModel.updateTextEditor(text: newValue, isFocused: isFocused)
        }
        .onChange(of: isFocused) { newValue in
            viewModel.togglePlaceHolder(isFocused)
        }
        .blurBackground()
        .accessibilityIdentifier("addCardViewTextEditor")
        
        .padding(.bottom, keyboardResponder.currentHeight == 0 ? 0 : keyboardResponder.currentHeight - 90)
    }
    
    private var generateButton: some View {
        Button(action: {
            viewModel.generateCards()
            isFocused = false
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
    
    private var doneButton: some View {
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
