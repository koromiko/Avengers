//
//  UIImageViewHelper.swift
//  Avengers
//
//  Created by Neo on 15/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation
import UIKit

/// Remote Image donwload helper
extension UIImageView {
    
    func loadImage( with url: URL ) {
        
        // Reduce the flash (1)
        if self.requestingURL != url.absoluteString {
            self.image = nil
        }
        
        /// In case that the unvisible cell callbacks interupt the visible ones, check requesting urls before putting on the downloaded images (2)
        self.requestingURL = url.absoluteString
        
        ApiManager.downloadData(from: url, complete: { [weak self] (success, imageData, error) in
            if success {
                if let imageData = imageData, let strongSelf = self {
                    DispatchQueue.main.async {
                        if strongSelf.requestingURL == url.absoluteString {
                            let image = UIImage(data: imageData )
                            strongSelf.image = image
                        }
                    }
                }
            }
        })
    }
    
    
}

/// extension property implementation
extension UIImageView {
    
    private struct AssociatedKeys {
        static var requestingURL: UInt8 = 0
    }
    
    var requestingURL: String {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.requestingURL ) as? String) ?? ""
        }
        set { objc_setAssociatedObject(self, &AssociatedKeys.requestingURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

}

