//
//  RunTableViewCell.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/16/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class RunTableViewCell: UITableViewCell {

    

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    var run:Run?
    
    @IBOutlet weak var envelopeImage: UIImageView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var runLandingPad:Run?
    
    var isAChallengeRecieved:Bool = false
    
    //this also works with the inbox but it is a run that has been sent/retrieved or sitting there
    func isASoloRun(){
        guard let ownerOfApp = CloudController.shared.user else {return}
        guard let runRecieved = runLandingPad else {return}
        guard let ownerOfRun = runRecieved.user else {return}
        //now we need to determine if its the user whos run this belongs to
        if ownerOfApp.name == ownerOfRun.name{
            usernameLabel.text = "My Personal Run"
            if let _ = runRecieved.sendTo{
                envelopeImage.isHidden = false
            }
        } else {
            usernameLabel.text = "Run from: \(ownerOfRun.name)"
            envelopeImage.isHidden = false
        }
        let dateAsString = Converter.dateFull(runRecieved.date)
        dateLabel.text = dateAsString
        let distanceAsString = Converter.distance(Measurement(value: runRecieved.distance, unit: UnitLength.meters))
        distanceLabel.text = distanceAsString
    }
    
    //meaning that both runs have been done
    func isACompleteRun(){
        guard let runRecieved = run else {return}
        guard let opponent = runRecieved.competingRun?.user else {return}
        let dateAsString = Converter.dateFull(runRecieved.date)
        dateLabel.text = "  \(dateAsString)"
        usernameLabel.text = "My run  against: \(opponent.name)"
        let distanceAsString = Converter.distance(Measurement(value: runRecieved.distance, unit: UnitLength.meters))
        distanceLabel.text = distanceAsString
   
    }
    
    func update(runRecieved: Run){
        envelopeImage.isHidden = true
        run = runRecieved
        cardView.layer.shadowColor = UIColor(named: "areYaYellow")!.cgColor
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.cornerRadius = 5
        
        runLandingPad = run
        //if there is a competeing run then it is a complete run
        if let _ = runRecieved.competingRun{
            isACompleteRun()
            return
        }
            isASoloRun()
        
        
    }
    
}
