//
//  character.swift
//  Avengers
//
//  Created by Neo on 11/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

public struct MarvelCharacter {
    let name: String
    let desc: String
    let avatarURL: String
    
}

// Interface
extension MarvelCharacter {
    
    public func getAllMarvelCharacters( complete: ( _ success: Bool, _ offlineContentExists: Bool, _ response: [MarvelCharacter]? )->() ) {
        
    }
    
}

// API
extension MarvelCharacter {
    fileprivate static func fetchMarvelCharacterList( success: Bool, complete: [MarvelCharacter]? ) {
        
    }
}

// Storage
extension MarvelCharacter {
    fileprivate static func saveToLocalStorage( data: [MarvelCharacter] ) {
        
    }
    
    fileprivate static func loadFromLocalStorage( exists: Bool, complete: [MarvelCharacter]? ) {
        
    }

}

