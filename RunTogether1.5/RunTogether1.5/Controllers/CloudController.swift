//
//  CloudController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/18/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation
import CloudKit

class CloudController {
    
    static let shared = CloudController()
    
    var user: User?
    
    var userID:CKRecord.ID?
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    //MARK: - PUSH TO SERVER FUNCTIONS
    
    ///must call fetch userID first
    func createNewUserAndPushWith(name: String, height: Double, weight: Double, age: Int, gender: String,prefersMetric: Bool, completion: @escaping (Bool) -> Void){
        //create a user
        guard let ID = userID else {return}
        let user = User(name: name, height: height, weight: weight, prefersMetric: prefersMetric, age: age, gender: gender)
        user.userReference = ID.recordName
        //convert to a record
        guard let record = CKRecord(user: user) else {return}
        publicDatabase.save(record) { (recordRecieved, error) in
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
            newUser.userReference = ID.recordName
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
        publicDatabase.save(recordToPush) { (recordToSave, error) in
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
    
    
    
    
    
    
    
    
    
    //MARK: - RETRIEVE FROM SERVER FUNCTIONS
    
    func retrieveUserID(completion: @escaping (Bool) -> Void){
        CKContainer.default().fetchUserRecordID { (usersRecord, error) in
            if let error = error{
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
            self.userID = usersRecord
            return
        }
    }
    // to be called every time the app starts up
    func retrieveUserProfile(completion: @escaping (Bool,Error?) -> Void){
        
        guard let userID = userID else {completion(false,nil); return}
        let predicate = NSPredicate(format: "UserReference = %@", userID.recordName)
    let query = CKQuery(recordType: UserKeys.userObjectKey, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (record, error) in
            if let error = error{
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false,error)
                return
            }
            guard let recordList = record else {completion(false,nil);return}
            guard let record = recordList.first else {completion(false,nil);return}
            guard let user = User(record: record) else {completion(false,nil);return}
            self.user = user
            completion(true,nil)
            return
        }
    }
    
    func retrieveRuns(completion: @escaping (Bool) -> Void){
        guard let user = user else  {completion(false);return}
        let predicate = NSPredicate(format: "UserReference = %@", user.recordID)
        let query = CKQuery(recordType: RunKeys.runObjectKey, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (recordList, error) in
            if let error = error {
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = recordList else {completion(false); return}
            let runs:[Run] = records.compactMap({Run(record: $0, user: user)})
            user.runs = runs
            completion(true)
            return
        }
    }
    
    func retrieveRunsToDO(completion: @escaping (Bool) -> Void){
        guard let user = user else {completion(false);return}
        let predicate = NSPredicate(format: "", <#T##args: CVarArg...##CVarArg#>)
    }
    
}
