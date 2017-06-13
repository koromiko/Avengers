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
    
    var viewModel: ShowcaseViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        viewModel?.dataUpdated = { [unowned self] () in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        viewModel?.loadNextPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}

extension ShowcaseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShowcaseTableViewCellIdentifier.characterCellIdentifier, for: indexPath) as! ShowcaseCharacterTableViewCell
        
        if let aChar = viewModel?.characters[indexPath.row] {
            cell.nameLabel.text = aChar.name
            cell.descLabel.text = aChar.desc ?? ""
            
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.characters.count ?? 0
    }
    
}
