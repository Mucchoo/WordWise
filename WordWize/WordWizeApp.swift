//
//  WordWizeApp.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct WordWizeApp: App {
    private var persistence: Persistence
    private var cardService: CardService
    
    @StateObject private var dataViewModel: DataViewModel = {
        let useInMemory = Self.shouldUseInMemory
        let persistence = Persistence(inMemory: useInMemory)
        let cardService: CardService = Self.isRunningForPreviews ? MockCardService() : NetworkCardService()
        return DataViewModel(cardService: cardService, persistence: persistence)
    }()
    
    private static var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    private static var shouldUseInMemory: Bool {
        isRunningForPreviews || CommandLine.arguments.contains("FOR_TESTING")
    }

    init() {
        let useInMemory = Self.shouldUseInMemory
        self.persistence = .init(inMemory: useInMemory)
        self.cardService = Self.isRunningForPreviews ? MockCardService() : NetworkCardService()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.viewContext)
                .environmentObject(dataViewModel)
        }
    }
}

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
