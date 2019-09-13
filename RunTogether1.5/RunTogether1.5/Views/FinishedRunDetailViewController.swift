//
//  FinishedRunDetailViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/13/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
import CoreLocation
class FinishedRunDetailViewController: UIViewController {
   //MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var averagePaceLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var elevationGainedLabel: UILabel!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var deleteRunButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var saveAndSendButton: UIButton!
    
    //MARK: - LandingPads
    
    var seconds: Int?
    
    var listOfLocations: [CLLocation]?
    
    var averagePace: Double?
    
    var distance: Double?
    
    var elevationGained: Int?
    
    var calories: Int?
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    
    
    
    //MARK: - Helper Functions
    
    
    
    
    
    
    //MARK: - Actions
    
    @IBAction func deleteThisRunButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveOnlyButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveAndSendButtonTapped(_ sender: Any) {
    }
    
    
}
