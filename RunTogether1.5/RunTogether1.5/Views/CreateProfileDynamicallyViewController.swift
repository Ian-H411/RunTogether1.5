//
//  CreateProfileDynamicallyViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/22/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class CreateProfileDynamicallyViewController: UIViewController {
    //MARK: - OUTLETS
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var measurementLabel: UILabel!
    
    @IBOutlet weak var letsGoButton: UIButton!

    
    @IBOutlet weak var answerTextField: UITextField!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    //MARK: - Variables for user profile creation
    
    var username:String = ""
    
    //inchs or centimeters depending on user choice
    var height:Int = 0
    
    var heightAsString:String = ""
    
    var age:Int = 0
    
    var weight:Int = 0
    
    var weightAsString:String = ""
    
    var gender:String = ""
    
    
    //MARK: - Variables for Navigation and Picker
    
    var step:Int = 0
    
    var isMetric = false
    
    var questions:[String] = ["Choose a Username","whats your preffered measurement System?", "Whats your Height?", "How old are you?", "Approxametly how much do you weigh?", "Whats your gender?","EverythingLook Okay?"]
    var placeHolderPrompts:[String] = ["Username", "Metric/Customary", "Height", "Age", "Weight", "Gender"]
    
    var currentQuestion:String{
        return questions[step]
    }
    var currentPlaceHolder:String{
        return placeHolderPrompts[step]
    }
    
    var userNamePicker = [["PLACEHOLDER YOU SHOULD NOT SEE THIS"]]
    
    var measurementStylePicker:[[String]] = [["Customary", "Metric"]]
    
    var heightStylePicker:[[String]]{
        if isMetric{
            var centimeterList:[String] = []
            for i in 120...203{
                centimeterList.append("\(i)")
            }
            let centemeter = ["CM"]
            return [centimeterList, centemeter]
        } else {
            let footList = ["3","4","5","6","7"]
            let foot = ["Ft"]
            let inchList = ["1","2","3","4","5","6","7","8","9","10","11","12"]
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
    
    var genderStylePicker: [[String]] = [["I Identify as a"],["\(GenderKeys.female)","\(GenderKeys.other)","\(GenderKeys.male)"]]
    
    var currentPickerData:[[String]] {
        let pickers = [userNamePicker,measurementStylePicker,heightStylePicker,ageStylePicker,weightStlyePicker,genderStylePicker]
        return pickers[step]
    }
    
    
    var toolbar:UIToolbar?
    
    var picker: UIPickerView?
    
    
    //MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialSetUP()
        createPicker()
        createToolBar()
        
    }
    
    //MARK: - ACTIONS
    
  
    
    
    @IBAction func letsRunButtonTapped(_ sender: Any) {
    }
    
    
    
    
    //MARK: - HELPERS
    
    func InitialSetUP(){
        answerTextField.text = ""
        let labelArray: [UILabel] = [usernameLabel,heightLabel,ageLabel,weightLabel,genderLabel,measurementLabel]
        //first make everything disappear
        for label in labelArray{
            label.isHidden = true
        }
        letsGoButton.isHidden = true
        questionLabel.text = questions[step]
        
    }
    
    func createPicker(){
        let responsePicker = UIPickerView()
        responsePicker.delegate = self
        picker = responsePicker
        if step > 0 {
            answerTextField.inputView = responsePicker
        }
    }
    
    func createToolBar(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Next Question", style: .plain, target: self, action: #selector(CreateProfileDynamicallyViewController.toolbarButtonTapped))
        let backButton = UIBarButtonItem(title: "GoBack", style: .plain, target: self, action: #selector(CreateProfileDynamicallyViewController.backButtonTapped))
        toolBar.setItems([backButton,button], animated: false)
        toolBar.isUserInteractionEnabled = true
        answerTextField.inputAccessoryView = toolBar
        toolbar = toolBar
        
    }
    @objc func backButtonTapped(){
        goBackAstep()
        refreshUI()
    }
    
    @objc func toolbarButtonTapped(){
        addToStep()
        refreshUI()
        view.reloadInputViews()
    }
    
    func addToStep(){
        if step < 6 {
            step = step + 1
        }
    }
    
    func goBackAstep(){
        if step > 1{
            step = step - 1
        }
    }
    
    func refreshUI(){
        answerTextField.text = ""
        if step == 1{
        guard let picker = picker else {return}
        answerTextField.inputView = picker
            questionLabel.text = questions[step]
            view.reloadInputViews()
            view.endEditing(true)
    
        } else if step == 6{
            //congrats review everything and move on
            view.endEditing(true)
            unhideLabels()
            usernameLabel.text = username
            heightLabel.text = heightAsString
            weightLabel.text = weightAsString
            ageLabel.text = "\(age) years old"
            genderLabel.text = gender
            if isMetric{
                measurementLabel.text = "Metric"
            } else {
                measurementLabel.text = "Customary"
            }
        } else {
            questionLabel.text = questions[step]
            view.endEditing(true)
            
        }
        
    }
    
    func unhideLabels(){
        let labelArray: [UILabel] = [usernameLabel,heightLabel,ageLabel,weightLabel,genderLabel,measurementLabel]
        //first make everything disappear
        for label in labelArray{
            label.isHidden = false
        }
        letsGoButton.isHidden = false
        
    }
    
    func rehideLabels(){
        let labelArray: [UILabel] = [usernameLabel,heightLabel,ageLabel,weightLabel,genderLabel,measurementLabel]
        //first make everything disappear
        for label in labelArray{
            label.isHidden = true
        }
        letsGoButton.isHidden = true
    }
    
}
//MARK: - EXTENSIONS

extension CreateProfileDynamicallyViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return currentPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerData[component].count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerData[component][row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var returnString:[String] = []
        for i in 0...currentPickerData.count - 1 {
            returnString.append(currentPickerData[i][pickerView.selectedRow(inComponent: i)])
            returnString.append(" ")
        }
        let finalstring = returnString.joined()
        answerTextField.text = finalstring
    }
    
    
}
