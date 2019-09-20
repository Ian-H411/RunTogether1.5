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
        guard let friendList = CloudController.shared.user?.friends else {return 0}
        if isInSearchMode{
        }
        if isInSearchMode{
            return results.count
        }
        return friendList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? FriendTableViewCell else {return UITableViewCell()}
        cell.delegate = self
        cell.isASearchResult = isInSearchMode
        if isInSearchMode{
            let user = results[indexPath.row]
        cell.update(user: user)
        } else {
            guard let user = CloudController.shared.user else {return UITableViewCell()}
            let friend = user.friends[indexPath.row]
            cell.update(user: friend)
        }
        // Configure the cell...

        return cell
    }


    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    
    //MARK: - ACTIONS
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
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
    
    func updateUI(){
        
        if !isInSearchMode{

            tableView.reloadData()
        } else {

            tableView.reloadData()
        }
    }
    

}
