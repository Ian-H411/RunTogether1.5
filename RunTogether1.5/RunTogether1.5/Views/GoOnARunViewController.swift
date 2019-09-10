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
    
    @IBOutlet weak var CurrentRouteView: MKMapView!
    
    
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
    
    func setUpUI(){
        CurrentRouteView.layer.cornerRadius = 20.0
        
        startStopButton.layer.cornerRadius = 50
        startStopButton.backgroundColor = .clear
        startStopButton.setTitle("start", for: .normal)
        distanceLabel.layer.cornerRadius = 10
        timeLabel.layer.cornerRadius = 10
        PaceLabel.layer.cornerRadius = 10
        UITabBar.appearance().tintColor = .black
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
       //update afterwards
    }
    func startRun(){
        //clear everything out and then go
        seconds = 0
        calories = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        listOfLocations.removeAll()
        //update labels here
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.addSecond()
            //update calories
        }
        startLocationTracking()
    }
    
    func stopRun(){
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        listOfLocations.removeAll()
        //update display here
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    //TODO: - IMPLEMENT MORE PRECISE CALORIE MEASUREMENT FORMULA
    func caloriesBurnt (){
        let distanceInMiles = distance.converted(to: UnitLength.miles)
        let burnt = 100 * distanceInMiles.value
        calories = burnt
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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
