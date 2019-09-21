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
    
    var testID = "huiuljoijiokjik"
    
    //MARK: - PUSH TO SERVER FUNCTIONS
    
    ///must call fetch userID first
    func createNewUserAndPushWith(name: String, height: Double, weight: Double, age: Int, gender: String,prefersMetric: Bool, completion: @escaping (Bool) -> Void){
        //create a user
        guard let ID = userID else {return}
        let user = User(name: name, height: height, weight: weight, prefersMetric: prefersMetric, age: age, gender: gender, userReference: ID.recordName)
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
            self.user = newUser
            completion(true)
            return
        }
    }
    
    func searchUsers(searchTerm:String, completion: @escaping ([User]) -> Void){
        guard let user = user else {completion([]);return}
        let cleanedTerm = searchTerm
        let predicate1 = NSPredicate(format: "\(UserKeys.nameKey) BEGINSWITH '\(cleanedTerm)'")
        let predicate2 = NSPredicate(format: "\(UserKeys.nameKey) != %@", user.name)
        let predicate3 = NSPredicate(format: "NOT (\(UserKeys.friendReferenceIDKey) CONTAINS %@)", user.recordID)
        //add a predicate to not include friends
        let compPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])
        let query = CKQuery(recordType: UserKeys.userObjectKey, predicate: compPredicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (recordResults, error) in
            if let error = error {
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion([])
                return
            } else {
                guard let unwrappedRecords = recordResults else {completion([]); return}
                if unwrappedRecords.isEmpty{
                    completion([])
                    print("no records found")
                    return
                } else {
                    var foundUsers = [User]()
                    for record in unwrappedRecords{
                        guard let newUser = User(record: record) else {completion([]); return}
                        foundUsers.append(newUser)
                    }
                    completion(foundUsers)
                    print("Results found")
                    return
                }
            }
        }
    }
    func addRunAndPushToCloud(with distance: Double, elevation: Double, calories: Int, totalTime: Double, coreLocations: [CLLocation], completion: @escaping (Bool) -> Void){
        //unwrap user if no user then yo can run simple as that
        guard let user = user else {return}
        //create a run
        let run = Run(distance: distance, elevation: elevation, calories: calories , totalTime: totalTime, coreLocationPoints: coreLocations, user: user)
        //create a record from it
        if var userReferences = user.runsReferenceList{
            userReferences.append(CKRecord.Reference(recordID: run.ckRecordId, action: .none))
        } else {
            user.runsReferenceList = [CKRecord.Reference(recordID: run.ckRecordId, action: .none)]
        }
        guard let recordUser = CKRecord(user: user) else {return}
        let operation = CKModifyRecordsOperation(recordsToSave: [recordUser], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .low
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
            self.publicDatabase.add(operation)
            completion(true)
        }
    }
    
    func addFriend(friend: User,completion: @escaping (Bool) -> Void){
        guard let user = user else {return}
        user.friends.append(friend)
        if var userFriendReferenceList = friend.friendReferenceList{
            userFriendReferenceList.append(CKRecord.Reference(recordID: user.recordID, action: .none))
        } else {
            friend.friendReferenceList = [CKRecord.Reference(recordID: user.recordID, action: .none)]
        }
        
        guard let record = CKRecord(user: friend) else {return}
        let op = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        op.savePolicy = .changedKeys
        op.queuePriority = .normal
        publicDatabase.add(op)
        
    }
    
    func sendARunToAfriend(run:Run, friend:User){
        run.sendTo = CKRecord.Reference(recordID: friend.recordID, action: .none)
        guard let record = CKRecord(run: run) else {return}
        let op = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        op.savePolicy = .changedKeys
        op.queuePriority = .normal
        publicDatabase.add(op)
    }
    
    
    
    
    
    //MARK: - RETRIEVE FROM SERVER FUNCTIONS
    
    func performStartUpFetchs(completion: @escaping (Bool) -> Void){
        retrieveUserID { (success) in
            if success{
                self.retrieveUserProfile(completion: { (success, error) in
                    if let error = error{
                    print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                    }
                    completion(success)
                    return
                })
            } else {
                print("hit")
                completion(false)
                return
            }
        }
    }
    
    
    func retrieveUserID(completion: @escaping (Bool) -> Void){
        CKContainer.default().fetchUserRecordID { (usersRecord, error) in
            if let error = error{
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            
            
            self.userID = usersRecord
            completion(true)
            return
        }
    }
    // to be called every time the app starts up
    func retrieveUserProfile(completion: @escaping (Bool,Error?) -> Void){
        
        guard let userID = userID else {completion(false,nil);print("no user ID"); return}
        let predicate = NSPredicate(format: "UserReference = %@", userID.recordName)
        let query = CKQuery(recordType: UserKeys.userObjectKey, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (record, error) in
            if let error = error{
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false,error)
                return
            }
            guard let recordList = record else {completion(false,nil);print("recordList in fetch user is nil");return}
            guard let record = recordList.first else {completion(false,nil);print("first failure");return}
            guard let user = User(record: record) else {completion(false,nil);print("cant make a user");return}
            self.user = user
            print("user found succesfully")
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
        guard let user = user else {completion(false); print("no user");return}
        let predicate = NSPredicate(format: "\(RunKeys.sendToKey) == %@", user.recordID)
        let query = CKQuery(recordType: RunKeys.runObjectKey, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let recordListRuns = records else {completion(false);print("recordList was nil");return}
            var recordIDList:[CKRecord.ID] = []
            for record in recordListRuns{
                recordIDList.append(record.recordID)
            }
            let predicate2 = NSPredicate(format: "\(UserKeys.runsReferenceList) CONTAINS %@", argumentArray: recordIDList)
            let query2 = CKQuery(recordType: UserKeys.userObjectKey, predicate: predicate2)
            self.publicDatabase.perform(query2, inZoneWith: nil, completionHandler: { (recordsUsers, error) in
                if let error = error{
                    print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let recordListUsers = recordsUsers else {completion(false); print("record list of users was nil");return}
                var users:[User] = []
                for record in recordListUsers{
                    guard let newUser = User(record: record) else {return}
                    users.append(newUser)
                }
                var runs = [Run]()
                for record in recordListRuns{
                    guard let id = record[RunKeys.userReferenceKey] as? CKRecord.Reference else {return}
                    for user in users{
                        if id == user.recordID{
                            guard let newRun = Run(record: record, user: user) else {return}
                            runs.append(newRun)
                        }
                   }
                }
                user.runsRecieved = runs
                completion(true)
                return
            })
        }
    }
    
    func retrieveFriends(completion: @escaping (Bool) -> Void){
        guard let user = user else {return}
        let predicate = NSPredicate(format: "\(UserKeys.friendReferenceIDKey) CONTAINS %@", user.recordID)
        let query = CKQuery(recordType: UserKeys.userObjectKey, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let recordList = records else {completion(true);print("error decoding friends");return}
            for record in recordList{
               guard let friend = User(record: record) else {completion(true);print("error decoding friends");return}
                if !user.friends.contains(friend){
                user.friends.append(friend)
                }
            }
        }
    }
    
}
