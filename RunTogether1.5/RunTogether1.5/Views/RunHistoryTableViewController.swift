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
    
    var hasFiredRunInbox = false
    
    lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(RunHistoryTableViewController.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(named: "SilverFox")!
        return refreshControl
    }()
    
    var dataSource: [Run]{
        guard let user = CloudController.shared.user else {return []}
        if displayInbox{
            return user.runsRecieved
        } else {
            return CloudController.shared.organizeRunsByDate(runs: user.runs)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        if !Reachability.isConnectedToNetwork(){
            totalDistanceLabel.text = "No Internet Connection"
            RacesWonLabel.text = ""
        }
        CloudController.shared.retrieveRuns { (success) in
            if success{
                DispatchQueue.main.async {
                    guard let user = CloudController.shared.user else {return}
                    self.setUpTotalDistance()
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
                    self.RacesWonLabel.text = "RACES WON: \(user.racesWon)"
                }
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        hasFiredRunInbox = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if !Reachability.isConnectedToNetwork(){
           refresh.endRefreshing()
            presentNoInternetAlert()

        }
        else if displayInbox{
            CloudController.shared.retrieveRunsToDO { (success) in
                if success{
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        print("success")
                        self.refresh.endRefreshing()
                        return
                    }
                }
                
            }
        } else {
            CloudController.shared.retrieveRuns { (success) in
                if success{
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        print("success")
                        self.refresh.endRefreshing()
                        return
                    }
                }
            }
        }
        self.refresh.endRefreshing()
        return
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "runCell", for: indexPath) as? RunTableViewCell else {return UITableViewCell()}
        let run = dataSource[indexPath.row]
        if displayInbox{
            cell.isAChallengeRecieved = true
        }
        cell.update(runRecieved: run)
        
        return cell
    }
    //MARK: - ACTIONS
    
    @IBAction func runInboxControlTapped(_ sender: Any) {
        if displayInbox{
            displayInbox = false
            tableView.reloadData()
        } else if !hasFiredRunInbox{
            self.displayInbox = true
            tableView.reloadData()
            CloudController.shared.retrieveRunsToDO { (success) in
                if success{
                    
                    self.hasFiredRunInbox = true
                    print("successfullyrecieved")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            displayInbox = true
            tableView.reloadData()
            
        }
        
    }
    
    
    
    
    
    //MARK: - HELPER FUNCTIONS
    
    func setUpUI(){
        
        self.tableView.addSubview(self.refresh)
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
    func presentNoInternetAlert(){
        let alertcontroller = UIAlertController(title: "Internet Connection Error", message: "Looks like your not connected to the internet try again later", preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "okay", style: .default, handler: { (_) in
            self.refresh.endRefreshing()
        }))
        self.present(alertcontroller, animated:  true)
    }
    
    
    func setUpTotalDistance(){
        var distance = Measurement(value: 0.0, unit: UnitLength.miles)
        guard let user = CloudController.shared.user else {return}
        for run in user.runs{
            distance = distance + run.distanceInMeasurement
        }
        let formattedDistance = Converter.distance(distance)
        totalDistanceLabel.text = "Total Distance Ran: \(formattedDistance)"
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailRun" {
            if let indexPath = tableView.indexPathForSelectedRow{
                if let destination = segue.destination as? RunDetailViewController{
                    let run = dataSource[indexPath.row]
                    if let competingRun = run.competingRun{
                        destination.isAChallenge = true
                        destination.landingPadUserRun = run
                        destination.landingPadOpponentRun = competingRun
                    } else if displayInbox {
                        destination.userIsAcceptingChallenge = true
                        destination.landingPadOpponentRun = run
                        destination.isAChallenge = false
                    } else {
                        destination.isAChallenge = false
                        destination.landingPadUserRun = run
                    }
                }
            }
        }
    }
    
}
