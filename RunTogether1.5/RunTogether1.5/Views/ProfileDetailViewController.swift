//
//  ProfileDetailViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/23/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class ProfileDetailViewController: UIViewController {
    //MARK: - OUTLETS
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var totalPointsLabel: UILabel!
    
    @IBOutlet weak var numberOfRunsLabel: UILabel!
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
    @IBOutlet weak var privacyPolicyLink: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        
    }
    
    //MARK: - ACTIONS
    
    @IBAction func SendToPrivacyPolicyLink(_ sender: Any) {
        if !Reachability.isConnectedToNetwork(){
            presentNoInternetAlert()
            return
        }
        if let url = URL(string: "https://sites.google.com/view/runagainstfriends") {
            UIApplication.shared.open(url)
        }
    }
    
    
    @IBAction func deleteProfileButtonTapped(_ sender: Any) {
        if !Reachability.isConnectedToNetwork(){
            presentNoInternetAlert()
            return
        }
        presentDeleteProfileAlert()
    }
    
    
    
    //MARK: - HELPERS
    
    func initialSetUp(){
        guard let user = CloudController.shared.user else {return}
        usernameLabel.text = user.name
        totalPointsLabel.text = "\(retrieveUserPoints()) Total Points"
        let distance = Converter.distance(retrieveDistance())
        totalDistanceLabel.text = "Total distance: \(distance)"
        numberOfRunsLabel.text = "Run Count: \(user.runs.count)"
        
        let labelCarousel:[UILabel] = [usernameLabel,totalDistanceLabel,numberOfRunsLabel,totalPointsLabel]
        for label in labelCarousel{
            label.layer.borderColor = UIColor(named: "SilverFox")!.cgColor
            label.layer.borderWidth = 4
            label.layer.cornerRadius = 10
        }
    }
    func retrieveUserPoints() -> Int{
        guard let user = CloudController.shared.user else {return 0 }
        var points = 0
        for run in user.runs{
            points = points + run.totalPoints
        }
        return points
    }
    
    func retrieveDistance() ->Measurement<UnitLength>{
        guard let user = CloudController.shared.user else {return Measurement(value: 0, unit: UnitLength.miles)}
        var distance = Measurement(value: 0, unit: UnitLength.miles)
        for run in user.runs{
            distance = distance + run.distanceInMeasurement
        }
        return distance
    }
    
    func presentNoInternetAlert(){
        let alertcontroller = UIAlertController(title: "Internet Connection Error", message: "Looks like your not connected to the internet try again later", preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        self.present(alertcontroller, animated:  true)
    }
    
    func presentDeleteProfileAlert(){
        let alertController = UIAlertController(title: "DELETE PROFILE", message: "THIS WILL REMOVE YOUR ENITRE PROFILE AND CANNOT BE UNDONE", preferredStyle: .alert)
        let yesDeleteAction = UIAlertAction(title: "Yes delete my profile", style: .destructive) { (_) in
            CloudController.shared.deleteUser()
            DispatchQueue.main.async {
                
                self.tabBarController?.dismiss(animated: true, completion: nil)
            }
        }
        let noAction = UIAlertAction(title: "Keep my profile", style: .default, handler: nil)
        alertController.addAction(yesDeleteAction)
        alertController.addAction(noAction)
        self.present(alertController,animated: true)
    }
}
