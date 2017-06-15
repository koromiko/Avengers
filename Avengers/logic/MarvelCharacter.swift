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

extension MarvelCharacter {
    
    public static func fetchMarvelCharacterList( offset: Int, complete: @escaping ( _ success: Bool, _ characters: [MarvelCharacter]?, _ errorMessage: String? )->() ) {
        
        ApiManager.fetchCharacterList(offset: offset) { (success, response) in
            if success {
                
                if let characters = jsonToObj(response) {
                    
                    StorageManager.saveCharacterList(charlist: response as! StorageManager.serializedKeyValueType)
                    
                    complete( true , characters, nil )
                }else {
                    complete( false , nil, response as? String )
                }
                
            } else {
                complete( false, nil , response as? String )
            }
        }
    }
    
    private static func jsonToObj( _ response: Any? ) -> [MarvelCharacter]? {
        if let response = response as? [AnyHashable: Any],
            let data = response["data"] as? [AnyHashable: Any],
            let results = data["results"] as? [[AnyHashable: Any]] {
            
            var characters = [MarvelCharacter]()
            results.forEach({ (jsonDic) in
                if let charOBj = MarvelCharacter.decode(from: jsonDic) {
                    characters.append(charOBj)
                }
            })
            
            return characters
        }else {
            return nil
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
                let httpsUrl = url.replacingOccurrences(of: "http", with: "https")
                avatarUrl = httpsUrl.appendingFormat(".%@", ext)
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

