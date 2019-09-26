//
//  GoOnARunViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

import CoreLocation

class GoOnARunViewController: UIViewController {
    
    
    //MARK: -Outlets
    
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var elevationLabel: UILabel!
    
    
    ///vars and lets for tracking a run
    
    let locationManager = LocationManager.shared
    
    var run: Run?
    
    var seconds = 0
    
    var isRunning: Bool = false

    var timer: Timer?
    
    var distance = Measurement(value: 0, unit: UnitLength.feet)
    
    var elevation = Measurement(value: 0, unit: UnitLength.feet)
    
    var listOfLocations = [CLLocation]()
    
    var arrayOfPaces = [Double]()
    
    //MARK: - CHALLENGING VARIABLES
    
    var hasInternetBeenChecked:Bool = false
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stopRun()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        CloudController.shared.retrieveFriends { (_) in
            
        }
    }
    
    //MARK: - ACTIONS
    
    @IBAction func startStopButtonTapped(_ sender: Any) {
        if !Reachability.isConnectedToNetwork(){
            presentNoInternetAlert()
            return
        }
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
    
    
    
    
    
    //MARK: -Helpers
    
    func presentNoInternetAlert(){
        let alertController = UIAlertController(title: "Connection Error", message: "are you connected to the internet? RunTogether requires an internet connection so come back later when you have one!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    
    
    
    //initial start up only
    
    
    func setUpUI(){
        let labelColor: String = "SilverFox"
        let labelBorderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 35
        
        let labelArray: [UILabel] = [timeLabel, paceLabel, elevationLabel,distanceLabel]
        
        //set  background
        self.view.backgroundColor = UIColor(named: "DarkSlate")!
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: labelColor)!]
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
        startStopButton.layer.cornerRadius = cornerRadius - 10
        startStopButton.setTitle("Start", for: .normal)
    }
    //to be used to update the label text
    func updateUIText(){
        paceLabel.text = Converter.pace(distance: distance, seconds: seconds, user: nil)
        timeLabel.text = Converter.formatTime(seconds: seconds)
        distanceLabel.text = Converter.distance(distance)
        elevationLabel.text = Converter.distance(elevation)
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
    
        distance = Measurement(value: 0, unit: UnitLength.meters)
        listOfLocations.removeAll()
        updateUIText()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.addSecond()
        }
        startLocationTracking()
    }
    
    func stopRun(){
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        if !listOfLocations.isEmpty{
            presentFinishedRunAlert()
        }
    }
    
    func clearUpUI(){
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        updateUIText()
    }
    
 
    
    func saveAndShare(){
        guard let user = CloudController.shared.user else {return}
        
        CloudController.shared.addRunAndPushToCloud(with: distance, elevation: self.elevation, totalTime: Double(self.seconds), coreLocations: self.listOfLocations, completion: { (success) in
            if success{
                print("saved")
                self.run = user.runs.last
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "sendThisRun", sender: nil)
                }
            } else {
                print("error")
            }
        })
    }
    
    
    func saveTheRun(){
        
        CloudController.shared.addRunAndPushToCloud(with: distance, elevation: elevation, totalTime: Double(self.seconds), coreLocations: self.listOfLocations, completion: { (success) in
            if success{
                print("saved")
                DispatchQueue.main.async {
                    self.clearUpUI()
                }
            } else {
                print("error")
            }
        })
    }
    func presentFinishedRunAlert(){
        let alert = UIAlertController(title: "Run complete congratulations!", message: "what would you like to do with this run?", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "just save the run", style: .default) { (_) in
            self.saveTheRun()
        }
        let shareAction = UIAlertAction(title: "Save and share this run", style: .default) { (_) in
            self.saveAndShare()
        }
        let deleteAction = UIAlertAction(title: "Delete This Run", style: .destructive) { (_) in
            //TODO: - present a alert that double checks if this is really what they want
            DispatchQueue.main.async {
                self.clearUpUI()
            }
         
        }
        guard let user = CloudController.shared.user else {return}
        if !user.friends.isEmpty{
            alert.addAction(shareAction)
        }
        alert.addAction(saveAction)
        alert.addAction(deleteAction)
        self.present(alert, animated: true)
    }
    //MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendThisRun"{
            if let destination = segue.destination as? ChallengeTableViewController {
                guard let run = run else {return}
                destination.runToSend = run
                clearUpUI()
            }
        }
    }
    
    
    
    // MARK: - EXTENSIONS
    
    
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
                let changeInElevation = abs(location.altitude.distance(to: lastLocation.altitude))
                elevation = elevation + Measurement(value: changeInElevation, unit: UnitLength.feet)
            }
            listOfLocations.append(location)
        }
    }
}
