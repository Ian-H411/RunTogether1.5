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
    
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
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
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    
    
    
    
    //MARK: - ACTIONS
    func initialUISetUP(){
        let labelColor: String = "SilverFox"
        let labelBorderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 35
        
        let labelArray: [UILabel] = [timeLabel,caloriesLabel,distanceLabel,elevationGained,paceLabel,timeToBeatLabel,challengerLabel]
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
        challengerLabel.text = "Challenger:\n\(user.name)"
    }
    
    func updateUI(){
        let pace = Converter.paceFormatter(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        let time = Converter.formatTime(seconds: seconds)
        let distanceString = Converter.measureMentFormatter(distance: distance)
        let elevationString = Converter.measureMentFormatter(distance: elevation)
        caloriesLabel.text = "\(calories) CAL"
        paceLabel.text = pace
        timeLabel.text = time
        distanceLabel.text = distanceString
        elevationGained.text = elevationString
        
        
    }
    
    @IBAction func startStopButtonTapped(_ sender: Any) {
        if isRunning{
            stopRun()
            isRunning = false
            startStopButton.setTitle("Start", for: .normal)
        } else {
            startRun()
            isRunning = true
            startStopButton.setTitle("Stop", for: .normal)
        }
        
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
    }
    func caloriesBurnt (){
        calories = Int(100 * distance.converted(to: UnitLength.miles).value)
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
            self.caloriesBurnt()
        }
        startLocationTracking()
    }
    
    func stopRun(){
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        if listOfLocations.isEmpty{
            return
        }
        presentFinishedRunAlert()
    }
    
    
    func presentFinishedRunAlert(){
        let alert = UIAlertController(title: "Run complete congratulations!", message: "what would you like to do with this run?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete This Run", style: .destructive) { (_) in
            //TODO: - present a alert that double checks if this is really what they want
            
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let opponentsRun = self.opponentRun else {return}
            
            CloudController.shared.completeTheChallenge(opponentsRun: opponentsRun, distance: self.distance.value, elevation: self.elevation.value, calories: self.calories, totalTime: Double(self.seconds), coreLocations: self.listOfLocations) { (success) in
                if success{
                    print("donesies")
                }
            }
        }
        alert.addAction(saveAction)
        
        alert.addAction(deleteAction)
        self.present(alert, animated: true)
    }
    
    //MARK: - HELPER FUNCTIONS
    
}
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