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
    @StateObject private var vm: AddCardViewModel
    @FocusState private var isFocused: Bool
    
    init(vm: AddCardViewModel) {
        print("AddCardView init")
        _vm = StateObject(wrappedValue: vm)
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
            vm.setDefaultCategory()
        }
    }
    
    private var categoryPicker: some View {
        HStack(spacing: 0) {
            Picker("", selection: $vm.selectedCategory) {
                ForEach(vm.container.appState.categories, id: \.self) { category in
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
                vm.showingAddCategoryAlert = true
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
        .alert("Add Category", isPresented: $vm.showingAddCategoryAlert) {
            TextField("category name", text: $vm.textFieldInput)
            Button("Add", role: .none) {
                vm.addCategory()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enter the new category name.")
        }
    }
    
    private func textEditorView(baseHeight: CGFloat) -> some View {
        TextEditor(text: Binding(
            get: { vm.displayText },
            set: { vm.cardText = $0 }
        ))
        .scrollContentBackground(.hidden)
        .focused($isFocused)
        .foregroundColor(vm.showPlaceholder ? .secondary : .primary)
        .onChange(of: vm.cardText) { newValue in
            vm.updateTextEditor(text: newValue, isFocused: isFocused)
        }
        .onChange(of: isFocused) { newValue in
            vm.togglePlaceHolder(isFocused)
        }
        .blurBackground()
        .accessibilityIdentifier("addCardViewTextEditor")
        .frame(height: baseHeight - (isFocused ? 80 : 180))
    }
    
    private var generateButton: some View {
        Button(action: {
            vm.generateCards()
            
            withAnimation {
                isFocused = false
            }
        }) {
            Text("Add \(vm.cardText.split(separator: "\n").count) Cards")
                .padding()
                .frame(maxWidth: .infinity)
                .bold()
                .background(LinearGradient(colors: [.navy, .ocean], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .accessibilityIdentifier("addCardsButton")
        .disabled(vm.shouldDisableAddCardButton())
        .padding([.horizontal, .bottom])
        .alert("Failed to add cards", isPresented: $vm.showingFetchFailedAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text("Failed to find these wards on the dictionary.\n\n\(vm.fetchFailedWords.joined(separator: "\n"))")
        }
        
        .alert("Added Cards", isPresented: $vm.showingFetchSucceededAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text("Added \(vm.addedCardCount) cards successfully.")
        }
        .background(ProgressAlert(vm: vm, isPresented: $vm.generatingCards))
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
    @StateObject var vm: AddCardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Generating Cards...")
                .font(.headline)
                .bold()
                .padding(.bottom)
            Text("\(vm.fetchedWordCount) / \(vm.requestedWordCount) Completed")
                .font(.footnote)
                .padding(.bottom)
            ProgressView(value: Float(vm.fetchedWordCount), total: Float(vm.requestedWordCount))
                .padding(.horizontal)
        }
    }
}

private struct ProgressAlert: UIViewControllerRepresentable {
    @ObservedObject var vm: AddCardViewModel
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
        
        let progressContentView = ProgressAlertContent(vm: vm)
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
        AddCardView(vm: .init(container: .mock()))
    }
}
