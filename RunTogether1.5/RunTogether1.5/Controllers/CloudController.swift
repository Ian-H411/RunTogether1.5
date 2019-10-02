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
    func createNewUserAndPushWith(name: String,prefersMetric: Bool, completion: @escaping (Bool) -> Void){
        //create a user
        guard let ID = userID else {return}
        let user = User(name: name, prefersMetric: prefersMetric, userReference: ID.recordName)
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
    
    
    func addRunAndPushToCloud(with distance: Measurement<UnitLength>, elevation: Measurement<UnitLength>, totalTime: Double, coreLocations: [CLLocation], completion: @escaping (Bool) -> Void){
        //unwrap user if no user then yo can run simple as that
        guard let user = user else {return}
        //create a run
        let distance = distance.converted(to: UnitLength.miles)
        let elevation = elevation.converted(to: UnitLength.feet)
        let run = Run(distance: distance.value, elevation: elevation.value, totalTime: totalTime, coreLocationPoints: coreLocations, user: user)
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
            user.runs = self.organizeRunsByDate(runs: user.runs)
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
    
    func completeTheChallenge(opponentsRun:Run, distance: Double, elevation: Double, totalTime: Double, coreLocations: [CLLocation], completion: @escaping (Bool) -> Void){
        guard let user = user else {completion(false);print("user not found");return}
        let myRun = Run(distance: distance, elevation: elevation, totalTime: totalTime, coreLocationPoints: coreLocations, user: user)
        myRun.competingRun = opponentsRun
        opponentsRun.competingRun = myRun
        //first total up the points
        calculatePoints(run1: opponentsRun, run2: myRun)
        //save my run
        
        //check if i have any runs in my reference list if not i need to make one
        if var userReferences = user.runsReferenceList{
            userReferences.append(CKRecord.Reference(recordID: myRun.ckRecordId, action: .none))
        } else {
            user.runsReferenceList = [CKRecord.Reference(recordID: myRun.ckRecordId, action: .none)]
        }
       
        
        
        
        guard let recordToPush = CKRecord(run: myRun) else {return}
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
            runToSave.competingRun = opponentsRun
            opponentsRun.competingRun = runToSave
             user.runs.append(runToSave)
            guard let recordOpponentRun = CKRecord(run: opponentsRun) else {return}
             guard let recordUser = CKRecord(user: user) else {return}
           
            let operation = CKModifyRecordsOperation(recordsToSave: [recordUser,recordOpponentRun], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            self.publicDatabase.add(operation)
            completion(true)
        }
    }
    //MARK: - REPORTING FUNCTIONS
    
    
    func blockUser(userToBlock:User){
        guard let user = user else {return}
        //add to the blocked list
        if var userToBlockList = userToBlock.blockedByReferenceList{
            userToBlockList.append(CKRecord.Reference(recordID: user.recordID, action: .none))
        } else {
            userToBlock.blockedByReferenceList = [CKRecord.Reference(recordID: user.recordID, action: .none)]
        }
        //remove from friendList references and objects
        if var friendList = userToBlock.friendReferenceList{
            for i in 0...friendList.count - 1{
                if friendList[i].recordID.recordName == user.recordID.recordName{
                    friendList.remove(at: i)
                }
            }
        }
        if var userFriendList = user.friendReferenceList{
            for i in 0...userFriendList.count - 1{
                if userFriendList[i].recordID.recordName == userToBlock.recordID.recordName{
                    userFriendList.remove(at: i)
                }
            }
        }
        
        for i in 0...user.friends.count - 1{
            if user.friends[i] == userToBlock{
                user.friends.remove(at: i)
            }
        }
        
        //and then push to the server
        guard let recordOfUser = CKRecord(user: user) else {return}
        guard let recordOfBlockedUser = CKRecord(user: userToBlock) else {return}
        let operation = CKModifyRecordsOperation(recordsToSave: [recordOfBlockedUser,recordOfUser], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        publicDatabase.add(operation)
    }
    
    
    
    //MARK: - RETRIEVE FROM SERVER FUNCTIONS
    
    
    //MARK: - START UPS
    func performStartUpFetchs(completion: @escaping (Bool,Error?) -> Void){
        retrieveUserID { (success) in
            if success{
                self.retrieveUserProfile(completion: { (success, error) in
                    if let error = error{
                        print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                        completion(false,error)
                        
                    }
                    completion(success,nil)
                    return
                })
            } else {
                print("hit")
                completion(false,nil)
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
            var opposingRunReferences:[CKRecord.Reference] = []
            for record in records{
                if let opposingRunKey = record[RunKeys.opposingRunReferenceKey] as? CKRecord.Reference {
                    opposingRunReferences.append(opposingRunKey)
                }
            }
            let runs:[Run] = records.compactMap({Run(record: $0, user: user)})
            user.runs = self.organizeRunsByDate(runs: runs)
            
            if opposingRunReferences.isEmpty{
                completion(true)
                return
            } else {
                self.retrieveOpposingRuns() { (success) in
                    completion(success)
                    return
                }
            }
        }
    }
    //MARK: - RUN RETRIEVAL
    
    func retrieveOpposingRuns(completion: @escaping (Bool) -> Void){
        guard let user = user else {return}
        var runIds:[CKRecord.ID] = []
        for run in user.runs{
            runIds.append(run.ckRecordId)
        }
        let findRunsPredicate = NSPredicate(format: "%@ CONTAINS \(RunKeys.opposingRunReferenceKey)", runIds )
        let query = CKQuery(recordType: RunKeys.runObjectKey, predicate: findRunsPredicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            //now that weve found the runs we need to grab the users associated with them
            guard let recordsOfRuns = records else {return}
            var runRecordIDs:[CKRecord.ID] = []
            for record in recordsOfRuns{
                runRecordIDs.append(record.recordID)
            }
            let predicate2 = NSPredicate(format: "\(UserKeys.friendReferenceIDKey) CONTAINS %@", user.recordID)
            let compoundpredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate2])
            let query2 = CKQuery(recordType: UserKeys.userObjectKey, predicate: compoundpredicate)
            self.publicDatabase.perform(query2, inZoneWith: nil) { (userRecords, error) in
                if let error = error{
                    print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let recordListUsers = userRecords else {completion(false); print("record of users was nil"); return}
                var usersList = [User]()
                for record in recordListUsers{
                    guard let newUser = User(record: record) else {return}
                    usersList.append(newUser)
                }
                //now that we have users we can have runs
                
                let isAttached = self.organizeAndAttachOpposingRuns(recordOfRuns: recordsOfRuns, listOfRetrievedUsers: usersList)
                completion(isAttached)
                
            }
            
        }
        
    }
    func organizeAndAttachOpposingRuns(recordOfRuns:[CKRecord],listOfRetrievedUsers:[User]) -> Bool{
        guard let owner = user else {return false}
        for record in recordOfRuns {
            guard let id = record[RunKeys.userReferenceKey] as? CKRecord.Reference else {return false}
            for userOpponent in listOfRetrievedUsers{
                if id.recordID.recordName == userOpponent.recordID.recordName{
                    guard let newRun = Run(record: record, user: userOpponent) else {return false}
                    for runOwned in owner.runs{
                        guard let opposingRunKey = record[RunKeys.opposingRunReferenceKey] as?  CKRecord.Reference else {return false}
                        if opposingRunKey.recordID.recordName == runOwned.ckRecordId.recordName{
                            runOwned.competingRun = newRun
                        }
                    }
                }
            }
            
        }
        return true
    }
    
    
    func retrieveRunsToDO(completion: @escaping (Bool) -> Void){
        guard let user = user else {completion(false); print("no user");return}
        //make a reference of the runs i already have so i can look up the completed runs and not pull them here
        var retrievedRuns:[CKRecord.Reference] = []
        for run in user.runs{
            retrievedRuns.append(CKRecord.Reference(recordID: run.ckRecordId, action: .none))
        }
        let predicate = NSPredicate(format: "\(RunKeys.sendToKey) == %@", user.recordID)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        let query = CKQuery(recordType: RunKeys.runObjectKey, predicate: compoundPredicate)
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
            if recordIDList.isEmpty{
                completion(true)
                print("Inbox empty")
                return
            }
            
            let predicate = NSPredicate(format: "\(UserKeys.friendReferenceIDKey) CONTAINS %@", user.recordID)
            let query2 = CKQuery(recordType: UserKeys.userObjectKey, predicate: predicate)
            self.publicDatabase.perform(query2, inZoneWith: nil, completionHandler: { (recordsUsers, error) in
                if let error = error{
                    print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let recordListUsers = recordsUsers else {completion(false); print("record list of users was nil");return}
                var users:[User] = []
                var tripped = false
                for record in recordListUsers{
                    if let BlockedByList = record[UserKeys.blockedByUsers] as? [CKRecord.Reference]{
                        for userWhoBlocked in BlockedByList{
                            if userWhoBlocked.recordID.recordName == user.recordID.recordName{
                                tripped = true
                            }
                        }
                    }
                    if !tripped{
                        guard let newUser = User(record: record) else {return}
                        users.append(newUser)
                    }
                }
                var runs = [Run]()
                for record in recordListRuns{
                    if let _ = record[RunKeys.opposingRunReferenceKey] as? CKRecord.Reference{
                        continue
                    }
                    guard let id = record[RunKeys.userReferenceKey] as? CKRecord.Reference else {return}
                    for user in users{
                        print(id.recordID.recordName)
                        print(user.recordID.recordName)
                        if id.recordID.recordName == user.recordID.recordName{
                            guard let newRun = Run(record: record, user: user) else {return}
                            runs.append(newRun)
                        }
                    }
                }
                user.runsRecieved = self.organizeRunsByDate(runs: runs)
                completion(true)
                return
            })
        }
    }
    //MARK: - users/friends
    
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
            var tripped = false
            for record in recordList{
                guard let friend = User(record: record) else {completion(true);print("error decoding friends");return}
                if let bannedbylist = friend.blockedByReferenceList{
                    for ban in bannedbylist{
                        if ban.recordID.recordName == user.recordID.recordName{
                            tripped = true
                        }
                    }
                }
                if !tripped{
                    if !user.friends.contains(friend){
                        user.friends.append(friend)
                    }
                    let friendsSorted = self.organizeUsersAlphabetically(users: user.friends)
                    user.friends = friendsSorted
                    completion(true)
                    return
                }
            }
        }
    }
    
    func checkIfUserExists(username:String,completion: @escaping (Bool) -> Void){
        
        let predicate = NSPredicate(format: "\(UserKeys.nameKey) == %@", username)
        let query = CKQuery(recordType: UserKeys.userObjectKey, predicate: predicate)
        CloudController.shared.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = records else {completion(true);return}
            if records.isEmpty{
                completion(true)
                return
            } else {
                completion(false)
                print("User exists")
                return
            }
            
        }
    }
    
    func searchUsers(searchTerm:String, completion: @escaping ([User]) -> Void){
        guard let userOwner = user else {completion([]);return}
        let cleanedTerm = searchTerm
        let predicate1 = NSPredicate(format: "\(UserKeys.nameKey) BEGINSWITH '\(cleanedTerm)'")
        let predicate2 = NSPredicate(format: "\(UserKeys.nameKey) != %@", userOwner.name)
        let predicate3 = NSPredicate(format: "NOT (\(UserKeys.friendReferenceIDKey) CONTAINS %@)", userOwner.recordID)
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
                    var tripwire = false
                    var foundUsers = [User]()
                    for record in unwrappedRecords{
                        if let blockedList = record[UserKeys.blockedByUsers] as? [CKRecord.Reference]{
                            for blocked in blockedList{
                                if blocked.recordID.recordName == userOwner.recordID.recordName{
                                    tripwire = true
                                }
                            }
                        }
                        if !tripwire{
                            guard let newUser = User(record: record) else {completion([]); return}
                            foundUsers.append(newUser)
                        }
                        tripwire = false
                    }
                    completion(self.organizeUsersAlphabetically(users: foundUsers))
                    print("Results found")
                    return
                }
            }
        }
    }
    //MARK: - DELETE
    
    func deleteArun(run:Run){
        guard let user = user else {return}
        
        for i in 0...user.runs.count - 1{
            if user.runs[i] == run{
                user.runs.remove(at: i)
                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [run.ckRecordId])
                operation.queuePriority = .normal
                publicDatabase.add(operation)
                print("run removed")
                
            }
        }
    }
    func deleteUser(){
        guard let user = user else {return}
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [user.recordID])
        
        publicDatabase.add(operation)
    }
    
    func removeFriend(friend:User){
        guard let user = CloudController.shared.user else {return}
        for i in 0...user.friends.count - 1{
            if user.friends[i] == friend{
                user.friends.remove(at: i)

            }
        }
        if var friendsFriendList = friend.friendReferenceList {
            for i in 0...friendsFriendList.count - 1{
                if friendsFriendList[i].recordID.recordName == user.recordID.recordName{
                    friendsFriendList.remove(at: i)
                    friend.friendReferenceList = friendsFriendList
                }
            }
        }
        guard let friendRecord = CKRecord(user: friend) else {return}
        let operation = CKModifyRecordsOperation(recordsToSave:[friendRecord] , recordIDsToDelete: nil)
        operation.queuePriority = .high
        operation.savePolicy = .changedKeys
        publicDatabase.add(operation)
        print("friend removed")
    }
    
    //MARK: - POINT SYSTEM
    //updates run points
    func calculatePoints(run1: Run, run2: Run){
        var winningRunTime:Run = run2
        var losingRunTime:Run = run1
        //check time.  run 1 is faster in this case so we give them the points
        if run1.totalTime < run2.totalTime {
            winningRunTime = run1
            losingRunTime = run2
            winningRunTime.timePoints = 60
        } else {
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
    //MARK: - MISC HELPERS
    
    func organizeRunsByDate(runs:[Run]) -> [Run]{
        let newArray = runs.sorted(by: { $0.date > $1.date })
        return newArray
    }
    
    func organizeUsersAlphabetically(users:[User]) -> [User]{
        return users.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
    }
    
    
}

