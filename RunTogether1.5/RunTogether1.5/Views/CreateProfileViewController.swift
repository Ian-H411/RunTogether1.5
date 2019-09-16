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
    
    @IBOutlet weak var createAProfileLabel: UILabel!
    
    @IBOutlet weak var DesiredMeasurementSystemControl: UISegmentedControl!
    
    @IBOutlet weak var createProfileButton: UIButton!
    
    
    
    //MARK: - VARIABLES
    var selectedGender: String = GenderKeys.female
    
    var isMetric:Bool = true
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    //MARK: - ACTIONS
    
    @IBAction func CreateProfileButtonTapped(_ sender: Any) {
        guard let username = userNameTextField.text, !username.isEmpty,
        let weight = WeightTextField.text, !weight.isEmpty,
        let age = ageTextField.text, !age.isEmpty,
        let height = heightTextField.text, !height.isEmpty
            else {presentFillOutAllFieldsAlert();return}
        
    }
    
    @IBAction func selectedGenderControlTapped(_ sender: UISegmentedControl) {
        if sender.tag == 0{
            selectedGender = GenderKeys.female
        } else if sender.tag == 1{
            selectedGender = GenderKeys.other
        } else {
            selectedGender = GenderKeys.male
        }
    }
    
    
    @IBAction func selectedMeasurementStyleControlTapped(_ sender: UISegmentedControl) {
        if sender.tag == 1{
            isMetric = false
        } else {
            isMetric = true
        }
    }
    
    
    //MARK: - HELPER FUNCTIONS
    func presentFillOutAllFieldsAlert(){
    }
    
    func setUpUI(){
        setNeedsStatusBarAppearanceUpdate()
        let labelColor: String = "SilverFox"
        let labelBorderWidth: CGFloat = 3
        let labelArray: [UITextField] = [userNameTextField, WeightTextField,heightTextField,ageTextField]
        
        //set  background
        self.view.backgroundColor = UIColor(named: "DarkSlate")!
        createAProfileLabel.layer.borderWidth = labelBorderWidth
        createAProfileLabel.layer.borderColor = UIColor(named: "areYaYellow")!.cgColor
        createAProfileLabel.layer.cornerRadius = 15
       createAProfileLabel.layer.masksToBounds = true
        
        
        
        createProfileButton.layer.masksToBounds = true
        createProfileButton.layer.borderWidth = 2
        createProfileButton.layer.borderColor = UIColor(named: "areYaYellow")!.cgColor
        createProfileButton.layer.cornerRadius = 15
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: labelColor)!]
        for label in labelArray {
            //set all labels border
            label.layer.borderWidth = labelBorderWidth
            //set labels border color
            label.layer.borderColor = UIColor(named: "areYaYellow")!.cgColor
            label.layer.cornerRadius = 15
            label.layer.masksToBounds = true
            //set text color
            label.layer.backgroundColor = UIColor(named: labelColor)!.cgColor
            
            
        }
  
    }
    
    //MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
}
