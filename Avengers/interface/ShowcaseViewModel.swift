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
    
    var isDownloading = false {
        didSet {
            self.dataUpdated?()
        }
    }
    
    var offlineContentAvailable = false {
        didSet {
            self.dataUpdated?()
        }
    }
    
    var downloadProgress: Float = 0.0 {
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
    
    override init() {
        super.init()
        defer {
            offlineContentAvailable = MarvelCharacter.isOfflineContentAvaliable
        }
    }
    
    func loadNextPage() {
        
        if isLoading || isCompleteLoading {
            return
        }

        isLoading = true
        
        if offlineContentAvailable {
            MarvelCharacter.loadOfflineMarvelCharacterList(offset: offset, complete: { (success, pageCharacters, errMsg) in
                if let pageCharacters = pageCharacters {
                    if pageCharacters.count != 0 {
                        self.characters.append(contentsOf: pageCharacters)
                    }else{
                        self.isCompleteLoading = true
                    }
                }
                
                self.isLoading = false
            })
        }else {
            MarvelCharacter.fetchMarvelCharacterList(offset: offset) { [unowned self] (success, pageCharacters, errorMessage) in
                if let pageCharacters = pageCharacters {
                    if pageCharacters.count != 0 {
                        self.characters.append(contentsOf: pageCharacters)
                    }else{
                        self.isCompleteLoading = true
                    }
                    
                }
                
                self.isLoading = false
            }
        }
        
    }
    
    func reloadData() {
        characters = [MarvelCharacter]()
        isLoading = false
        isCompleteLoading = false
        
        dataUpdated?()
    }
    
    func removeOfflineContent() {
        if !isDownloading {
            MarvelCharacter.removeOfflineContent()
            self.dataUpdated?()
        }
    }
    
    func downloadOfflineContent() {
        if !isDownloading && !offlineContentAvailable {
            self.isDownloading = true
            
            MarvelCharacter.downloadOfflineContent(
                progress: { (progress) in
                    self.downloadProgress = progress
                    
                }, complete: { (success) in
                    if success {
                        self.offlineContentAvailable = true
                    }
                
                    self.isDownloading = false
            })
        }
    }
    
}


