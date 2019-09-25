//
//  FriendTableViewCell.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/19/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

protocol FriendTableViewCellDelegate: class  {
    func cellSettingHasChanged(_ sender: FriendTableViewCell,wasBlockPressed:Bool)
}

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var iconView: UIImageView!
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    var isASearchResult:Bool = false
    
    weak var delegate: FriendTableViewCellDelegate?
    
    var userInCell:User?
    
    @IBOutlet weak var cardView: UIView!
    
    var isInChallengeMode = false
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        delegate?.cellSettingHasChanged(self, wasBlockPressed: false)
            
        if isASearchResult{
        addButton.setTitle("Friend!", for: .normal)
        addButton.tintColor = UIColor(named: "areYaYellow")
        addButton.layer.backgroundColor = UIColor(named: "DeepMatteGrey")?.cgColor
        }
    }
    @IBAction func blockButtonTapped(_ sender: Any) {
        delegate?.cellSettingHasChanged(self, wasBlockPressed: true)
    }
    
    
}
extension FriendTableViewCell {
    func update(user: User){
        cardView.layer.shadowColor = UIColor(named: "areYaYellow")!.cgColor
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.cornerRadius = 5
        iconView.layer.cornerRadius = 15
        iconView.layer.masksToBounds = true
        iconView.layer.shadowColor = UIColor(named: "DeepMatteGrey")!.cgColor
        iconView.layer.shadowRadius = 5
        iconView.layer.shadowOffset = .zero
        iconView.layer.shadowOpacity = 0.5
        userInCell = user
        usernameLabel.text = "\(user.name)"
        addButton.layer.cornerRadius = 10
        if !isASearchResult{
            addButton.layer.backgroundColor = UIColor(named: "BloodRed")!.cgColor
            addButton.setTitle("RemoveFriend?", for: .normal)
        } else {
            addButton.layer.backgroundColor = UIColor(named: "areYaYellow")!.cgColor
            addButton.setTitle("add friend", for: .normal)
        }
    }
}
