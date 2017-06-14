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
    
    
    func handleUpdateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            if self.viewModel.isLoading {
                self.showLoading()
            }else {
                self.hideLoading()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}


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
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.characters.count
    }
    
}
