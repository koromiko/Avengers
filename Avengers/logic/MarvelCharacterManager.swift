//
//  MarvelCharacterManager.swift
//  Avengers
//
//  Created by Neo on 02/08/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit

class MarvelCharacterManager {
    
    enum MarvelCharacterOfflineContentKey {
        static let jsonContentKeyPrefix = "caracter_"
        static let offlineContentAvailableUserDefaultKey = "MarvelCharacterOfflineContentAvailableUserDefaultKey"
    }
    
    static var isOfflineContentAvaliable: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: MarvelCharacterOfflineContentKey.offlineContentAvailableUserDefaultKey)
        }
        get {
            return (UserDefaults.standard.object(forKey: MarvelCharacterOfflineContentKey.offlineContentAvailableUserDefaultKey) as? Bool) ?? false
        }
    }
    
    var manager: ApiManager!
    
    init(manager: ApiManager = ApiManager()) {
        self.manager = manager
    }
    
    func fetchMarvelCharacterList( offset: Int, complete: @escaping ( _ success: Bool, _ characters: [MarvelCharacter]?, _ errorMessage: String? )->() ) {
        
        manager.fetchCharacterList(offset: offset) { [weak self] (success, response) in
            if success {
                guard let strongSelf = self else { return }
                
                if let characters = strongSelf.jsonToObj(response) {
                    complete( true , characters, nil )
                }else {
                    complete( false , nil, "Wrong Return Data Format" )
                }
                
            } else {
                complete( false, nil , response as? String )
            }
        }
    }
    
    func jsonToObj( _ response: Any? ) -> [MarvelCharacter]? {
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


extension MarvelCharacterManager {
    
    func downloadOfflineContent( progress: @escaping (_ progress: Float)->(), complete: @escaping (_ success: Bool )->() ) {
        self.fetchAllCharacterData(offset: 0, progress: progress) { (success, characters) in
            if let characters = characters, success {
                if characters.count == 0 {
                    MarvelCharacterManager.isOfflineContentAvaliable = true
                    complete( true )
                }
            }else {
                complete( false )
            }
        }
    }
    
    func removeOfflineContent() {
        try? StorageManager.removeOfflineContent()
        MarvelCharacterManager.isOfflineContentAvaliable = false
    }
    
    func fetchAllCharacterData( offset: Int, progress: @escaping (_ progress: Float)->(), update: @escaping (_ success: Bool, _ characters: [MarvelCharacter]? )->() ){
        
        manager.fetchCharacterList(offset: offset) { [weak self] (success, response ) in
            
            guard let response = response as? [AnyHashable: Any],
                let data = response["data"] as? [AnyHashable: Any],
                let total = data["total"] as? Int else {
                    update( false, nil)
                    return
            }
            
            guard let strongSelf = self else { return }
            
            let characters = strongSelf.jsonToObj(response) ?? [MarvelCharacter]()
            if characters.count > 0 {
                
                /* save json */
                do {
                    try StorageManager.saveOfflineContent(key: MarvelCharacterManager.offlineContentKey(with: offset), content: response )
                }catch {
                    update( false, nil )
                    return
                }
                
                /* download images */
                strongSelf.downloadOfflineImages(characters: characters, complete: { (success) in
                    
                    progress( Float(offset+characters.count)/Float(total) )
                    
                    /* fetch next page */
                    strongSelf.fetchAllCharacterData(offset: offset+characters.count, progress: progress, update: update)
                    
                })
            }
            
        }
        
    }
    
    func downloadOfflineImages( characters: [MarvelCharacter], complete: @escaping (_ success: Bool)->() ) {
        
        let downloadGroup = DispatchGroup()
        var anError: Error?
        characters.forEach({ (aChar) in
            if let avatarURL = aChar.avatarURL, let url = URL(string: avatarURL) {
                downloadGroup.enter()
                manager.downloadData(from: url, complete: { (success, data, err) in
                    
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
    
    func loadOfflineMarvelCharacterList( offset: Int, complete: @escaping ( _ success: Bool, _ characters: [MarvelCharacter]?, _ errorMessage: String? )->() ) {
        
        if let content = StorageManager.loadOfflineContent(key: MarvelCharacterManager.offlineContentKey(with: offset)) {
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
