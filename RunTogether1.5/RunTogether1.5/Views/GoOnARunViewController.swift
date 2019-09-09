//
//  GoOnARunViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
import MapKit

class GoOnARunViewController: UIViewController {
    //MARK: -Outlets
    
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBOutlet weak var PaceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var CurrentRouteView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
    }
    
    
    
    //MARK: - ACTIONS
    
    
    
    
    
    
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
