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
        userInCell = user
        usernameLabel.text = user.name
        pointsLabel.text = "\(user.totalMiles)"
        
    }
    
}
