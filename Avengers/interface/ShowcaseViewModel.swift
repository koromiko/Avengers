//
//  ShowcaseViewModel.swift
//  Avengers
//
//  Created by Neo on 13/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation


class ShowcaseViewModel: NSObject {
    
    typealias ShowcaseDataUpdatedCallback = ()->()
    
    var isLoading = false {
        didSet {
            self.dataUpdated?()
        }
    }
    var isCompleteLoading = false
    var characters = [MarvelCharacter]()
    
    var offset: Int {
        return characters.count
    }
    
    var dataUpdated: ShowcaseDataUpdatedCallback?
    
    func loadNextPage() {
        
        if isLoading || isCompleteLoading {
            return
        }
        print("load next offset \(offset)")
        isLoading = true
        
        MarvelCharacter.fetchMarvelCharacterList(offset: offset) { [unowned self] (success, pageCharacters, errorMessage) in
            print("fetched \(pageCharacters!.count)")
            if let pageCharacters = pageCharacters {
                self.characters.append(contentsOf: pageCharacters)
            }else {
                self.isCompleteLoading = true
            }
            self.isLoading = false
            
            self.dataUpdated?()
        }
    }
    
    func reloadData() {
        characters = [MarvelCharacter]()
        isLoading = false
        isCompleteLoading = false
        
        dataUpdated?()
    }
    
}
