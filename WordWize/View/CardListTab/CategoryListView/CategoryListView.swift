//
//  CategoryListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: CategoryListViewModel
    
    init(viewModel: CategoryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        if viewModel.container.appState.categories.isEmpty {
            NoCardView(image: "BoyRight")
        } else {
            NavigationView {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.container.appState.categories) { category in
                            categoryRow(category)
                        }
                    }
                }
                .gradientBackground()
                .navigationBarTitle("Categories", displayMode: .large)
                .alert("Rename Category", isPresented: $viewModel.showingRenameAlert) {
                    TextField("category name", text: $viewModel.categoryNameTextFieldInput)
                    Button("Rename", role: .none) {
                        viewModel.renameCategory()
                    }
                    .disabled(viewModel.categoryNameTextFieldInput.isEmpty)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Please enter the new category name.")
                }
                .alert("Do you want to delete \(viewModel.targetCategoryName) and it's cards?", isPresented: $viewModel.showingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteCategory()
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
            NavigationLink(destination: CardListView(viewModel: .init(container: viewModel.container, categoryName: category.name ?? ""))) {
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
                    
                    MasteryRateBars(viewModel: .init(container: viewModel.container, categoryName: category.name ?? ""))
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
                            viewModel.targetCategoryName = category.name ?? ""
                            viewModel.categoryNameTextFieldInput = category.name ?? ""
                            viewModel.showingRenameAlert = true
                        }) {
                            Label("Rename", systemImage: "pencil")
                        }

                        Button(action: {
                            viewModel.targetCategoryName = category.name ?? ""
                            viewModel.showingDeleteAlert = true
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

//#Preview {
//    CategoryListView()
//        .injectMockDataViewModelForPreview()
//}
