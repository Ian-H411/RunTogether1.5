//
//  ChallengeTableViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/20/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class ChallengeTableViewController: UITableViewController ,ChallengeTableViewCellDelegate{
    func cellSettingHasChanged(_ sender: ChallengeTableViewCell) {
        if !Reachability.isConnectedToNetwork(){
            presentNoInternetAlert()
        }
        guard let friend = sender.userInCell else {return}
        guard let run = runToSend else {return}
        CloudController.shared.sendARunToAfriend(run: run, friend: friend)
    }
    
    var runToSend:Run?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Challenge a friend"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let user = CloudController.shared.user else {return 0}
        
        return user.friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Challenge", for: indexPath) as? ChallengeTableViewCell else {return UITableViewCell()}
        guard let user = CloudController.shared.user else {return UITableViewCell()}
        let friend = user.friends[indexPath.row]
        cell.delegate = self
        cell.update(user: friend)

        return cell
    }
    //MARK: - HELPERS
    
    func presentNoInternetAlert(){
          let alertController = UIAlertController(title: "Connection Error", message: "are you connected to the internet? RunTogether requires an internet connection so come back later when you have one!", preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
          self.present(alertController, animated: true)
      }


}
