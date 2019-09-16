//
//  RunController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation
import CloudKit

class RunCloudController{
    //Singleton
    static let shared = RunCloudController()
    //source of truth
    var user: User?
    //database local
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //MARK: - CLOUD
    
    //used only on creation of a new profile
    func createNewUserAndPushWith(name: String, height: Double, weight: Double, age: Int, gender: String, completion: @escaping (Bool) -> Void){
        //create a user
        let user = User(name: name, height: height, weight: weight, age: age, gender: gender)
        //convert to a record
        guard let record = CKRecord(user: user) else {return}
        privateDB.save(record) { (recordRecieved, error) in
            if let error = error {
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                //TODO: - TELL USER IF THERE WAS A PROBLEM CREATING THEIR PROFILE
                completion(false)
                return
            }
            //make a record from the record i recieved
            guard let record = recordRecieved else {completion(false);return}
            //create a user from that record
            guard let newUser = User(record: record) else {completion(false);return}
            //set it to my source of truth
            self.user = newUser
            completion(true)
            return
            
        }
    }
    
    func addRunAndPushToCloud(with distance: Double, elevation: Double, calories: Int, totalTime: Double, coreLocations: [CLLocation], completion: @escaping (Bool) -> Void){
        //unwrap user if no user then yo can run simple as that
        guard let user = user else {return}
        //create a run
        let run = Run(distance: distance, elevation: elevation, calories: calories , totalTime: totalTime, coreLocationPoints: coreLocations, user: user)
        //create a record from it
        guard let recordToPush = CKRecord(run: run) else {return}
        //save it
        privateDB.save(recordToPush) { (recordToSave, error) in
            if let error = error {
                //fingers crossed there wasnt an error
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                //TODO: - Find a way to save run and upload later in case of lack of connection??
                //TODO: - also if fails here tell user
                completion(false)
                return
            }
            guard let recordToSave = recordToSave else {completion(false);return}
            guard let runToSave = Run(record: recordToSave, user: user) else {completion(false);return}
            user.runs.append(runToSave)
            completion(true)
        }
        
    }
    
    func fetchExistingUser(completion: @escaping (Bool) -> Void){
        //there should only ever be one user profile so i can just look through the whole thing
        let predicate = NSPredicate(value: true)
        //specify that im searching for the userobject
        let query = CKQuery(recordType: UserKeys.userObjectKey, predicate: predicate)
        //perform my query
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            //it returns a list of records make sure it aint empty
            guard let records = records, records.count > 0
                else {print("recieved an empty array instead of a user");completion(false);return}
            //grab the first and only record (i can force unwrap due to previous statement)
            let userRecordRetrieved = records.first!
            //create a user from that
            guard let userRetrieved = User(record: userRecordRetrieved) else {completion(false);return}
            //set the user
            self.user = userRetrieved
        }
    }
    
    func updateRunPoints(){
        
    }
    
    func fetchRuns(completion: @escaping (Bool) -> Void){
        //unrwrap user
        guard let user = user else {return}
        
        //grab the reference
        let userReference = user.recordID
        
        //create a search for the reference
        let predicate = NSPredicate(format: "%K == %@", RunKeys.userReferenceKey, userReference)
        
        //grab all of the run ids
        let runIDs = user.runs.compactMap({$0.ckRecordId})
        
        //2nd predicate to make sure im getting the correct data
        let predicate2 = NSPredicate(format: "NOT(recordID in %@)", runIDs)
        
        //put my predicates together
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,predicate2])
        
        //create a query
        let query = CKQuery(recordType: "Run", predicate: compoundPredicate)
        
        //perform the query
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            //unwrap the records i recieved and then turn them into runs
            guard let records = records else {completion(false); return}
            var fetchedRuns = [Run]()
            for record in records {
                if let run  = Run(record: record, user: user){
                    fetchedRuns.append(run)
                }
            }
            //set the users runs equal to the ones ive fetched
            user.runs = fetchedRuns
            completion(true)
            
        }
    }
    func subScribeToNewRuns(completion: @escaping (Bool, Error?) -> Void){
        
    }
    
    //MARK: - RUNNING CALCULATIONS
    
    //updates run points
    func calculatePoints(run1: Run, run2: Run){
        var winningRunTime:Run = run2
        var losingRunTime:Run = run1
        //check time.  run 1 is faster in this case so we give them the points
        if run1.totalTime < run2.totalTime {
            winningRunTime = run1
            losingRunTime = run2
            winningRunTime.timePoints = 60
        }
        //get the difference between the two
        let timeDifference: Double = winningRunTime.totalTime.distance(to: run2.totalTime)
        //and then calculate points
        if timeDifference  < 60 {
            losingRunTime.timePoints = 55
        } else if timeDifference < 120 {
            losingRunTime.timePoints = 50
        } else if timeDifference < 300 {
            losingRunTime.timePoints = 45
        } else if timeDifference < 600 {
            losingRunTime.timePoints = 35
        } else if timeDifference < 1200 {
            losingRunTime.timePoints = 20
        } else {
            losingRunTime.timePoints = 10
        }
        //dont want to run the same code over and over
        let runsCompared = [run1,run2]
        for run in runsCompared{
            let points = Int((run.elevationGained / 100) * 5)
            if points > 20{
                run.elevationPoints = 20
            } else {
            run.elevationPoints = points
            }
        }
    }
}
