//
//  MasteryRateBars.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct MasteryRateBars: View {
    @StateObject private var vm: MasteryRateBarsViewModel
    
    init(vm: MasteryRateBarsViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            VStack(alignment: .leading, spacing: 8) {
                masteryRateBar(.oneHundred, width: width)
                masteryRateBar(.seventyFive, width: width)
                masteryRateBar(.fifty, width: width)
                masteryRateBar(.twentyFive, width: width)
                masteryRateBar(.zero, width: width)
            }
            .onAppear {
                vm.isLoaded = false
                vm.setWidthAndCountText(geometryWidth: width)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.isLoaded = true
                }
            }
        }
        .frame(height: 182)
    }
    
    private func masteryRateBar(_ rate: MasteryRate, width: CGFloat) -> some View {
        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(colors: vm.getColors(rate), startPoint: .leading, endPoint: .trailing)
                )
                .frame(width: vm.barWidths[rate], height: 30)
                .animation(.easeInOut(duration: 1), value: vm.barWidths[rate])
            HStack(spacing: 2) {
                Text(vm.getRateText(rate))
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .font(.footnote)
                    .padding(.leading, 8)
                
                Spacer()
                
                Text(vm.isLoaded ? vm.countTexts[rate] ?? "" : "")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .animation(vm.isLoaded ? .easeInOut(duration: 1) : .none)
                
                Spacer()
                    .frame(width: 6)
            }
            .frame(width: 85 + vm.getRatio(rate) * (width - 85), height: 30)
            .animation(vm.isLoaded ? .easeInOut(duration: 1) : .none, value: vm.isLoaded)
        }
    }
}

#Preview {
    MasteryRateBars(vm: .init(container: .mock(), category: MockHelper.mockCategory))
}
