//
//  StringHelper.swift
//  Avengers
//
//  Created by Neo on 12/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

extension String {
    var md5: String? {
        let leng = Int(CC_MD5_DIGEST_LENGTH)
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        let hash = data.withUnsafeBytes { ( bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        return (0..<leng).map { String(format: "%02x", hash[$0]) }.joined()
    }
}
