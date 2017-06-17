//
//  MarvelCharacterOfflineHelper.swift
//  Avengers
//
//  Created by Neo on 17/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation
import UIKit

extension MarvelCharacter {
    
    private enum MarvelCharacterOfflineContentKey {
        static let jsonContentKeyPrefix = "caracter_"
        static let offlineContentAvailableUserDefaultKey = "MarvelCharacterOfflineContentAvailableUserDefaultKey"
    }
    
    public static var isOfflineContentAvaliable: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: MarvelCharacterOfflineContentKey.offlineContentAvailableUserDefaultKey)
        }
        get {
            return (UserDefaults.standard.object(forKey: MarvelCharacterOfflineContentKey.offlineContentAvailableUserDefaultKey) as? Bool) ?? false
        }
    }
    
    static func downloadOfflineContent( complete: @escaping (_ success: Bool )->() ) {
        self.fetchAllCharacterData(offset: 0) { (success, characters) in
            if let characters = characters, success {
                if characters.count == 0 {
                    isOfflineContentAvaliable = true
                    complete( true )
                }
            }else {
                complete( false )
            }
        }
    }
    
    static func removeOfflineContent() {
        try? StorageManager.removeOfflineContent()
        self.isOfflineContentAvaliable = false
    }
    
    static func fetchAllCharacterData( offset: Int, update: @escaping (_ success: Bool, _ characters: [MarvelCharacter]? )->() ){
        
        ApiManager.fetchCharacterList(offset: offset) { (success, response ) in
            
            if let response = response as?  [AnyHashable: Any] {
                
                let characters = jsonToObj(response) ?? [MarvelCharacter]()
                if characters.count > 0 {
                    
                    /* save json */
                    do {
                        try StorageManager.saveOfflineContent(key: offlineContentKey(with: offset), content: response )
                    }catch {
                        update( false, nil )
                        return
                    }
                    
                    /* download images */
                    downloadOfflineImages(characters: characters, complete: { (success) in
                        
                        /* fetch next page */
                        fetchAllCharacterData(offset: offset+characters.count, update: update)
                        print("fetch nex \(offset)")
                    })
                }
                
            }else {
                update(false, nil)
            }

        }
        
    }
    
    static func downloadOfflineImages( characters: [MarvelCharacter], complete: @escaping (_ success: Bool)->() ) {
        
        let downloadGroup = DispatchGroup()
        var anError: Error?
        characters.forEach({ (aChar) in
            if let avatarURL = aChar.avatarURL, let url = URL(string: avatarURL) {
                downloadGroup.enter()
                ApiManager.downloadData(from: url, complete: { (success, data, err) in
                    print("download url \(avatarURL)")
                    if let data = data {
                        do {
                            try StorageManager.saveImageData(key: avatarURL, data: data)
                        } catch {
                            anError = error
                        }
                    }else {
                        anError = err
                    }
                    downloadGroup.leave()
                })
            }
        })
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            complete( anError == nil )
        }
    }

    public static func loadOfflineMarvelCharacterList( offset: Int, complete: @escaping ( _ success: Bool, _ characters: [MarvelCharacter]?, _ errorMessage: String? )->() ) {
        
        if let content = StorageManager.loadOfflineContent(key: offlineContentKey(with: offset)) {
            if let characters = jsonToObj(content) {
                complete( true, characters, nil)
            }else {
                complete( false, nil, "Data format error")
            }
        }else {
            complete( false, nil, "file not exists")
        }
        
    }
    
    public static func loadOfflineImage( with url: String ) -> UIImage? {
        return StorageManager.loadImage(key: url)
    }

    private static func offlineContentKey( with offset: Int ) -> String {
        return MarvelCharacterOfflineContentKey.jsonContentKeyPrefix.appending("\(offset)")
    }
    
    
    
    
}
