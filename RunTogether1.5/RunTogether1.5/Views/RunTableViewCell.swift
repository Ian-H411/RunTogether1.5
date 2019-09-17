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
    
    @IBOutlet weak var distanceLabel: UILabel!
    

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var opponentsUsernameLabel: UILabel!
    
    @IBOutlet weak var myPointsLabel: UILabel!
    
    @IBOutlet weak var opponentsLabel: UILabel!
    
    @IBOutlet weak var mytimeLabel: UILabel!
    
    @IBOutlet weak var opponentsTimeLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    func update(run: Run){
        //make distance pretty
        let distanceMeasurement = Measurement(value: run.distance, unit: UnitLength.miles)
        let distance:String = Converter.measureMentFormatter(distance: distanceMeasurement)
        distanceLabel.text = distance
        
        //make timelabel
        let time:String = Converter.formatTime(seconds: Int(run.totalTime))
        mytimeLabel.text = time
        
        //date
        let dateAsString:String = Converter.formatDate(date: run.date)
        dateLabel.text = dateAsString
        
        usernameLabel.text = RunCloudController.shared.user?.name
        
    }
    
}
