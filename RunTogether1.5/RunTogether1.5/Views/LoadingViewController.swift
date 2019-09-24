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
        
        updateUI()
        if Reachability.isConnectedToNetwork(){
        retrieveUser()
        } else {
            warmingUpLabel.text = "Check your internet then \n try again"
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
    func notConnectedToInternetAlert(){
        let alertController = UIAlertController(title: "Connection Error", message: "are you connected to the internet? RunTogether requires an internet connection", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        self.present(alertController, animated: true)
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
