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
    
    @IBOutlet weak var heightTextField: UITextField!
    
    
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var weightTextField: UITextField!
    
    
    @IBOutlet weak var selectedMeasurement: UISegmentedControl!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    //MARK: - NEWDATA
    
    var height = 0
    
    var weight = 0
    
    var age = 0
    
    //ismetric is handled elsewhere
    
    //MARK: - PICKER DATA
    var isMetric:Bool{
        guard let user = CloudController.shared.user else {return false}
        return user.prefersMetric
    }
    
    var heightStylePicker:[[String]]{
        if isMetric{
            var centimeterList:[String] = []
            for i in 120...203{
                centimeterList.append("\(i)")
            }
            let centemeter = ["CM"]
            return [centimeterList, centemeter]
        } else {
            let footList = ["3","4","5","6","7","8"]
            let foot = ["Ft"]
            let inchList = ["0","1","2","3","4","5","6","7","8","9","10","11"]
            let inch = ["In"]
            return [footList,foot,inchList,inch]
        }
    }
    var weightStlyePicker:[[String]]{
        if isMetric{
            var kilogramList:[String] = []
            for i in 40...130{
                kilogramList.append("\(i)")
            }
            return [kilogramList,["Kg"]]
            
        } else {
            var poundList:[String] = []
            for i in 90...285{
                poundList.append("\(i)")
            }
            return [poundList,["Lbs."]]
        }
    }
    var ageStylePicker:[[String]]{
        var ages:[String] = []
        for i in 16...80{
            ages.append("\(i)")
        }
        return [ages,["Years Old"]]
    }
    
    var selectedPickerStyle:[[String]]{
        if heightTextField.isSelected{
            return heightStylePicker
        } else if weightTextField.isSelected{
            return weightStlyePicker
        } else if ageTextField.isSelected{
            return ageStylePicker
        } else {
            return [["IF you can read this then we have a problem"]]
        }
    }
    
    var selectedTextField:UITextField?{
        if heightTextField.isSelected{
            return heightTextField
        } else if weightTextField.isSelected{
            return weightTextField
        } else if ageTextField.isSelected{
            return ageTextField
        } else {
            return nil
        }
    }
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUP()
    }
    
    
    
    //MARK: - HELPERS
    
    func initialSetUP(){
        
        
    }
    
    
    
    //MARK: - ACTIONS
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    @IBAction func selectedMeasurementController(_ sender: Any) {
        guard let user = CloudController.shared.user else {return}
        if isMetric{
            user.prefersMetric = false
        } else {
            user.prefersMetric = true
        }
    }
    
    
}
//MARK: - EXTENSIONS

extension ProfileDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        selectedPickerStyle.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectedPickerStyle[component].count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectedPickerStyle[component][row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var returnString:[String] = []
        for i in 0...selectedPickerStyle.count - 1 {
            returnString.append(selectedPickerStyle[i][pickerView.selectedRow(inComponent: i)])
            returnString.append(" ")
        }
        let finalstring = returnString.joined()
        guard let textfield = selectedTextField else {return}
    }
    
}
