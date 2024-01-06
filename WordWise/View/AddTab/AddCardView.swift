//
//  AddCardView.swift
//  WordWise
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftData
import Combine
import SwiftUI

struct AddCardView: View {
    @StateObject private var vm: AddCardViewModel
    @FocusState private var isFocused: Bool
    
    init(vm: AddCardViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
        
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    categoryPicker
                    textEditorView
                }
                
                VStack {
                    Spacer()
                    generateButton
                        .padding(.bottom, 100)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .gradientBackground()
            .navigationBarTitle("Add Cards", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            vm.setDefaultCategory()
        }
        .alert(vm.alertTitle, isPresented: $vm.showingAlert) {
            if vm.currentAlert == .addCategory {
                TextField("category name", text: $vm.textFieldInput)
                Button("Add", role: .none) {
                    vm.addCategory()
                }
                Button("Cancel", role: .cancel) {}
            } else {
                Button("OK", role: .none) {}
            }
        } message: {
            Text(vm.alertMessage)
        }
    }

    private var categoryPicker: some View {
        HStack(spacing: 0) {
            Picker("", selection: $vm.selectedCategory) {
                ForEach(vm.categories, id: \.self) { category in
                    Text(category).tag(category)
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
                vm.currentAlert = .addCategory
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
    }
    
    private var textEditorView: some View {
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
        .padding(.bottom, isFocused ? 0 : 90)
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
        .background(ProgressAlert(vm: vm, isPresented: $vm.generatingCards))
    }
}

#Preview {
    NavigationView {
        AddCardView(vm: .init(container: .mock()))
    }
}
