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
    
    @IBOutlet weak var PaceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
   
    
    
    ///vars and lets for tracking a run
    
let locationManager = LocationManager.shared

    var run: Run?
    
    var seconds = 0
    
    var isRunning: Bool = false
    
    var calories: Double = 0.0
    
    var timer: Timer?
    
    var distance = Measurement(value: 0, unit: UnitLength.feet)
    
    var listOfLocations = [CLLocation]()
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
        startStopButton.layer.cornerRadius = 50
        startStopButton.backgroundColor = .clear
        startStopButton.setTitle("start", for: .normal)
        distanceLabel.layer.cornerRadius = 10
        timeLabel.layer.cornerRadius = 10
        PaceLabel.layer.cornerRadius = 10
        UITabBar.appearance().tintColor = .black
    }
    //to be used to update the label text
    func updateUIText(){
        PaceLabel.text = Converter.paceFormatter(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
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
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
//        listOfLocations.removeAll()
        updateUIText()
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        self.performSegue(withIdentifier: "finished", sender: nil)
    }
    //TODO: - IMPLEMENT MORE PRECISE CALORIE MEASUREMENT FORMULA
    func caloriesBurnt (){
        let distanceInMiles = distance.converted(to: UnitLength.miles)
        let burnt = 100 * distanceInMiles.value
        calories = burnt
    }
    
   
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finished" {
            if let finishedVC = segue.destination as? FinishedRunViewController {
                finishedVC.listOfLocations = listOfLocations
            }
        }
     }

    
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
            }
            listOfLocations.append(location)
        }
    }
}
