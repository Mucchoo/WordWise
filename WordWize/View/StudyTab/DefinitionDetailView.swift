//
//  DefinitionDetailView.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct DefinitionDetailView: View {
    let meaning: Meaning
    let index: Int
    @Binding var showTranslations: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(meaning.partOfSpeech ?? "Unknown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                    .padding(.top, 4)
                    .background(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
            }
            
            ForEach(meaning.definitionsArray.indices, id: \.self) { index in
                if index != 0 {
                    Spacer().frame(height: 24)
                }
                
                let definition = meaning.definitionsArray[index]
                
                VStack(alignment: .leading) {
                    Text("\(index + 1). \(showTranslations ? definition.translatedDefinition ?? "" : definition.definition ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                                        
                    if let example = definition.example, !example.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Example: " + example)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    if let synonyms = definition.synonyms, !synonyms.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Synonyms: " + synonyms)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    if let antonyms = definition.antonyms, !antonyms.isEmpty {
                        Spacer().frame(height: 8)
                        Text("Antonyms: " + antonyms)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
