//
//  StorageManager.swift
//  Avengers
//
//  Created by Neo on 11/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation
import UIKit

enum StorageDirectoryName {
    static let offlineContentDirectoryName = "offline"
}

enum StorageError: Error {
    case saveFileError(msg: String)
    case fileNotExistError(msg: String)
    case formatError
}


/// Main storage logic
class StorageManager {
    
    typealias serializedKeyValueType = [AnyHashable: Any]
    
    /// Save a key/value pair to local json file system with specific key
    /// - Throws: `saveFileError` if storage full or file system was broken, `formatError` if input content can not be serialized to JSON or key contains special characters
    public class func saveOfflineContent( key: String, content: serializedKeyValueType ) throws -> Void {
        if let jsonData = try? JSONSerialization.data(withJSONObject: content, options: []) {
            try self.saveOfflineData(key: key, ext: "json", data: jsonData)
        }else {
            throw StorageError.formatError
        }
    }

    /// Load a key/value pair from local json file with specific key
    public class func loadOfflineContent( key: String ) -> serializedKeyValueType? {
        if let jsonData = self.loadOfflineData(key: key, ext: "json"),
            let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: []) {
            return (jsonObj as? StorageManager.serializedKeyValueType) ?? nil
        }
        return nil
    }
    
    public class func loadImage( key: String ) -> UIImage? {
        if let imageData = self.loadOfflineData(key: key, ext: "jpg") {
            return UIImage(data: imageData)
        }else{
            return nil
        }
    }
    
    public class func saveImageData( key: String, data: Data) throws -> Void {
        if let url = self.offlineContentFileURL(key: key, ext: "jpg") {
            try data.write(to: url)
        }
    }
    
    public class func removeOfflineContent() throws -> Void {
        try FileManager.default.removeItem(atPath: offlineContentDirectory)
    }
    
    /// generic save file function
    private class func loadOfflineData( key: String, ext: String ) -> Data? {
        if let url = self.offlineContentFileURL(key: key, ext: ext) {
            if let data = try? Data(contentsOf: url) {
                return data
            }
        }
    
        return nil
    }
    /// generic load data function
    private class func saveOfflineData( key: String, ext: String, data: Data) throws -> Void {
        if !FileManager.default.fileExists(atPath: StorageManager.offlineContentDirectory ) {
            do {
                try FileManager.default.createDirectory(atPath: StorageManager.offlineContentDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw StorageError.saveFileError(msg: "Can not create local file")
            }
        }
        
        guard let fileURL = self.offlineContentFileURL(key: key, ext: ext) else {
            throw StorageError.formatError
        }
        
        do {
            try data.write(to: fileURL )
        } catch {
            throw StorageError.saveFileError(msg: "Can not create local file")
        }
    }
    
    
    
}

/// Convinience Storage Path
extension StorageManager {
    
    fileprivate class func offlineContentFileURL( key: String, ext: String ) -> URL? {
        guard let escaptedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        let trimedSlashKey = escaptedKey.replacingOccurrences(of: "/", with: "_")
        return URL(fileURLWithPath: offlineContentDirectory).appendingPathComponent("\(trimedSlashKey).\(ext)")
    }
    
    fileprivate class var offlineContentDirectory: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let offlineDirPath = documentsPath.appendingFormat("/%@", StorageDirectoryName.offlineContentDirectoryName)
        return offlineDirPath
    }
}
