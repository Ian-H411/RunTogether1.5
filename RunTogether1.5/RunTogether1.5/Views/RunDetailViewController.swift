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
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
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
        if userIsAcceptingChallenge{
            performSegue(withIdentifier: "challengeAccepted", sender: nil)
        } else 
        if !isAChallenge{
            performSegue(withIdentifier: "toChallenge", sender: nil)
        }
    }
    
    
    
    
    //MARK: - HELPERS
    
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
        let cornerRadius: CGFloat = 27
        
        let labelArray: [UILabel] = [distanceLabel,timeLabel,elevationGainedLabel,averagePaceLabel,caloriesLabel,timePointsLabel,elevationPointsLabel]
   
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
        usernameLabel.layer.cornerRadius = 22
        dateLabel.layer.cornerRadius = 22
    }
    
    func changeStatsUpdate(){
        guard let run = landingPadUserRun else {return}
        var selectedRun = run
        if !isDisplayingUser{
            guard let opponentRun = landingPadOpponentRun else {return}
            selectedRun = opponentRun
        }
        usernameLabel.text = selectedRun.user?.name ?? ""
        dateLabel.text = Converter.formatDate(date: selectedRun.date)
        timeLabel.text = "  Time: \(Converter.formatTime(seconds: Int(selectedRun.totalTime)))"
        elevationGainedLabel.text = "  ElevationGained: \(Converter.measureMentFormatter(distance: Measurement(value: selectedRun.elevationGained, unit: UnitLength.feet)) )"
        averagePaceLabel.text = "  AveragePace: \(Converter.paceFormatter(distance: Measurement(value: selectedRun.distance, unit: UnitLength.feet), seconds: Int(selectedRun.totalTime), outputUnit: UnitSpeed.minutesPerMile))"
        caloriesLabel.text = "  CaloriesBurned: \(selectedRun.calories)"
        timePointsLabel.text = "\(selectedRun.timePoints)"
        elevationPointsLabel.text = "\(selectedRun.elevationPoints)"
        distanceLabel.text = "  Distance:  \(Converter.measureMentFormatter(distance: Measurement(value: selectedRun.distance, unit: UnitLength.miles)))"
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
