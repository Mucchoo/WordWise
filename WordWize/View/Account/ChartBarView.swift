//
//  ChartBarView.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct ChartBarView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @State var status: Int
    var image: String
    var colors: [Color]
    
    @State private var progress: CGFloat = 0
    @State private var isLoaded = false
    @State private var text = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 90 + progress * (geometry.size.width - 90), height: 30)
                    .animation(.easeInOut(duration: 1), value: progress)
                HStack(spacing: 2) {
                    Image(systemName: image)
                        .font(.system(size: 14))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .frame(width: 14)
                        .padding(.leading, 10)
                    Spacer()
                    Text(isLoaded ? text : "")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .animation(isLoaded ? .easeInOut(duration: 1) : .none)
                    Spacer()
                        .frame(width: 6)
                }
                .frame(width: 85 + progress * (geometry.size.width - 85), height: 30)
                .animation(isLoaded ? .easeInOut(duration: 1) : .none, value: isLoaded)
            }
            .onAppear {
                isLoaded = false
                text = "\(dataViewModel.cards.filter { $0.status == status }.count)"
                progress = dataViewModel.maxStatusCount > 0 ? CGFloat(dataViewModel.cards.filter { $0.status == status }.count) / CGFloat(dataViewModel.maxStatusCount) : 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isLoaded = true
                }
            }
        }
        .frame(height: 30)
        .accessibilityIdentifier("chartBar\(status)")
    }
}

struct ChartBarView_Previews: PreviewProvider {
    static var previews: some View {
        ChartBarView(status: 0, image: "checkmark", colors: [.black, .blue])
    }
}
