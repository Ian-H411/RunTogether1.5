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
    
    var blue  = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
    }
    
    
    
    //MARK: - ACTIONS
    
    
    
    
    
    
    //MARK: -Helpers
    
    func setUpUI(){
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        CurrentRouteView.layer.cornerRadius = 20.0
        
        startStopButton.layer.cornerRadius = 5.0
        startStopButton.backgroundColor = .clear
        startStopButton.setTitle("start", for: .normal)
        startStopButton.setTitleColor(blue, for: .normal)
        timeLabel.textColor = blue
        distanceLabel.textColor = blue
        PaceLabel.textColor = blue
        
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
