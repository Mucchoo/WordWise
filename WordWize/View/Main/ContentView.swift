//
//  ContentView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @State var selectedTab = "book.closed"
    @State private var showTabBar = true

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                StudyView()
                    .tag("book.closed")
                    .accessibilityIdentifier("StudyView")
                AddCardView(showTabBar: $showTabBar)
                    .tag("plus.square")
                    .accessibilityIdentifier("AddCardView")
                CategoryListView()
                    .tag("rectangle.stack")
                    .accessibilityIdentifier("CategoryListView")
                AccountView()
                    .tag("person")
                    .accessibilityIdentifier("AccountView")
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                if showTabBar {
                    CustomTabBar(selectedTab: $selectedTab)
                    Spacer().frame(height: 20)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            dataViewModel.retryFetchingImages()
            
            guard CommandLine.arguments.contains("SETUP_DATA_FOR_TESTING") else { return }
            print("SETUP_DATA_FOR_TESTING")
            
            dataViewModel.addDefaultCategory {
                for i in 0..<Int.random(in: 1..<100) {
                    let testCard = dataViewModel.makeTestCard(text: "test card \(i)")
                    dataViewModel.cards.append(testCard)
                    print("add card: \(i)")
                }

                dataViewModel.persistence.saveContext()
                dataViewModel.loadData()

                dataViewModel.cards.forEach { card in
                    if card.category == nil {
                        card.category = dataViewModel.categories.first?.name
                        dataViewModel.persistence.saveContext()
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}

// MARK: - CustomTabBar

private struct CustomTabBar: View {
    @Binding var selectedTab: String
    @State var tabPoints: [CGFloat] = [10,0,0,0]

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(image: "book.closed", index: 0, selectedTab: $selectedTab, tabPoints: $tabPoints)
                .accessibilityIdentifier("studyViewTabButton")

            TabBarButton(image: "plus.square", index: 1, selectedTab: $selectedTab, tabPoints: $tabPoints)
                .accessibilityIdentifier("addCardViewTabButton")

            TabBarButton(image: "rectangle.stack", index: 2, selectedTab: $selectedTab, tabPoints: $tabPoints)
                .accessibilityIdentifier("cardListViewTabButton")

            TabBarButton(image: "person", index: 3, selectedTab: $selectedTab, tabPoints: $tabPoints)
                .accessibilityIdentifier("accountViewTabButton")
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [.navy, .ocean]), startPoint: .leading, endPoint: .trailing)
                .clipShape(TabCurve(tabPoint: getCurvePoint() - 15)))
        .overlay(
            Circle()
                .fill(Color.ocean)
                .frame(width: 10, height: 10)
                .offset(x: getCurvePoint() - 20)
            , alignment: .bottomLeading)
        .cornerRadius(30)
        .padding(.horizontal)
    }

    func getCurvePoint() -> CGFloat {
        switch selectedTab {
        case "book.closed":
            return tabPoints[0]
        case "plus.square":
            return tabPoints[1]
        case "rectangle.stack":
            return tabPoints[2]
        default:
            return tabPoints[3]
        }
    }
}

private struct TabBarButton: View {
    var image: String
    var index: Int
    @Binding var selectedTab: String
    @Binding var tabPoints: [CGFloat]

    var body: some View {
        GeometryReader { reader -> AnyView in
            let midX = reader.frame(in: .global).midX

            DispatchQueue.main.async {
                tabPoints[index] = midX
            }

            return AnyView(
                Button {
                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.5)) {
                        selectedTab = image
                    }
                } label: {
                    Image(systemName: "\(image)\(selectedTab == image ? ".fill" : "")")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.white)
                        .offset(y: selectedTab == image ? -10 : 0)
                        .accessibility(identifier: "\(image)")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
        .frame(height: 40)
    }
}

private struct TabCurve: Shape {
    var tabPoint: CGFloat
    var animatableData: CGFloat {
        get { return tabPoint }
        set { tabPoint = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            
            let mid = tabPoint
            
            path.move(to: CGPoint(x: mid - 40, y: rect.height))
            
            let to = CGPoint(x: mid, y: rect.height - 20)
            let control1 = CGPoint(x: mid - 15, y: rect.height)
            let control2 = CGPoint(x: mid - 15, y: rect.height - 20)
            
            let to1 = CGPoint(x: mid + 40, y: rect.height)
            let control3 = CGPoint(x: mid + 15, y: rect.height - 20)
            let control4 = CGPoint(x: mid + 15, y: rect.height)
            
            path.addCurve(to: to, control1: control1, control2: control2)
            path.addCurve(to: to1, control1: control3, control2: control4)
        }
    }
}
