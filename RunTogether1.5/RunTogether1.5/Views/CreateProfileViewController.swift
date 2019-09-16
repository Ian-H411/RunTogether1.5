//
//  CreateProfileViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/16/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController {
    //MARK: - Outlets
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var WeightTextField: UITextField!
    
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    
    @IBOutlet weak var DesiredMeasurementSystemControl: UISegmentedControl!
    
    @IBOutlet weak var createProfileButton: UIButton!
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    //MARK: - ACTIONS
    
    @IBAction func CreateProfileButtonTapped(_ sender: Any) {
    }
    
    @IBAction func GenderControlTapped(_ sender: Any) {
    }
    
    @IBAction func measurementControlTapped(_ sender: Any) {
    }
    
    //MARK: - HELPER FUNCTIONS
    
    
    func setUpUI(){
        setNeedsStatusBarAppearanceUpdate()
        let labelColor: String = "SilverFox"
        let labelBorderWidth: CGFloat = 1
        let labelArray: [UITextField] = [userNameTextField, WeightTextField,heightTextField,ageTextField]
        
        //set  background
        self.view.backgroundColor = UIColor(named: "DarkSlate")!
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: labelColor)!]
        for label in labelArray {
            //set all labels border
            label.layer.borderWidth = labelBorderWidth
            //set labels border color
            label.layer.borderColor = UIColor(named: labelColor)!.cgColor
            //set labels cornerradius
            //set text color
            label.layer.backgroundColor = UIColor(named: "DeepMatteGrey")!.cgColor
            
            
        }
    }
    
    
    
    
}
