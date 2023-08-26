//
//  CategoryListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @State private var showingRenameAlert = false
    @State private var showingDeleteAlert = false
    @State private var categoryNameTextFieldInput = ""
    @State private var targetCategoryName = ""

    var body: some View {
        if dataViewModel.cards.isEmpty {
            NoCardView(image: "BoyRight")
        } else {
            NavigationView {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(dataViewModel.categories) { category in
                            ZStack() {
                                NavigationLink(destination: CardListView(categoryName: category.name ?? "")) {
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
                                        
                                        MasteryRateBars(categoryName: category.name ?? "nil")
                                    }
                                    .padding(10)
                                    .modifier(BlurBackground())
                                    .cornerRadius(20)
                                }

                                HStack {
                                    Spacer()
                                    
                                    VStack {
                                        Spacer().frame(height: 30)
                                        
                                        Menu {
                                            Button(action: {
                                                targetCategoryName = category.name ?? ""
                                                categoryNameTextFieldInput = category.name ?? ""
                                                showingRenameAlert = true
                                            }) {
                                                Label("Rename", systemImage: "pencil")
                                            }

                                            Button(action: {
                                                targetCategoryName = category.name ?? ""
                                                showingDeleteAlert = true
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis.circle.fill")
                                                .resizable()
                                                .frame(width: 35, height: 35)
                                                .foregroundColor(colorScheme == .dark ? .teal : .navy)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    Spacer().frame(width: 30)
                                }
                            }
                        }
                    }
                }
                .background(BackgroundView())
                .navigationBarTitle("Categories", displayMode: .large)
                .alert("Rename Category", isPresented: $showingRenameAlert) {
                    TextField("category name", text: $categoryNameTextFieldInput)
                    Button("Rename", role: .none) {
                        dataViewModel.renameCategory(before: targetCategoryName, after: categoryNameTextFieldInput)
                    }
                    .disabled(categoryNameTextFieldInput.isEmpty)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Please enter the new category name.")
                }
                .alert("Do you want to delete \(targetCategoryName) and it's cards?", isPresented: $showingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        dataViewModel.deleteCategoryAndItsCards(name: targetCategoryName)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This operation cannot be undone.")
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

#Preview {
    CategoryListView()
        .injectMockDataViewModelForPreview()
}
