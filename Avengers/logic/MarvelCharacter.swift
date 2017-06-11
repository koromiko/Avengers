//
//  character.swift
//  Avengers
//
//  Created by Neo on 11/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

private protocol JSONDecodable {
    associatedtype T
    static func decode(from jsonDictionary: [AnyHashable: Any] ) -> T?
}

public struct MarvelCharacter {
    let name: String
    let desc: String?
    let avatarURL: String?

}

// Interface
extension MarvelCharacter {
    
    public static func getAllMarvelCharacters( complete: @escaping ( _ success: Bool, _ offlineContentExists: Bool, _ response: [MarvelCharacter]? )->() ) {
        fetchMarvelCharacterList { (success, characters, errorMessage) in
            complete(success, false, characters)
        }
    }
    
}

extension MarvelCharacter: JSONDecodable {
    typealias T = MarvelCharacter
    static func decode(from jsonDictionary: [AnyHashable : Any]) -> MarvelCharacter? {
        if let name = jsonDictionary["name"] as? String {
            var avatarUrl: String?
            if let thumbnail = jsonDictionary["thumbnail"] as? [AnyHashable: Any],
                let url = thumbnail["path"] as? String,
                let ext = thumbnail["extension"] as? String {
                avatarUrl = url.appendingFormat(".%@", ext)
            }
            return MarvelCharacter(
                        name: name,
                        desc: jsonDictionary["description"] as? String,
                        avatarURL: avatarUrl )
        }else {
            return nil
        }
    }
}

// API
extension MarvelCharacter {
    fileprivate static func fetchMarvelCharacterList( complete: @escaping ( _ success: Bool, _ characters: [MarvelCharacter]?, _ errorMessage: String? )->() ) {
        
        ApiManager.fetchCharacterList { (success, response) in
            if success {
                if let response = response as? [AnyHashable: Any],
                    let data = response["data"] as? [AnyHashable: Any],
                    let results = data["results"] as? [[AnyHashable: Any]] {
                   
                    var characters = [MarvelCharacter]()
                    results.forEach({ (jsonDic) in
                        if let charOBj = MarvelCharacter.decode(from: jsonDic) {
                            characters.append(charOBj)
                        }
                    })
                    complete( true, characters, nil )
                }else {
                    complete( false, nil, response as? String )
                }
                
            } else {
                complete( false, nil ,response as? String )
            }
        }
    }
}

// Storage
extension MarvelCharacter {
    fileprivate static func saveToLocalStorage( data: [MarvelCharacter] ) {
        
    }
    
    fileprivate static func loadFromLocalStorage( exists: Bool, complete: [MarvelCharacter]? ) {
        
    }

}

