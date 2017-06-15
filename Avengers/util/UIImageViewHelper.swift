//
//  UIImageViewHelper.swift
//  Avengers
//
//  Created by Neo on 15/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func loadImage( with url: URL ) {
        self.image = nil
        
        ApiManager.downloadData(from: url, complete: { (success, imageData) in
            if success {
                if let imageData = imageData {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData )
                        self.image = image
                    }
                }
            }
        })
    }

}

