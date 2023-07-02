//
//  BackgroundView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct BackgroundView: View {
    @Binding var initialAnimation: Bool
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            ClubbedView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView(initialAnimation: .constant(true))
    }
}
