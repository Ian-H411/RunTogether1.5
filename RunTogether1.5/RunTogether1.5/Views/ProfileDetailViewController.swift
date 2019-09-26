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
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var totalPointsLabel: UILabel!
    
    @IBOutlet weak var numberOfRunsLabel: UILabel!
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    //MARK: - ACTIONS
    
    @IBAction func SendToPrivacyPolicyLink(_ sender: Any) {
        if let url = URL(string: "https://sites.google.com/view/runagainstfriends") {
            UIApplication.shared.open(url)
        }
    }
    
    
    @IBAction func deleteProfileButtonTapped(_ sender: Any) {
        presentDeleteProfileAlert()
    }
    
    
    
    //MARK: - HELPERS
    
    func initialSetUp(){
        guard let user = CloudController.shared.user else {return}
        usernameLabel.text = user.name
    }
    
    func presentDeleteProfileAlert(){
        let alertController = UIAlertController(title: "DELETE PROFILE", message: "THIS WILL REMOVE YOUR ENITRE PROFILE AND CANNOT BE UNDONE", preferredStyle: .alert)
        let yesDeleteAction = UIAlertAction(title: "Yes delete my profile", style: .destructive) { (_) in
            CloudController.shared.deleteUser()
            DispatchQueue.main.async {
                
                self.tabBarController?.dismiss(animated: true, completion: nil)
            }
        }
        let noAction = UIAlertAction(title: "Keep my profile", style: .default, handler: nil)
        alertController.addAction(yesDeleteAction)
        alertController.addAction(noAction)
        self.present(alertController,animated: true)
    }
}
