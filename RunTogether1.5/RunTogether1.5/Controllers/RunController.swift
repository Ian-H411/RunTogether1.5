//
//  RunController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation
import CloudKit

class RunController{
    //Singleton
    static let shared = RunController()
    //source of truth
    var user: User?
    //database local
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //used only on creation of a new profile
    func createNewUserAndPushWith(name: String, height: Double, weight: Double, age: Int, completion: @escaping (Bool) -> Void){
        //create a user
        let user = User(name: name, height: height, weight: weight, age: age)
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
    
    func addRunAndPushToCloud(with averagePace: Double, calories: Int, distance: Double, totalTime: Double, coreLocations: [CLLocation], completion: @escaping (Bool) -> Void){
        //unwrap user if no user then yo can run simple as that
        guard let user = user else {return}
        //create a run
        let run = Run(averagePace: averagePace, calories: calories, distance: distance, totalTime: totalTime, coreLocationPoints: coreLocations, user: user)
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
}
