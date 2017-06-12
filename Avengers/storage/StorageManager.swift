//
//  StorageManager.swift
//  Avengers
//
//  Created by Neo on 11/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

enum StorageFileName {
    static let characterLocalContentFileName = "character.json"
}

class StorageManager {
    
    typealias serializedKeyValueType = [AnyHashable: Any]
    
    public class func saveCharacterList( charlist: serializedKeyValueType ) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: charlist, options: []) {
            try? jsonData.write(to: localCharacterContentURL )
        }
    }
    
    public class func loadCharacterList() -> serializedKeyValueType? {
        guard let fileData = try? Data(contentsOf: self.localCharacterContentURL) else {
            return nil
        }
        
        if let obj = try? JSONSerialization.jsonObject(with: fileData, options: .allowFragments) as? [AnyHashable: Any] {
            return obj
        }else {
            return nil
        }
        
    }
}

extension StorageManager {
    fileprivate class var localCharacterContentURL: URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: documentsPath).appendingPathComponent(StorageFileName.characterLocalContentFileName)
    }
}
