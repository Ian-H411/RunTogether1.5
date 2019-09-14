//
//  GoOnARunViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GoOnARunViewController: UIViewController {
    //MARK: -Outlets
    
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var elevationLabel: UILabel!
    
    
    ///vars and lets for tracking a run
    
let locationManager = LocationManager.shared

    var run: Run?
    
    var seconds = 0
    
    var isRunning: Bool = false
    
    var calories: Int = 0
    
    var timer: Timer?
    
    var distance = Measurement(value: 0, unit: UnitLength.feet)
    
    var elevation = Measurement(value: 0, unit: UnitLength.feet)
    
    var listOfLocations = [CLLocation]()
    
    var arrayOfPaces = [Double]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
    }
    
    //MARK: - ACTIONS
    
    @IBAction func startStopButtonTapped(_ sender: Any) {
        if isRunning{
            stopRun()
            isRunning = false
        } else {
            startRun()
            isRunning = true
        }
    }
    
    
    
    
    
    //MARK: -Helpers
    
    //initial start up only
    func setUpUI(){
        
    }
    //to be used to update the label text
    func updateUIText(){
        paceLabel.text = Converter.paceFormatter(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        timeLabel.text = Converter.formatTime(seconds: seconds)
        distanceLabel.text = Converter.measureMentFormatter(distance: distance)
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
       updateUIText()
    }
    func startRun(){
        //clear everything out and then go
        seconds = 0
        calories = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        listOfLocations.removeAll()
        updateUIText()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.addSecond()
            //update calories
        }
        startLocationTracking()
    }
    
    func stopRun(){
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        presentFinishedRunAlert()
    }
    
    func clearUpUI(){
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        updateUIText()
    }

    func caloriesBurnt (){
        //TODO: - calc calories and display
    }
    func presentFinishedRunAlert(){
        let alert = UIAlertController(title: "Run complete congratulations!", message: "what would you like to do with this run?", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Save This Run", style: .default) { (_) in
            //TODO: - save the run but do not send
            DispatchQueue.main.async {
                self.clearUpUI()
            }
        }
        let deleteAction = UIAlertAction(title: "Delete This Run", style: .destructive) { (_) in
            //TODO: - present a alert that double checks if this is really what they want
            DispatchQueue.main.async {
                self.clearUpUI()
            }
        }
        let saveAndSendAction = UIAlertAction(title: "Save my run and challenge someone", style: .default) { (_) in
            //TODO: - Send them to a place where they can send this run to a friend
            DispatchQueue.main.async {
                self.clearUpUI()
            }
        }
        alert.addAction(saveAction)
        
        alert.addAction(saveAndSendAction)
        
        alert.addAction(deleteAction)
        self.present(alert, animated: true)
    }
   
     // MARK: - Navigation

    
}
extension GoOnARunViewController: CLLocationManagerDelegate{
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
