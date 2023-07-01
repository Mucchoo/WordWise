//
//  AddView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/13/23.
//

import CoreData
import SwiftUI
import AVFoundation

struct AddCardView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<CardCategory>
    @FocusState var isFocused: Bool
    
    @State private var VocabBuilders = [String]()
    @State private var isEditing = false
    @State private var cardText = ""
    @State private var pickerSelected = ""
    @State private var showingAlert = false
    @State private var textFieldInput = ""
    @State private var showingFetchFailedAlert = false
    @Binding var initialAnimation: Bool
    @State private var fetchFailedWords: [String] = []

    private let initialPlaceholder = "Write whatever wards you want to add. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.5))
                            .overlay(
                                TransparentBlurView(removeAllLayers: true)
                                .blur(radius: 9, opaque: true)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                        
                        HStack {
                            Picker("Options", selection: $pickerSelected) {
                                ForEach(categories) { category in
                                    let name = category.name ?? ""
                                    Text(name).tag(name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                        }
                    }
                    .frame(height: 44)
                                        
                    Button(action: {
                        showingAlert = true
                    }) {
                        Text("Add Category")
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(LinearGradient(colors: [Color("Navy"), Color("Blue")], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.leading, 10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)

                TextEditor(text: Binding(
                    get: { isEditing ? cardText : initialPlaceholder },
                    set: { cardText = $0 }
                ))
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .foregroundColor(isEditing ? .primary : .secondary)
                .onTapGesture {
                    isEditing = true
                }
                .onChange(of: cardText) { newValue in
                    cardText = newValue.lowercased()
                }
                .padding()
                .background {
                    TransparentBlurView(removeAllLayers: true)
                        .blur(radius: 9, opaque: true)
                        .background(.white.opacity(0.5))
                }
                .cornerRadius(10)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                .animation(.default)
                .padding([.horizontal, .bottom])
                
                Button(action: {
                    CardManager.shared.addCard(text: cardText) { [self] failedWords in
                        cardText = ""
                        
                        fetchFailedWords = failedWords
                        if !fetchFailedWords.isEmpty {
                            showingFetchFailedAlert = true
                        }
                    }
                    isFocused = false
                }) {
                    Text("Add \(cardText.split(separator: "\n").count) Cards")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [Color("Navy"), Color("Blue")], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cardText == initialPlaceholder)
                .padding([.horizontal, .bottom])

            }
            .padding(.bottom)
            .onTapGesture {
                isFocused = false
            }
            .background {
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                        .edgesIgnoringSafeArea(.all)
                    ClubbedView(initialAnimation: $initialAnimation)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitle("Add Cards", displayMode: .large)
        }
        .onAppear {
            PersistenceController.shared.addDefaultCategory()
        }
        
        .alert("Add Category", isPresented: $showingAlert) {
            TextField("category name", text: $textFieldInput)
            Button("Add", role: .none) {
                CardManager.shared.addCategory(name: textFieldInput)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enter the new category name.")
        }
        
        .alert("Failed to add cards", isPresented: $showingFetchFailedAlert) {
            Button("OK", role: .none) {}
        } message: {
            Text("Failed to find these wards on the dictionary.\n\n\(fetchFailedWords.joined(separator: "\n"))")
        }
        
        .overlay(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }
        )
    }
    
    @ViewBuilder
    func ClubbedView(initialAnimation: Binding<Bool>) -> some View {
        Rectangle()
            .fill(.linearGradient(colors: [Color("Teal"), Color("Mint")], startPoint: .top, endPoint: .bottom))
            .mask {
                TimelineView(.animation(minimumInterval: 20, paused: false)) { _ in
                    ZStack {
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.5, color: .yellow))
                            context.addFilter(.blur(radius: 30))
                            context.drawLayer { ctx in
                                for index in 1...30 {
                                    if let resolvedView = context.resolveSymbol(id: index) {
                                        ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                    }
                                }
                            }
                        } symbols: {
                            ForEach(1...30, id: \.self) { index in
                                let offset = CGSize(width: .random(in: -300...300), height: .random(in: -500...500))
                                ClubbedRoundedRectangle(offset: offset, initialAnimation: $initialAnimation.wrappedValue, width: 100, height: 100, corner: 50)
                                    .tag(index)
                            }
                        }
                    }
                }
            }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    func ClubbedRoundedRectangle(offset: CGSize, initialAnimation: Bool, width: CGFloat, height: CGFloat, corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.white)
            .frame(width: width, height: height)
            .offset(x: initialAnimation ? offset.width : 0, y: initialAnimation ? offset.height : 0)
            .animation(.easeInOut(duration: 20), value: offset)
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView(initialAnimation: .constant(true))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
