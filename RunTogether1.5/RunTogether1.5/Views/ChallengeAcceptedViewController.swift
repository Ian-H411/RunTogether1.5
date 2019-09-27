//
//  ChallengeAcceptedViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/23/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
import CoreLocation
class ChallengeAcceptedViewController: UIViewController {
    //MARK: -OUTLETS
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var elevationGained: UILabel!
    
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var timeToBeatLabel: UILabel!
    
    @IBOutlet weak var challengerLabel: UILabel!
    
    @IBOutlet weak var startStopButton: UIButton!
    
    
    //MARK: - CORELOCATION VARIABLES
    let locationManager = LocationManager.shared
    
    var run: Run?
    
    var opponentRun:Run?
    
    var distanceGoal = Measurement(value: 0, unit: UnitLength.feet)
    
    var hasPassedDistance:Bool{
        if distanceGoal < distance{
            return true
        } else {
            return false
        }
    }
    
    var seconds = 0
    
    var isRunning:Bool = false
    
    var calories:Int = 0
    
    var timer: Timer?
    
    var distance = Measurement(value: 0, unit: UnitLength.feet)
    
    var elevation = Measurement(value: 0, unit: UnitLength.feet)
    
    var listOfLocations = [CLLocation]()
    
    var arrayOfPaces = [Double]()
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetUP()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if isRunning{
            stopRun()
        }
    }
    
    
    
    
    
    //MARK: - ACTIONS
    func initialUISetUP(){
        let labelColor: String = "SilverFox"
        let labelBorderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 20
        
        let labelArray: [UILabel] = [timeLabel,distanceLabel,elevationGained,paceLabel,timeToBeatLabel,challengerLabel]
        self.view.backgroundColor = UIColor(named: "DarkSlate")!
        for label in labelArray {
            //set all labels border
            label.layer.borderWidth = labelBorderWidth
            //set labels border color
            label.layer.borderColor = UIColor(named: labelColor)!.cgColor
            //set labels cornerradius
            label.layer.cornerRadius = cornerRadius
            //set text color
            label.layer.backgroundColor = UIColor(named: "DeepMatteGrey")!.cgColor
            
            
        }
        guard let run = opponentRun else {return}
        startStopButton.layer.cornerRadius = cornerRadius - 10
        startStopButton.setTitle("BEGIN", for: .normal)
        let time = Converter.formatTime(seconds: Int(run.totalTime))
        timeToBeatLabel.text = "Time to Beat:\n\(time)"
        guard let user = run.user else {return}
        var preferedMetric = UnitLength.kilometers
        if !user.prefersMetric{
            preferedMetric = UnitLength.miles
        }
        let distanceAsOpponentPreferedMeasurement = Measurement(value: run.distance, unit: preferedMetric)
        guard let owner = CloudController.shared.user else {return}
        var ownerPreference = UnitLength.kilometers
        if !owner.prefersMetric{
            ownerPreference = UnitLength.miles
        }
        let distanceToDisplay = distanceAsOpponentPreferedMeasurement.converted(to: ownerPreference)
        distanceGoal = distanceAsOpponentPreferedMeasurement.converted(to: UnitLength.feet)
        challengerLabel.text = "DistanceToRun:\n\(Converter.distance(distanceToDisplay))"
    }
    
    func updateUI(){
        let pace = Converter.pace(distance: distance, seconds: seconds, user: nil)
        let time = Converter.formatTime(seconds: seconds)
        let distanceString = Converter.distance(distance)
        let elevationString = Converter.distance(elevation)
        paceLabel.text = pace
        timeLabel.text = time
        distanceLabel.text = distanceString
        elevationGained.text = elevationString
        
        
    }
    
    
    
    
    @IBAction func startStopButtonTapped(_ sender: Any) {
        if isRunning{
            if hasPassedDistance{
                stopRun()
                isRunning = false
                startStopButton.setTitle("Start", for: .normal)
            } else {
                presentDistanceNotAchievedAlert()
                stopRun()
                isRunning = false
            }
        } else {
            startRun()
            isRunning = true
            startStopButton.setTitle("Stop", for: .normal)
        }
        
    }
    //MARK: - HELPER FUNCTIONS
    func presentDistanceNotAchievedAlert(){
        let alert = UIAlertController(title: "Not Quite there", message: "you havent met your distance goal would you like to give up for now?", preferredStyle: .alert)
        let falseStartAction = UIAlertAction(title: "False start let me try again", style: .default) { (_) in
            self.tryAgain()
            
            
        }
        let giveUpForNowAction = UIAlertAction(title: "ill try again later", style: .destructive) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(giveUpForNowAction)
        alert.addAction(falseStartAction)
        self.present(alert,animated: true)
    }
    func tryAgain(){
        isRunning = true
        startStopButton.setTitle("Stop", for: .normal)
        startRun()
    }
    func startLocationTracking(){
        //set the delegate
        locationManager.delegate = self
        //tell it what activity we are doing
        locationManager.activityType = .fitness
        //how accurate in meters the device needs to be before giving us an update
        locationManager.distanceFilter = 10
        //start the machine
        locationManager.startUpdatingLocation()
    }
    
    func addSecond(){
        seconds = seconds + 1
        updateUI()
        if hasPassedDistance{
            presentFinishedRunAlert()
            self.stopRun()
        }
    }
    
    
    
    func startRun(){
        //clear everything out and then go
        seconds = 0
        calories = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        listOfLocations.removeAll()
        updateUI()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.addSecond()
        }
        startLocationTracking()
    }
    
    func stopRun(){
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        if listOfLocations.isEmpty{
            return
        }
        if hasPassedDistance{
            presentFinishedRunAlert()
        }
    }
    
    
    
    func presentFinishedRunAlert(){
        let alert = UIAlertController(title: "Run complete congratulations!", message: "what would you like to do with this run?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete This Run", style: .destructive) { (_) in
            
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let opponentsRun = self.opponentRun else {return}
            
            CloudController.shared.completeTheChallenge(opponentsRun: opponentsRun, distance: self.distance.value, elevation: self.elevation.value, totalTime: Double(self.seconds), coreLocations: self.listOfLocations) { (success) in
                if success{
                    print("donesies")
                    DispatchQueue.main.async {
                        
                        self.navigationController? .popViewController(animated: true)
                    }
                }
            }
        }
        alert.addAction(saveAction)
        
        alert.addAction(deleteAction)
        self.present(alert, animated: true)
    }
    
    
    
}
//MARK: - EXTENSIONS

extension ChallengeAcceptedViewController: CLLocationManagerDelegate{
    //this will continually feed me new locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            //grab the time
            let timeOfLocation = location.timestamp.timeIntervalSinceNow
            guard location.horizontalAccuracy < 20 && abs(timeOfLocation) < 10 else {
                continue
            }
            if let lastLocation = listOfLocations.last{
                let changeInDistance = location.distance(from: lastLocation)
                distance = distance + Measurement(value: changeInDistance, unit: UnitLength.feet)
                let changeInElevation = location.altitude.distance(to: lastLocation.altitude)
                elevation = elevation + Measurement(value: changeInElevation, unit: UnitLength.feet)
            }
            listOfLocations.append(location)
        }
    }
}
