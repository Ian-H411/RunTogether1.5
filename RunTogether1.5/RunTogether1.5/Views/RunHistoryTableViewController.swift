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
    
    
    var displayInbox: Bool = false
    
    var dataSource: [Run]{
        guard let user = CloudController.shared.user else {return []}
        if displayInbox{
            return user.runsRecieved
        } else {
       
            return user.runs
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        CloudController.shared.retrieveRuns { (success) in
            if success{
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.setUpTotalDistance()
                }
            }
        }
        //TODO: - ASK FOR HELP WITH THIS ERROR
//        CloudController.shared.retrieveRunsToDO { (_) in
//
//        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "runCell", for: indexPath) as? RunTableViewCell else {return UITableViewCell()}
        let run = dataSource[indexPath.row]
        cell.update(run: run)

        return cell
    }
  
    
    
    
    
    
    //MARK: - HELPER FUNCTIONS
    
    func setUpUI(){
        guard let user = CloudController.shared.user else {return}
        RacesWonLabel.text = "RACES WON: \(user.racesWon)"
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
    
    
    func setUpTotalDistance(){
        var distance = Measurement(value: 0.0, unit: UnitLength.miles)
        guard let user = CloudController.shared.user else {return}
        for run in user.runs{
            distance = distance + Measurement(value: run.distance, unit: UnitLength.miles)
        }
        let formattedDistance = Converter.measureMentFormatter(distance: distance)
        totalDistanceLabel.text = "Total Distance Ran: \(formattedDistance)"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailRun" {
            if let indexPath = tableView.indexPathForSelectedRow{
                if let destination = segue.destination as? RunDetailViewController{
                    guard let user = CloudController.shared.user else {return}
                    let run = user.runs[indexPath.row]
                    if let competingRun = run.competingRun{
                        destination.isAChallenge = true
                        destination.landingPadUserRun = run
                        destination.landingPadOpponentRun = competingRun
                    } else {
                        destination.isAChallenge = false
                        destination.landingPadUserRun = run
                    }
                }
            }
        }
    }

}
