//
//  CategoryListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var vm: CategoryListViewModel
    
    init(vm: CategoryListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        if vm.container.appState.categories.isEmpty {
            NoCardView(image: "BoyRight")
        } else {
            NavigationView {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(vm.container.appState.categories) { category in
                            categoryRow(category)
                        }
                    }
                }
                .gradientBackground()
                .navigationBarTitle("Categories", displayMode: .large)
                .alert("Rename Category", isPresented: $vm.showingRenameAlert) {
                    TextField("category name", text: $vm.categoryNameTextFieldInput)
                    Button("Rename", role: .none) {
                        vm.renameCategory()
                    }
                    .disabled(vm.categoryNameTextFieldInput.isEmpty)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Please enter the new category name.")
                }
                .alert("Do you want to delete \(vm.targetCategoryName) and it's cards?", isPresented: $vm.showingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        vm.deleteCategory()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This operation cannot be undone.")
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private func categoryRow(_ category: CardCategory) -> some View {
        ZStack() {
            NavigationLink(destination: CardListView(vm: .init(container: vm.container, categoryName: category.name ?? ""))) {
                VStack {
                    HStack(alignment: .top) {
                        Text(category.name ?? "")
                            .fontWeight(.bold)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "ellipsis.circle.fill")
                            .resizable()
                            .opacity(0)
                            .frame(width: 35, height: 35)
                    }
                    
                    MasteryRateBars(vm: .init(container: vm.container, categoryName: category.name ?? ""))
                }
                .padding(10)
                .blurBackground()
                .cornerRadius(20)
            }

            HStack {
                Spacer()
                
                VStack {
                    Spacer().frame(height: 30)
                    
                    Menu {
                        Button(action: {
                            vm.targetCategoryName = category.name ?? ""
                            vm.categoryNameTextFieldInput = category.name ?? ""
                            vm.showingRenameAlert = true
                        }) {
                            Label("Rename", systemImage: "pencil")
                        }

                        Button(action: {
                            vm.targetCategoryName = category.name ?? ""
                            vm.showingDeleteAlert = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(colorScheme == .dark ? .sky : .navy)
                    }
                    
                    Spacer()
                }
                
                Spacer().frame(width: 30)
            }
        }
    }
}

#Preview {
    CategoryListView(vm: .init(container: .mock()))
}
