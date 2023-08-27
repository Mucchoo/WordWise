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
        
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    if !isFocused {
                        CategoryPickerView(viewModel: viewModel)
                    }
                    
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
                    .modifier(BlurBackground())
                    .accessibilityIdentifier("addCardViewTextEditor")
                    
                    .padding(.bottom, keyboardResponder.currentHeight == 0 ? 0 : keyboardResponder.currentHeight - 90) 
                    
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
                
                GeneratingCardsOverlay(viewModel: viewModel)
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

private struct CategoryPickerView: View {
    @ObservedObject var viewModel: AddCardViewModel
    
    var body: some View {
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
            
            AddCategoryButton(viewModel: viewModel)
        }
        .padding(.trailing)
    }
}

struct AddCategoryButton: View {
    @ObservedObject var viewModel: AddCardViewModel
    
    var body: some View {
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
}

private struct GeneratingCardsOverlay: View {
    @ObservedObject var viewModel: AddCardViewModel
    
    var body: some View {
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
