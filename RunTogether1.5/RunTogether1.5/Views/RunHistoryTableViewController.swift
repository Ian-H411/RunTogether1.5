//
//  RunHistoryTableViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/15/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class RunHistoryTableViewController: UITableViewController {

    //MARK: - OUTLETS
    
    
    @IBOutlet weak var RacesWonLabel: UILabel!
    
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RunCloudController.shared.user?.runs.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "runCell", for: indexPath)

        // Configure the cell...

        return cell
    }
  
    
    
    
    
    
    //MARK: - HELPER FUNCTIONS
    
    func setUpUI(){
        setNeedsStatusBarAppearanceUpdate()
        let labelColor: String = "SilverFox"
        let labelBorderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 10
        
        
        let labelArray: [UILabel] = [RacesWonLabel, totalDistanceLabel]
        
        //set  background
        self.view.backgroundColor = UIColor(named: "DarkSlate")!
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: labelColor)!]
        for label in labelArray {
            //set all labels border
            label.layer.borderWidth = labelBorderWidth
            //set labels border color
            label.layer.borderColor = UIColor(named: labelColor)!.cgColor
            //set labels cornerradius
            label.layer.cornerRadius = cornerRadius
            //set text color
            label.layer.backgroundColor = UIColor(named: "DeepMatteGrey")!.cgColor
            
            
        }
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}