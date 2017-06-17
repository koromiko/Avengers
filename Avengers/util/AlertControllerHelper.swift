//
//  AlertControllerHelper.swift
//  Avengers
//
//  Created by Neo on 17/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    convenience init( title: String, message: String, confirmHandler: @escaping ()->()) {
        self.init(title: title, message: message, preferredStyle: .alert)
        
        self.addAction( UIAlertAction(title: "Yes", style: .default, handler: {  (action) in
            confirmHandler()
        }))
        self.addAction( UIAlertAction(title: "Cancel", style: .cancel, handler: nil) )
    }
}
