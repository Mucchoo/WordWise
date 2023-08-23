//
//  View+Extension.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/23/23.
//

import SwiftUI

extension View {
    func injectMockDataViewModelForPreview() -> some View {
        let isRunningForPreviews: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        
        if isRunningForPreviews {
            let mockModel = DataViewModel(cardService: MockCardService(), persistence: .init(inMemory: true))
            let card = mockModel.makeTestCard()
            mockModel.cards.append(card)
            mockModel.persistence.saveContext()
            mockModel.loadData()
            return AnyView(self.environmentObject(mockModel))
        } else {
            return AnyView(self)
        }
    }
}
