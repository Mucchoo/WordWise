//
//  ContentView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

enum TabType: String, CaseIterable {
    case study = "book.closed"
    case addCard = "plus.square"
    case categoryList = "rectangle.stack"
    case account = "person"
}

struct ContentView: View {
    @ObservedObject var contentViewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            TabView(selection: $contentViewModel.selectedTab) {
                StudyView()
                    .tag(TabType.study.rawValue)
                    .accessibilityIdentifier("StudyView")
                AddCardView(showTabBar: $contentViewModel.showTabBar)
                    .tag(TabType.addCard.rawValue)
                    .accessibilityIdentifier("AddCardView")
                CategoryListView()
                    .tag(TabType.categoryList.rawValue)
                    .accessibilityIdentifier("CategoryListView")
                AccountView()
                    .tag(TabType.account.rawValue)
                    .accessibilityIdentifier("AccountView")
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                if contentViewModel.showTabBar {
                    CustomTabBar(selectedTab: $contentViewModel.selectedTab, tabPoints: $contentViewModel.tabPoints)
                    Spacer().frame(height: 20)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { contentViewModel.onAppear() }
    }
}

#Preview {
    ContentView()
}

// MARK: - CustomTabBar

private struct CustomTabBar: View {
    @Binding var selectedTab: String
    @Binding var tabPoints: [CGFloat]
    
    var curvePoint: CGFloat {
        return tabPoints[tabIndex(for: selectedTab) ?? 0]
    }
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(image: TabType.study.rawValue, index: 0, selectedTab: $selectedTab, tabPoints: $tabPoints)
                .accessibilityIdentifier("studyViewTabButton")
            TabBarButton(image: TabType.addCard.rawValue, index: 1, selectedTab: $selectedTab, tabPoints: $tabPoints)
                .accessibilityIdentifier("addCardViewTabButton")
            TabBarButton(image: TabType.categoryList.rawValue, index: 2, selectedTab: $selectedTab, tabPoints: $tabPoints)
                .accessibilityIdentifier("cardListViewTabButton")
            TabBarButton(image: TabType.account.rawValue, index: 3, selectedTab: $selectedTab, tabPoints: $tabPoints)
                .accessibilityIdentifier("accountViewTabButton")
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [.navy, .ocean]), startPoint: .leading, endPoint: .trailing)
                .clipShape(TabCurve(tabPoint: curvePoint - 15)))
        .overlay(
            Circle()
                .fill(Color.ocean)
                .frame(width: 10, height: 10)
                .offset(x: curvePoint - 20)
            , alignment: .bottomLeading)
        .cornerRadius(30)
        .padding(.horizontal)
    }
    
    private func tabIndex(for tab: String) -> Int? {
        return TabType.allCases.firstIndex { $0.rawValue == tab }
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
