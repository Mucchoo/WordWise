//
//  Meaning+Extensions.swift
//  WordWize
//
//  Created by Musa Yazici on 9/10/23.
//

import Foundation

extension Meaning {
    public var definitionsArray: [Definition] {
        let definitionSet = definitions as? Set<Definition> ?? []
        
        return definitionSet.sorted {
            $0.createdAt ?? Date() < $1.createdAt ?? Date()
        }
    }
}
