//
//  LoadingViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/16/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var loadingImage: UIImageView!
    
    @IBOutlet weak var warmingUpLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isICloudContainerAvailable(){
           updateUI()
           if Reachability.isConnectedToNetwork(){
           retrieveUser()
           } else {
               warmingUpLabel.text = "Check your internet then \n try again"
           }
           } else{
               warmingUpLabel.text = "Sign into icloud,\n and check that your icloud drive is turned on.  then afterwards try again."
               warmingUpLabel.font = UIFont(name: "System Bold", size: 23)
           }
    }

    func isICloudContainerAvailable()->Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        }
        else {
            return false
        }
    }
    
    func updateUI(){
        DispatchQueue.main.async {
            
            self.loadingImage.rotate360Degrees()
        }
    }
    func retrieveUser(){
        CloudController.shared.performStartUpFetchs { (success) in
            DispatchQueue.main.async {
            if success{
                self.performSegue(withIdentifier: "returningUser", sender: nil)
            } else {
            self.performSegue(withIdentifier: "newUser", sender: nil)
                }
            }
        }
        
    }
    func presentNotConnectedToIcloudAlert(){
        let alertController = UIAlertController(title: "ICloud Error", message: "it looks like your not signed into icloud, or your icloud drive may be turned off.  check that and then come back later", preferredStyle: .alert)
        let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayButton)
        self.present(alertController,animated: true)
    }
    
    
}
    extension UIView {
        func rotate360Degrees(duration: CFTimeInterval = 20.0, completionDelegate: AnyObject? = nil) {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 2.0)
            rotateAnimation.duration = duration
            
            if let delegate: AnyObject = completionDelegate {
                rotateAnimation.delegate = (delegate as! CAAnimationDelegate)
                
            }
            self.layer.add(rotateAnimation, forKey: nil)
        }
}
