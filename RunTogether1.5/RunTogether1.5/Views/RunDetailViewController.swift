//
//  RunDetailViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/20/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class RunDetailViewController: UIViewController {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var elevationGainedLabel: UILabel!
    
    @IBOutlet weak var averagePaceLabel: UILabel!

    
    @IBOutlet weak var timePointsLabel: UILabel!
    
    @IBOutlet weak var elevationPointsLabel: UILabel!
    
    @IBOutlet weak var statsSelector: UISegmentedControl!
    
    @IBOutlet weak var sendARunButton: UIButton!
    
    var isAChallenge = true
    
    var isDisplayingUser = true
    
    var userIsAcceptingChallenge = false
    
    var landingPadUserRun:Run?
    
    var landingPadOpponentRun:Run?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialUISetUp()
    }

    

    
    //MARK: - ACTIONS
    
    @IBAction func statsSelectorTapped(_ sender: UISegmentedControl) {
        if isDisplayingUser{
            isDisplayingUser = false
             changeColors(borderColor: "areYaYellow")
        } else {
            isDisplayingUser = true
            changeColors(borderColor: "SilverFox")
        }
        changeStatsUpdate()
    }
    
    @IBAction func challengeSomeOneButtonTapped(_ sender: Any) {
        guard let run = landingPadUserRun else {return}
        guard let owner = CloudController.shared.user else {return}
        guard let runowner = run.user else {return}
        if runowner == owner {
        if let _ = run.sendTo{
                presentAwaitingOtherUserAlert()
                return
            }
        }
        if userIsAcceptingChallenge{
            performSegue(withIdentifier: "challengeAccepted", sender: nil)
        } else 
        if !isAChallenge{
            performSegue(withIdentifier: "toChallenge", sender: nil)
        }
    }
    
    
    
    
    //MARK: - HELPERS
    
    func presentAwaitingOtherUserAlert(){
        let alertController = UIAlertController(title: "Wait up!", message: "This run has already been sent to another user.  come back later when the've completed their run", preferredStyle: .alert)
        let alertOkay = UIAlertAction(title: "okay ", style: .default, handler: nil)
        alertController.addAction(alertOkay)
        self.present(alertController, animated: true)
    }
    
    
    func InitialUISetUp(){
         navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "SilverFox")!]
        if isAChallenge{
            sendARunButton.isHidden = true
        } else {
            statsSelector.isHidden = true
        }
        if userIsAcceptingChallenge{
            changeColors(borderColor: "areYaYellow")
            guard let run = landingPadOpponentRun else {return}
            landingPadUserRun = run
            sendARunButton.setTitle("ACCEPT THIS CHALLENGE", for: .normal)
            changeStatsUpdate()
            return
        }
        changeColors(borderColor: "SilverFox")
        changeStatsUpdate()
    }
    
    func changeColors(borderColor: String){
        let labelColor: String = borderColor
        let labelBorderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 10
        
        let labelArray: [UILabel] = [distanceLabel,timeLabel,elevationGainedLabel,averagePaceLabel,timePointsLabel,elevationPointsLabel]
   
        for label in labelArray {
            //set all labels border
            label.layer.borderWidth = labelBorderWidth
            //set labels border color
            label.layer.borderColor = UIColor(named: labelColor)!.cgColor
            //set labels cornerradius
            label.layer.cornerRadius = cornerRadius

        }
        dateLabel.layer.borderWidth = labelBorderWidth
        usernameLabel.layer.borderWidth = labelBorderWidth
        dateLabel.layer.borderColor = UIColor(named: labelColor)!.cgColor
        usernameLabel.layer.borderColor = UIColor(named: labelColor)!.cgColor
        usernameLabel.layer.cornerRadius = 10
        dateLabel.layer.cornerRadius = 10
    }
    
    func changeStatsUpdate(){
        guard let run = landingPadUserRun else {return}
        var selectedRun = run
        if !isDisplayingUser{
            guard let opponentRun = landingPadOpponentRun else {return}
            selectedRun = opponentRun
        }
        usernameLabel.text = selectedRun.user?.name ?? ""
        dateLabel.text = Converter.dateShort(selectedRun.date)
        timeLabel.text = "  Time: \(Converter.formatTime(seconds: Int(selectedRun.totalTime)))"
        guard let selectedUser = selectedRun.user else {return}
        elevationGainedLabel.text = "  ElevationGained: \(Converter.distance(selectedRun.elevationGained,user:selectedUser))"
        averagePaceLabel.text = "  AveragePace: \(Converter.pace(distance: selectedRun.distanceInMeasurement, seconds: Int(selectedRun.totalTime), user: selectedUser ))"
        timePointsLabel.text = "\(selectedRun.timePoints)"
        elevationPointsLabel.text = "\(selectedRun.elevationPoints)"
        distanceLabel.text = "  Distance:  \(Converter.distance(selectedRun.distance,user: selectedUser))"
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChallenge" {
            if let destination = segue.destination as? ChallengeTableViewController {
                guard let run = landingPadUserRun else {return}
                destination.runToSend = run
            }
        } else if segue.identifier == "challengeAccepted"{
            if let destination = segue.destination as? ChallengeAcceptedViewController{
                guard let run = landingPadOpponentRun else {return}
                
                destination.opponentRun = run
            }
        }
    }
    
  
}
