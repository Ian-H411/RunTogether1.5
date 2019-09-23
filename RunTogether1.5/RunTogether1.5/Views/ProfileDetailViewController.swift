//
//  ProfileDetailViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/23/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class ProfileDetailViewController: UIViewController {
    //MARK: - OUTLETS
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = CloudController.shared.user else {return}
        usernameLabel.text = user.name
        if user.prefersMetric{
           let height = "\(user.height) CMs"
            let weight = "\(user.weight) Kgs"
            weightLabel.text = weight
            heightLabel.text = height

        } else {
           let heightAsInt = Int(user.height)
            let height = "\(user.height/12) foot \(heightAsInt % 12) Inchs"
            let weight = "\(user.weight) Lbs"
            weightLabel.text = weight
            heightLabel.text = height

        }
        ageLabel.text = "\(user.age) years old"
            }
  
}
