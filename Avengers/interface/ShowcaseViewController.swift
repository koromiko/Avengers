//
//  ShowcaseViewController.swift
//  Avengers
//
//  Created by Neo on 11/06/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit

private enum ShowcaseTableViewCellIdentifier {
    static let characterCellIdentifier = "characterCellIdentifier"
}

class ShowcaseCharacterTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
}

class ShowcaseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var downloadBtn: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var loadingAvtivityIndicator: UIActivityIndicatorView!
    
    @IBAction func downloadBtnPressed(_ sender: Any) {
        
        if self.viewModel.offlineContentAvailable {
            let alert = UIAlertController(title: "Remove Offline Content", message: "Are you sure to remove offline content?", confirmHandler: { 
                self.viewModel.removeOfflineContent()
            })
            
            self.present(alert, animated: true, completion: nil)

        }else {
            let alert = UIAlertController(title: "Download Offline Content", message: "Are you sure to download offline content?", confirmHandler: { [unowned self] () in
                self.viewModel.downloadOfflineContent()
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    lazy var viewModel: ShowcaseViewModel = {
       return ShowcaseViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        viewModel.dataUpdated = { [unowned self] () in
            self.handleUpdateUI()
        }
        
        viewModel.loadNextPage()
    }
    
    /// Handle all UI update respond to the change of state (view model)
    func handleUpdateUI() {
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
            if self.viewModel.isLoading {
                self.showLoading()
            }else {
                self.hideLoading()
            }
            
            if self.viewModel.isDownloading {
                self.loadingAvtivityIndicator.startAnimating()
                self.progressView.progress = self.viewModel.downloadProgress
                self.downloadBtn.alpha = 0.0
                self.progressView.alpha = 1.0
            }else {
                self.loadingAvtivityIndicator.stopAnimating()
                self.downloadBtn.alpha = 1.0
                self.progressView.alpha = 0.0
            }
            
            if self.viewModel.offlineContentAvailable {
                self.downloadBtn.setTitle("Downloaded", for: .normal)
            }else {
                self.downloadBtn.setTitle("Download", for: .normal)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}

//MARK: Pagination Loading View
extension ShowcaseViewController {
    
    func showLoading() {
        let loadingFooter = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        loadingFooter.frame.size.height = 50
        loadingFooter.hidesWhenStopped = true
        loadingFooter.startAnimating()
        tableView.tableFooterView = loadingFooter
        
    }
    
    func hideLoading() {
        tableView.tableFooterView = UIView()
    }
    
}


extension ShowcaseViewController: UIScrollViewDelegate {
    
    /// Trigger pagination when scroll to bottom
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isContentLargerThanScreen = (scrollView.contentSize.height > scrollView.frame.size.height)
        let viewableHeight = isContentLargerThanScreen ? scrollView.frame.size.height : scrollView.contentSize.height

        let isAtBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - viewableHeight + 40)
        if isAtBottom && !viewModel.isLoading {
            viewModel.loadNextPage()
        }
    }
}

extension ShowcaseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShowcaseTableViewCellIdentifier.characterCellIdentifier, for: indexPath) as! ShowcaseCharacterTableViewCell
        
        let aChar = viewModel.characters[indexPath.row]
        cell.nameLabel.text = aChar.name
        cell.descLabel.text = aChar.desc ?? ""
        
        if let imageURL = aChar.avatarURL {
            if let image = aChar.offlineImage {
                cell.avatarImageView.image = image
            }else {
                cell.avatarImageView.loadImage(with: URL(string: imageURL)!)
            }
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.characters.count
    }
    
}
