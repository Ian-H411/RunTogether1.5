//
//  RunDetailViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/20/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class RunDetailViewController: UIViewController {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var elevationGainedLabel: UILabel!
    
    @IBOutlet weak var averagePaceLabel: UILabel!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var timePointsLabel: UILabel!
    
    @IBOutlet weak var elevationPointsLabel: UILabel!
    
    @IBOutlet weak var statsSelector: UISegmentedControl!
    
    @IBOutlet weak var sendARunButton: UIButton!
    
    var isAChallenge = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialUISetUp()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    
    
    //MARK: - ACTIONS
    
    @IBAction func statsSelectorTapped(_ sender: UISegmentedControl) {
        print("HEY")
    }
    
    
    
    
    
    //MARK: - HELPERS
    
    func InitialUISetUp(){
        if isAChallenge{
            sendARunButton.isHidden = true
        } else {
            statsSelector.isHidden = true
        }
        let labelColor: String = "SilverFox"
        let labelBorderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 27
        
        let labelArray: [UILabel] = [dateLabel,usernameLabel,distanceLabel,timeLabel,elevationGainedLabel,averagePaceLabel,caloriesLabel,timePointsLabel,elevationPointsLabel]
        
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
            
            
        }
    }
    
    
    func changeStatsUpdate(){
        
    }
    
}
