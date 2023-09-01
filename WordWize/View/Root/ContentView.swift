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
    @StateObject private var vm: ContentViewModel
    
    init(container: DIContainer) {
        _vm = StateObject(wrappedValue: .init(container: container))
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $vm.selectedTab) {
                StudyView(vm: .init(container: vm.container))
                    .tag(TabType.study.rawValue)
                    .accessibilityIdentifier("StudyView")
                AddCardView(vm: .init(container: vm.container))
                    .tag(TabType.addCard.rawValue)
                    .accessibilityIdentifier("AddCardView")
                CategoryListView(vm: .init(container: vm.container))
                    .tag(TabType.categoryList.rawValue)
                    .accessibilityIdentifier("CategoryListView")
                AccountView(vm: .init(container: vm.container))
                    .tag(TabType.account.rawValue)
                    .accessibilityIdentifier("AccountView")
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                customTabBar
                Spacer().frame(height: 20)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { vm.onAppear() }
    }
    
    private var curvePoint: CGFloat {
        return vm.tabPoints[tabIndex(for: vm.selectedTab) ?? 0]
    }
    
    private func tabIndex(for tab: String) -> Int? {
        return TabType.allCases.firstIndex { $0.rawValue == tab }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabBarButton(index: 0, image: TabType.study.rawValue)
            tabBarButton(index: 1, image: TabType.addCard.rawValue)
            tabBarButton(index: 2, image: TabType.categoryList.rawValue)
            tabBarButton(index: 3, image: TabType.account.rawValue)
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
    
    private func tabBarButton(index: Int, image: String) -> some View {
        Button {
            withAnimation {
                vm.selectedTab = image
            }
        } label: {
            Image(systemName: "\(image)\(vm.selectedTab == image ? ".fill" : "")")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.white)
                .offset(y: vm.selectedTab == image ? -10 : 0)
                .accessibility(identifier: "\(image)")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeometryReader { geometry in
            Color.clear.onAppear {
                let midX = geometry.frame(in: .global).midX
                vm.tabPoints[index] = midX
            }
        })
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

#Preview {
    ContentView(container: .mock())
}
