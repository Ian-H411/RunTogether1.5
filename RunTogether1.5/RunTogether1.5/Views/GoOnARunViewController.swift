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
