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
        //step one make sure it exists
        guard let username = userNameTextField.text, !username.isEmpty,
            let weightAsString = WeightTextField.text, !weightAsString.isEmpty,
            let ageAsString = ageTextField.text, !ageAsString.isEmpty,
            let heightAsString = heightTextField.text, !heightAsString.isEmpty
            else {self.presentFillOutAllFieldsAlert(); return}
        //step 2 conform to my correct types
        guard let weight = Int(weightAsString),
            let age = Int(ageAsString),
            let height = Int(heightAsString)
            else {self.presentFillOutAllFieldsAlert(); return}
        
        CloudController.shared.createNewUserAndPushWith(name:username, height: Double(height), weight: Double(weight), age: age, gender:self.selectedGender, prefersMetric: self.isMetric) { (success) in
            if success{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toApp", sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.presentICloudErrorAlert()
                }
            }
        }
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
        let alert = UIAlertController(title: "did you fill out everything?", message: "you may have forgotten something look and try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay!", style: .default, handler: nil))
    }
    
    func presentICloudErrorAlert(){
        let alert = UIAlertController(title: "ICloud error", message: "check your internet connection, and make sure that ICloud drive is turned on then come back", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
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
