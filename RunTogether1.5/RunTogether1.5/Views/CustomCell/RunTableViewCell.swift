//
//  RunTableViewCell.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/16/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class RunTableViewCell: UITableViewCell {

    @IBOutlet weak var playerVsPlayerLabel: UILabel!
    

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var opponentsUsernameLabel: UILabel!
    
    @IBOutlet weak var myPointsLabel: UILabel!
    
    @IBOutlet weak var opponentsLabel: UILabel!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var runLandingPad:Run?
    
    var isAChallengeRecieved:Bool = false
    
    
    func update(run: Run){
        
        cardView.layer.shadowColor = UIColor(named: "areYaYellow")!.cgColor
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.cornerRadius = 5
        
        
        
        runLandingPad = run
        //if the run is complete on both ends
        if let opposingRun = run.competingRun{
            guard let user = CloudController.shared.user else {return}
            playerVsPlayerLabel.isHidden = false
            opponentsUsernameLabel.isHidden = false
            myPointsLabel.text = "\(run.totalPoints)"
            opponentsLabel.text = "\(opposingRun.totalPoints)"
            usernameLabel.text = user.name
            
            
            //if the run is not complete
        } else {
            usernameLabel.isHidden = true
            playerVsPlayerLabel.isHidden = true
            opponentsUsernameLabel.isHidden = true
            if isAChallengeRecieved{
                guard let opponent = run.user else {return}
                usernameLabel.isHidden = false
                usernameLabel.text = "Run From: \(opponent.name)"
            }
            
            let dateFormatted = Converter.date(run.date)
            dateLabel.text = "\(dateFormatted)"
            
            
            let timeFormatted = Converter.formatTime(seconds: Int(run.totalTime))
            opponentsLabel.text = "Time: \n \(timeFormatted)"
            guard let selectedUser = run.user else {return}
            let distanceFormatted = Converter.distance(run.distance, user: selectedUser) 
            myPointsLabel.text = "Distance: \(distanceFormatted)"
            
           
        }
      
    }
    
}
