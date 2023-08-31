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
    @StateObject private var viewModel: AddCardViewModel
    @FocusState private var isFocused: Bool
    
    init(viewModel: AddCardViewModel) {
        print("AddCardView init")
        _viewModel = StateObject(wrappedValue: viewModel)
    }
        
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    categoryPicker
                    textEditorView(baseHeight: geometry.size.height)
                    Spacer()
                    generateButton
                }
                .padding(.bottom, 90)
                .gradientBackground()
                .navigationBarTitle("Add Cards", displayMode: .large)
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.setDefaultCategory()
        }
    }
    
    private var categoryPicker: some View {
        HStack(spacing: 0) {
            Picker("", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.container.appState.categories, id: \.self) { category in
                    let name = category.name ?? ""
                    Text(name).tag(name)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 26)
            .blurBackground()
            .accessibilityIdentifier("addCardViewCategoryPicker")
            .opacity(isFocused ? 0 : 1)
            
            addCategoryButton
        }
        .padding(.trailing)
        .animation(.default, value: isFocused)
        .frame(height: 80)
    }
    
    private var addCategoryButton: some View {
        Button(action: {
            if isFocused {
                withAnimation {
                    isFocused = false
                }
            } else {
                viewModel.showingAddCategoryAlert = true
            }
        }) {
            Text(isFocused ? "Done" : "Add Category")
                .bold()
                .padding(.vertical, 12)
                .padding(.horizontal)
                .frame(width: 150)
                .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .accessibilityIdentifier("addCategoryButton")
        .alert("Add Category", isPresented: $viewModel.showingAddCategoryAlert) {
            TextField("category name", text: $viewModel.textFieldInput)
            Button("Add", role: .none) {
                viewModel.addCategory()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enter the new category name.")
        }
    }
    
    private func textEditorView(baseHeight: CGFloat) -> some View {
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
        .frame(height: baseHeight - (isFocused ? 80 : 180))
    }
    
    private var generateButton: some View {
        Button(action: {
            viewModel.generateCards()
            
            withAnimation {
                isFocused = false
            }
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
        .alert("Failed to add cards", isPresented: $viewModel.showingFetchFailedAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text("Failed to find these wards on the dictionary.\n\n\(viewModel.fetchFailedWords.joined(separator: "\n"))")
        }
        
        .alert("Added Cards", isPresented: $viewModel.showingFetchSucceededAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text("Added \(viewModel.addedCardCount) cards successfully.")
        }
        .background(ProgressAlert(viewModel: viewModel, isPresented: $viewModel.generatingCards))
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
            .sink { newHeight in
                withAnimation {
                    self.currentHeight = newHeight
                }
            }
    }
}

private extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

private struct ProgressAlertContent: View {
    @StateObject var viewModel: AddCardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Generating Cards...")
                .font(.headline)
                .bold()
                .padding(.bottom)
            Text("\(viewModel.fetchedWordCount) / \(viewModel.requestedWordCount) Completed")
                .font(.footnote)
                .padding(.bottom)
            ProgressView(value: Float(viewModel.fetchedWordCount), total: Float(viewModel.requestedWordCount))
                .padding(.horizontal)
        }
    }
}

private struct ProgressAlert: UIViewControllerRepresentable {
    @ObservedObject var viewModel: AddCardViewModel
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ProgressAlert>) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ProgressAlert>) {
        guard isPresented else {
            uiViewController.dismiss(animated: true)
            return
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let progressContentView = ProgressAlertContent(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: progressContentView)
        
        hostingController.view.backgroundColor = .clear
        hostingController.preferredContentSize = CGSize(width: 250, height: 100)
        alert.setValue(hostingController, forKey: "contentViewController")

        DispatchQueue.main.async {
            if uiViewController.presentedViewController == nil {
                uiViewController.present(alert, animated: true)
            }
        }
    }
}

#Preview {
    NavigationView {
        AddCardView(viewModel: .init(container: .mock()))
    }
}
