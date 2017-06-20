//
//  ApiManager.swift
//  Avengers
//
//  Created by Neo on 11/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

class ApiManager {

    public typealias completeClosureType = ( _ success: Bool, _ response: AnyObject?)->Void
    
    public class func fetchCharacterList( offset: Int, callback: @escaping completeClosureType ) {
        
        let queryString = self.generateQueryString(with: [
                                    "offset": "\(offset)"
                                ])
        
        let url = URL(string: String(format:"%@?%@", MarvelAPIConfig.characterURL, queryString))!
        
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse? , error: Error?) in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    callback(true, json as AnyObject)
                }else {
                    callback( false , json as AnyObject)
                }
             
            }else {
                callback( false, nil )
            }
        }

        task.resume()
    }
    
    public class func downloadData( from url: URL, complete: @escaping (_ success: Bool, _ response: Data?, _ error: Error? )->()) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if (error != nil) {
                complete(false, nil, error )
            }else {
                complete(true, data, nil )
            }
        }.resume()
    }
}

fileprivate extension ApiManager {
    
    fileprivate class func generateQueryString(with parameter: [String: String]? ) -> String{
        
        let timestamp = String( Date().timeIntervalSince1970 )
        
        let hash = String(format: "%@%@%@", timestamp, MarvelAPIConfig.privateKey, MarvelAPIConfig.publicKey).md5!
        
        var queryString = String(format: "ts=%@&hash=%@&apikey=%@", timestamp, hash, MarvelAPIConfig.publicKey )

        if let parameter = parameter {
            parameter.forEach { (key, value) in
                queryString.append( String( format: "&%@=%@", key, value ))
            }
        }
        
        return queryString
    }
    
}


