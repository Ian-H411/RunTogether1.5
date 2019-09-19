//
//  FriendsTableViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/19/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController, UISearchBarDelegate {

    //MARK: - outlets
    
    @IBOutlet weak var friendSearchControl: UISegmentedControl!
    
    @IBOutlet weak var findNewFriendsSearchBar: UISearchBar!
    
    
    
    var isInSearchMode: Bool = false
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)

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
    
    //changes to search mode or back and then
    @IBAction func friendSearchControlTapped(_ sender: UISegmentedControl) {
        if sender.tag == 0 {
            isInSearchMode = true
            updateUI()
        } else if sender.tag == 1{
            isInSearchMode = false
            updateUI()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - HELPER FUNCTIONS
    
    func updateUI(){
        if !isInSearchMode{
            findNewFriendsSearchBar.isHidden = true
            tableView.reloadData()
        } else {
            findNewFriendsSearchBar.isHidden = false
            tableView.reloadData()
        }
    }
    

}
extension UISearchBar {

}
