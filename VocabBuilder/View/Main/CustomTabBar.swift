//
//  CustomTabBar.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/28/23.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: String
    @State var tabPoints: [CGFloat] = []

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(image: "book.closed", selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(image: "plus.square", selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(image: "rectangle.stack", selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(image: "person", selectedTab: $selectedTab, tabPoints: $tabPoints)
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("purple"), Color("orange")]), startPoint: .leading, endPoint: .trailing)
                .clipShape(TabCurve(tabPoint: getCurvePoint() - 15)))
        .overlay(
            Circle()
                .fill(Color("purple"))
                .frame(width: 10, height: 10)
                .offset(x: getCurvePoint() - 20)
            , alignment: .bottomLeading)
        .cornerRadius(30)
        .padding(.horizontal)
    }

    func getCurvePoint() -> CGFloat {
        if tabPoints.isEmpty {
            return 10
        } else {
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
}

struct TabBarButton: View {
    var image: String
    @Binding var selectedTab: String
    @Binding var tabPoints: [CGFloat]

    var body: some View {
        GeometryReader { reader -> AnyView in
            let midX = reader.frame(in: .global).midX

            DispatchQueue.main.async {
                if tabPoints.count <= 4 {
                    tabPoints.append(midX)
                }
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
        .frame(height: 40)
    }
}

struct Home: View {
    @State var selectedTab = "house"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.blue)
                .ignoresSafeArea()
            
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}
