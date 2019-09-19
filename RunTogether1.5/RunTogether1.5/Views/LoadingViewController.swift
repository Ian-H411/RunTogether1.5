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
        retrieveUser()
        
    }
    
    func updateUI(){
        DispatchQueue.main.async {
            
            self.loadingImage.rotate360Degrees()
        }
    }
    func retrieveUser(){
        CloudController.shared.performStartUpFetchs { (success) in
            if success{
                self.performSegue(withIdentifier: "returningUser", sender: nil)
            } else {
                self.performSegue(withIdentifier: "newUser", sender: nil)
            }
        }
        
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
