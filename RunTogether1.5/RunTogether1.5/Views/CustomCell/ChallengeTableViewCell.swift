//
//  ChallengeTableViewCell.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/20/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
protocol ChallengeTableViewCellDelegate: class  {
    func cellSettingHasChanged(_ sender: ChallengeTableViewCell)
}


class ChallengeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var challengeLabel: UIButton!
    
    @IBOutlet weak var cardView: UIView!
    
    var userInCell:User?
    
    weak var delegate: ChallengeTableViewCellDelegate?
    
    @IBAction func challengeButtonTapped(_ sender: Any) {
        delegate?.cellSettingHasChanged(self)
        challengeLabel.setTitle("Sent", for: .normal)
        challengeLabel.tintColor = UIColor(named: "areYaYellow")
        challengeLabel.layer.backgroundColor = UIColor(named: "DeepMatteGrey")?.cgColor
    }
    
 
}
extension ChallengeTableViewCell {
    func update (user: User){
        cardView.layer.shadowColor = UIColor(named: "areYaYellow")!.cgColor
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.cornerRadius = 5
        challengeLabel.layer.cornerRadius = 5
        
        
        userInCell = user
        usernameLabel.text = user.name        
    }
    
}
