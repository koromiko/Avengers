//
//  character.swift
//  Avengers
//
//  Created by Neo on 11/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation
import UIKit

protocol JSONDecodable {
    associatedtype T
    static func decode(from jsonDictionary: [AnyHashable: Any] ) -> T?
}

protocol JSONEncodable {
    associatedtype T
    func encode() -> [AnyHashable: Any]
}

public struct MarvelCharacter {
    let name: String
    let desc: String?
    let avatarURL: String?
    
    var offlineImage: UIImage? {
        if let avatarURL = self.avatarURL {
            return MarvelCharacterManager.loadOfflineImage(with: avatarURL)
        }else {
            return nil
        }
    }

}

extension MarvelCharacter: JSONEncodable {
    func encode() -> [AnyHashable : Any] {
        var jsonDic = [AnyHashable: Any]()
        jsonDic["name"] = self.name
        if let desc = self.desc {
            jsonDic["desc"] = desc
        }
        if let url = self.avatarURL {
            jsonDic["avatar"] = url
        }
        return jsonDic
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

