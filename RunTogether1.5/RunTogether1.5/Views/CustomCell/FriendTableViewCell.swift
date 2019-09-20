//
//  FriendTableViewCell.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/19/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

protocol FriendTableViewCellDelegate: class  {
    func cellSettingHasChanged(_ sender: FriendTableViewCell)
}

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    var isASearchResult:Bool = false
    
    weak var delegate: FriendTableViewCellDelegate?
    
    var userInCell:User?
    
    var isInChallengeMode = false
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        
            delegate?.cellSettingHasChanged(self)
            addButton.setTitle("Friend!", for: .normal)
        addButton.tintColor = UIColor(named: "areYaYellow")
        addButton.layer.backgroundColor = UIColor(named: "DeepMatteGrey")?.cgColor
        
    }
    
    
}
extension FriendTableViewCell {
    func update(user: User){
        pointsLabel.text = "\(user.totalMiles)"
        userInCell = user
        usernameLabel.text = user.name
        if !isASearchResult{
            addButton.isHidden = true
        }
    }
}
