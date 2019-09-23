//
//  CreateProfileDynamicallyViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/22/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
import CloudKit

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
    
    @IBOutlet weak var gobackButton: UIButton!
    
    
    
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
    
    var textFieldstuff:[String] = ["","Customary ","3 Ft 0 In ","16 Years Old ","93 Lbs. ", "Sex Female "]
    
    var questions:[String] = ["Choose a Username","preffered measurement System?", "Whats your Height?", "How old are you?", "Approxametly how much do you weigh?", "Whats your sex?","Everything look okay?"]
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
    
    var genderStylePicker: [[String]] = [["Sex"],["\(GenderKeys.female)","\(GenderKeys.other)","\(GenderKeys.male)"]]
    
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
    override func viewWillAppear(_ animated: Bool) {
        answerTextField.becomeFirstResponder()
    }
    
    //MARK: - ACTIONS
    
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
       let labelCarousel:[UILabel] = [usernameLabel,measurementLabel, heightLabel,ageLabel,weightLabel,genderLabel]
       labelCarousel[step - 1].isHidden = true
       goBackAstep()
       refreshUI()
        answerTextField.becomeFirstResponder()
        gobackButton.isHidden = true
    }
    
    
    
    
    
    @IBAction func letsRunButtonTapped(_ sender: Any) {
        if !username.isEmpty && height != 0 && weight != 0 && age != 0 && !gender.isEmpty{
            
            CloudController.shared.createNewUserAndPushWith(name: self.username, height: Double(self.height), weight: Double(self.weight), age: self.age, gender: self.gender, prefersMetric: self.isMetric) { (success) in
                if success{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toApp", sender: nil)
                    }
                }
                
            }
        }
        
    }
    
    
    
    
    //MARK: - HELPERS
    
    func InitialSetUP(){
        answerTextField.becomeFirstResponder()
        answerTextField.text = ""
        let labelArray: [UILabel] = [usernameLabel,heightLabel,ageLabel,weightLabel,genderLabel,measurementLabel]
        //first make everything disappear
        for label in labelArray{
            label.isHidden = true
        }
        letsGoButton.isHidden = true
        questionLabel.text = questions[step]
        gobackButton.isHidden = true
        
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
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([backButton, flexibleSpace ,button], animated: false)
        toolBar.isUserInteractionEnabled = true
        answerTextField.inputAccessoryView = toolBar
        toolbar = toolBar
        
    }
    @objc func backButtonTapped(){
        let labelCarousel:[UILabel] = [usernameLabel,measurementLabel, heightLabel,ageLabel,weightLabel,genderLabel]
        labelCarousel[step - 1].isHidden = true
        goBackAstep()
        
        refreshUI()
        if step == 0{
            answerTextField.resignFirstResponder()
            answerTextField.inputView = nil
            answerTextField.becomeFirstResponder()
        }
    }
    
    @objc func toolbarButtonTapped(){
        guard let answer = answerTextField.text else {return}
        if step == 0{
            CloudController.shared.checkIfUserExists(username: answer) { (success) in
                if !success{
                    DispatchQueue.main.async {
                        self.presentUserExistsAlert()
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        self.addToStep()
                        self.refreshUI()
                        self.view.reloadInputViews()
                    }
                }
            }
        } else
        if !answer.isEmpty{
            addToStep()
            refreshUI()
            view.reloadInputViews()
        }
    }
    
    func addToStep(){
        if step < 6 {
            step = step + 1
        }
    }
    
    func goBackAstep(){
        if step >= 1{
            step = step - 1
        }
    }
    
    func refreshUI(){
        
        
        if step == 1{
            guard let usernamerecieved = answerTextField.text else {return}
            if username.count == 0{
            username = usernamerecieved
            }
            usernameLabel.isHidden = false
            answerTextField.text = textFieldstuff[step]
            guard let picker = picker else {return}
            answerTextField.inputView = picker
            view.endEditing(true)
            picker.reloadAllComponents()
            answerTextField.becomeFirstResponder()
            
        } else if step == 6{
            answerTextField.text = ""
            //congrats review everything and move on
            view.endEditing(true)
            letsGoButton.isHidden = false
            gobackButton.isHidden = false
            gobackButton.backgroundColor = UIColor(named: "DarkSlate")!
            letsGoButton.backgroundColor = UIColor(named: "DarkSlate")!
            letsGoButton.layer.cornerRadius = 20
            gobackButton.layer.cornerRadius = 20
            letsGoButton.layer.borderColor = UIColor(named: "SilverFox")!.cgColor
            gobackButton.layer.borderColor = UIColor(named: "SilverFox")!.cgColor
            letsGoButton.layer.borderWidth = 3
            gobackButton.layer.borderWidth = 3
            
        } else {
            
            questionLabel.text = questions[step]
            guard let picker = picker else {return}
            picker.reloadAllComponents()
            
            
        }
        let labelCarousel:[UILabel] = [usernameLabel,measurementLabel, heightLabel,ageLabel,weightLabel,genderLabel]
        if step >= 1 {
            if step == 1 {
                usernameLabel.text = "Username: \(username)"
            }
            
            let label = labelCarousel[step - 1]
            label.isHidden = false
            label.layer.shadowColor = UIColor(named: "areYaYellow")!.cgColor
            label.layer.shadowRadius = 10
            label.layer.shadowOffset = .zero
            label.layer.shadowOpacity = 0.5
            label.layer.cornerRadius = 20
            label.layer.borderColor = UIColor(named: "SilverFox")!.cgColor
            label.layer.borderWidth = 5
            
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
        let labelArray: [UILabel] = [usernameLabel,measurementLabel, heightLabel,ageLabel,weightLabel,genderLabel]
        //first make everything disappear
        for label in labelArray{
            label.isHidden = true
        }
        letsGoButton.isHidden = true
    }
    
    func presentUserExistsAlert(){
        let alertcontroller = UIAlertController(title: "Sorry", message: "Sorry That UserName is already taken try another!", preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertcontroller.addAction(alertButton)
        self.present(alertcontroller, animated: true)
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
        if step == 1{
            print(finalstring)
            if finalstring == "Metric "{
                print("SelectedMetric")
                isMetric = true
                measurementLabel.text = "  Metric"
            } else {
                isMetric = false
                measurementLabel.text = "  Customary"
            }
        } else if step == 2 {
            heightAsString = finalstring
            heightLabel.text = "  Height: \(finalstring)"
            if !isMetric{
                print("height in customary")
                print(returnString)
                guard let feet = Int(returnString[0]) else {return}
                guard let inches = Int(returnString[4]) else {return}
                height = (feet * 12) + inches
                print("\(height) inches")
            } else {
                print("height in CM")
                print(returnString)
                guard let centimeters = Int(returnString[0]) else {return}
                height = centimeters
            }
        } else if step == 3{
            ageLabel.text = "  \(finalstring)"
            guard let ageFound = Int(returnString[0]) else {return}
            print(ageFound)
            age = ageFound
        } else if step == 4 {
            weightLabel.text = "  \(finalstring)"
            guard let weightFound = Int(returnString[0]) else {return}
            weight = weightFound
        } else if step == 5 {
            print(returnString)
            genderLabel.text = "  \(finalstring)"
            if returnString[2] == "\(GenderKeys.male)"{
                gender = GenderKeys.male
            } else if returnString[2] == "\(GenderKeys.female)" {
                gender = GenderKeys.female
            } else {
                gender = GenderKeys.other
            }
        }
    }
    
    
}
