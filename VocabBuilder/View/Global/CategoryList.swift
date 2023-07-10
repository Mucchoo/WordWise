//
//  CategoryList.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct CategoryList: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @Binding var categories: [String]
    @State var showingRenameAlert = false
    @State var textFieldInput = ""
    @State var categoryToRename = ""
    
    init(categories: Binding<[String]>) {
        _categories = categories
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(dataViewModel.categories, id: \.id) { category in
                    VStack {
                        HStack {
                            if let categoryName = category.name, categories.contains(categoryName) {
                                Image(systemName: "checkmark.circle.fill")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            Text(category.name ?? "Unknown")
                            Spacer()
                            
                            if dataViewModel.cards.filter({ $0.category == category.name }).count > 0 {
                                Button {
                                    categoryToRename = category.name ?? ""
                                    showingRenameAlert = true
                                } label: {
                                    Text("Rename")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(.blue)
                                        .cornerRadius(10)
                                }
                            } else {
                                Button {
                                    dataViewModel.deleteCategory(name: category.name ?? "")
                                } label: {
                                    Text("Delete")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(.red)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 4)
                        .padding(.horizontal)
                        .onTapGesture {
                            guard let categoryName = category.name else { return }
                            if categories.contains(categoryName) {
                                guard categories.count != 1 else { return }
                                categories.removeAll { $0 == category.name }
                            } else {
                                categories.append(categoryName)
                            }
                        }
                        
                        if category.id != dataViewModel.categories.last?.id {
                            Divider()
                        }
                    }
                }
                .environment(\.editMode, .constant(EditMode.active))
                .presentationDetents([.medium, .large])
                .alert("Rename Category", isPresented: $showingRenameAlert) {
                    TextField("category name", text: $textFieldInput)
                    Button("Rename", role: .none) {
                        dataViewModel.renameCategory(before: categoryToRename, after: textFieldInput)
                        textFieldInput = ""
                        categoryToRename = ""
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Please enter the new category name.")
                }
            }
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(10)
            .clipped()
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct CategoryList_Previews: PreviewProvider {
    static var previews: some View {
        CategoryList(categories: .constant(["Category 1"]))
    }
}
