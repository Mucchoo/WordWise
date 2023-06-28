//
//  LoadingView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/19/23.
//

import SwiftUI

struct LoadingView: View {
    @Binding var progress: Float

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Loading...")
                    .font(.title)
                    .foregroundColor(.primary)

                APIProgressView(progress: $progress)
            }
            .padding()
            .background(.black)
            .cornerRadius(10)
        }
    }
}

struct APIProgressView: View {
    @Binding var progress: Float

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = Float(geometry.size.width)
                let height = Float(geometry.size.height)
                
                path.addLines([
                    .init(x: 0, y: Double(height)),
                    .init(x: Double(width * progress), y: Double(height))
                ])
            }
            .fill(Color.blue, style: FillStyle(eoFill: true, antialiased: true))
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(progress: .constant(0.5))
    }
}

struct APIProgressView_Previews: PreviewProvider {
    static var previews: some View {
        APIProgressView(progress: .constant(0.5))
    }
}
