//
//  ShowcaseViewModel.swift
//  Avengers
//
//  Created by Neo on 13/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation


class ShowcaseViewModel {
    
    typealias ShowcaseDataUpdatedCallback = ()->()
    
    let manager: MarvelCharacterManager!
    
    init(manager: MarvelCharacterManager = MarvelCharacterManager() ) {
        self.manager = manager
        defer {
            offlineContentAvailable = MarvelCharacterManager.isOfflineContentAvaliable
        }
    }
    
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
    
    func loadNextPage() {
        
        if isLoading || isCompleteLoading {
            return
        }

        isLoading = true
        
        if offlineContentAvailable {
            manager.loadOfflineMarvelCharacterList(offset: offset, complete: { [weak self] (success, pageCharacters, errMsg) in
                
                guard let strongSelf = self else { return }
                
                if let pageCharacters = pageCharacters {
                    if pageCharacters.count != 0 {
                        strongSelf.characters.append(contentsOf: pageCharacters)
                    }else{
                        strongSelf.isCompleteLoading = true
                    }
                }
                strongSelf.isLoading = false
            })
        }else {
            manager.fetchMarvelCharacterList(offset: offset) { [weak self] (success, pageCharacters, errorMessage) in
                
                guard let strongSelf = self else { return }
                
                if let pageCharacters = pageCharacters {
                    if pageCharacters.count != 0 {
                        strongSelf.characters.append(contentsOf: pageCharacters)
                    }else{
                        strongSelf.isCompleteLoading = true
                    }
                }
                strongSelf.isLoading = false
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
            manager.removeOfflineContent()
            self.dataUpdated?()
        }
    }

    func downloadOfflineContent() {
        if !isDownloading && !offlineContentAvailable {
            self.isDownloading = true
            
            manager.downloadOfflineContent(
                progress: { (progress) in
                    self.downloadProgress = progress
                    
                }, complete: { [weak self] (success) in
                    guard let strongSelf = self else { return }
                    
                    if success {
                        strongSelf.offlineContentAvailable = true
                    }
                
                    strongSelf.isDownloading = false
            })
        }
    }
    
}


