//
//  FriendsTableViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/19/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController, UISearchBarDelegate, FriendTableViewCellDelegate {
    func cellSettingHasChanged(_ sender: FriendTableViewCell) {
        guard let newFriend = sender.userInCell else {return}
        
        CloudController.shared.addFriend(friend: newFriend) { (success) in
            if success{
                print("made a friend")
            }
        }
    }
    
    
    //MARK: - outlets
    
    
    @IBOutlet weak var findNewFriendsSearchBar: UISearchBar!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var isInSearchMode: Bool = false
    
    
    
    var results:[User] = []
    
    var dataSource:[User] {
        if isInSearchMode{
            return results
        } else {
            guard let user = CloudController.shared.user else {return []}
            return user.friends
        }
    }
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        findNewFriendsSearchBar.delegate = self
        CloudController.shared.retrieveFriends { (success) in
            if success{
                DispatchQueue.main.async {
                self.tableView.reloadData()
                }
            }
        }
        
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isInSearchMode{
            return "Searching for new friends...."
        } else {
            return "My Friends"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? FriendTableViewCell else {return UITableViewCell()}
        cell.delegate = self
        cell.isASearchResult = isInSearchMode
        let user = dataSource[indexPath.row]
        cell.update(user: user)
        
        // Configure the cell...
        
        return cell
    }
    
   
    
    
    //MARK: - ACTIONS
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !Reachability.isConnectedToNetwork(){
            presentNoInternetAlert()
        }
        isInSearchMode = true
        tableView.reloadData()
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        isInSearchMode = false
        findNewFriendsSearchBar.text = ""
        tableView.reloadData()
        findNewFriendsSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let term = searchBar.text, !term.isEmpty else {return}
        CloudController.shared.searchUsers(searchTerm: term ) { (users) in
            self.results = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    //MARK: - HELPER FUNCTIONS
    
    func presentNoInternetAlert(){
          let alertController = UIAlertController(title: "Connection Error", message: "are you connected to the internet? RunTogether requires an internet connection so come back later when you have one!", preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
          self.present(alertController, animated: true)
      }
    
    func updateUI(){
        
        if !isInSearchMode{
            
            tableView.reloadData()
        } else {
            
            tableView.reloadData()
        }
    }
    
    
}
