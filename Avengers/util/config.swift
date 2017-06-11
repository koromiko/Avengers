//
//  config.swift
//  Avengers
//
//  Created by Neo on 11/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

enum MarvelAPIConfig {
    static let privateKey = "f946657bbab4896b331b119507344b94779b6896"
    static let publicKey = "d3ae9994fb10ba7b42bf8354caab8118"
    static let baseURL = "https://gateway.marvel.com/v1"
}

extension MarvelAPIConfig {
    static var characterURL: String {
        return MarvelAPIConfig.baseURL.appending("/public/characters")
    }
}

