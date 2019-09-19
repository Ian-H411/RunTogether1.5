//
//  RunController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
import CloudKit

class RunCloudController{
    //Singleton
    static let shared = RunCloudController()
    //source of truth
    var user: User?
    //database local
    let privateDB = CKContainer.default().privateCloudDatabase
    
    let sharedZoneKey = "SharedRuns"
    
    //MARK: - CLOUD
    
//    //used only on creation of a new profile
//    func createNewUserAndPushWith(name: String, height: Double, weight: Double, age: Int, gender: String,prefersMetric: Bool, completion: @escaping (Bool) -> Void){
//        //create a user
//        let user = User(name: name, height: height, weight: weight, prefersMetric: prefersMetric, age: age, gender: gender, )
//        //convert to a record
//        guard let record = CKRecord(user: user) else {return}
//        privateDB.save(record) { (recordRecieved, error) in
//            if let error = error {
//                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
//                //TODO: - TELL USER IF THERE WAS A PROBLEM CREATING THEIR PROFILE
//                completion(false)
//                return
//            }
//            //make a record from the record i recieved
//            guard let record = recordRecieved else {completion(false);return}
//            //create a user from that record
//            guard let newUser = User(record: record) else {completion(false);return}
//            //set it to my source of truth
//            self.user = newUser
//            
//            let sharedRunsZone = CKRecordZone(zoneName: self.sharedZoneKey)
//            
//            self.privateDB.save(sharedRunsZone, completionHandler: { (recordZone, error) in
//                if let error = error{
//                    print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
//                    completion(false)
//                    return
//                }
//                completion(true)
//                return
//            })
//            
//            
//            
//        }
//    }
    
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
            completion(true)
            
        }
    }
    
    func updateRunPoints(){
        
    }
    
    func fetchRuns(completion: @escaping (Bool) -> Void){
        guard let user = user else {return}
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RunKeys.runObjectKey, predicate: predicate)
        //grab all of the run ids
        
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
    
    func createflashyrecord(run:Run) -> CKRecord{
        let zone = CKRecordZone(zoneName: sharedZoneKey)
        let record = CKRecord(recordType: RunKeys.runObjectKey, zoneID: zone.zoneID)
        record.setValue(run.distance, forKey: RunKeys.distanceKey)
        record.setValue(run.totalTime, forKey: RunKeys.totalTimeKey)
        record.setValue(run.coreLocationPoints, forKey: RunKeys.coreLocationsKey)
        record.setValue(run.userReference, forKey: RunKeys.userReferenceKey)
        record.setValue(run.competingRun, forKey: RunKeys.opposingRunReferenceKey)
        record.setValue(run.consistencyPoints, forKey: RunKeys.consistencyPointsKey)
        record.setValue(run.elevationPoints, forKey: RunKeys.elevationPoints)
        record.setValue(run.timePoints, forKey: RunKeys.timePointsKey)
        record.setValue(run.calories, forKey: RunKeys.calorieKey)
        record.setValue(run.elevationGained, forKey: RunKeys.elevationGained)
        return record
    }
    
    
    func shareARun(distance:Double,elevation:Double,Calories:Int,timeInSeconds:Int,coreLocationPoints:[CLLocation], completion: @escaping (UICloudSharingController?) -> Void){
        
        guard let user = user else {return}
        
        let run = Run(distance: distance, elevation: elevation, calories: Calories, totalTime: Double(timeInSeconds), coreLocationPoints: coreLocationPoints, user: user)
        //if theres a problem look here
        let zone = CKRecordZone(zoneName: sharedZoneKey)
        let runRecord = createflashyrecord(run: run)
        
        let share = CKShare(rootRecord: runRecord)
        
        let sharingController = UICloudSharingController { (controller: UICloudSharingController, prepareCompletionHandler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            let modifyOp = CKModifyRecordsOperation(recordsToSave: [runRecord,share], recordIDsToDelete: nil)
            modifyOp.modifyRecordsCompletionBlock = {
                (_,_,error) in
                prepareCompletionHandler(share,CKContainer.default(),error)
                modifyOp.database = self.privateDB

            }
            self.privateDB.add(modifyOp)
        }
        sharingController.availablePermissions = [.allowPublic, .allowReadWrite]
        completion(sharingController)
        
    }
    
    
    //    func subScribeToNewRuns(completion: @escaping (Bool, Error?) -> Void){
    //
    //    }
    //    //felt cute might delete later
    //    func createAZone(run:Run, completion: @escaping (CKRecordZone?, Error?) -> Void){
    //        let zone = CKRecordZone(zoneName: run.ckRecordId.recordName)
    //        privateDB.save(zone) { (returnRecord, error) in
    //            completion(returnRecord,error)
    //        }
    //    }
    //    func shareARun(distance:Double,elevation:Double,Calories:Int,timeInSeconds:Int,coreLocationPoints:[CLLocation], completion: @escaping (UICloudSharingController?) -> Void) {
    //        //create a Run
    //        guard let user = user else {completion(nil);return}
    //        let run = Run(distance: distance, elevation: elevation, calories: Calories, totalTime: Double(timeInSeconds), coreLocationPoints: coreLocationPoints, user: user)
    //        //create and send zone
    //        createAndPushZone(run: run) { (CKRecordZoneOptional) in
    //            if let recordZone = CKRecordZoneOptional{
    //
    //
    //                self.createAndPushRecordToZone(run: run, zone: recordZone, completion: { (record) in
    //                    guard let record = record else {return}
    //                    guard let newRun = Run(record: record, user: user) else {return}
    //
    //
    //                    self.createShareProfile(run: newRun, zone: recordZone, completion: { (sharingcontroller) in
    //                        guard let shareController = sharingcontroller else {return}
    //                        completion(shareController)
    //                        return
    //                    })
    //                })
    //
    //            }
    //        }
    //        //create record
    //
    //        //createdefaultshareprofile
    //    }
    //
    //    func createAndPushZone(run:Run, completion: @escaping (CKRecordZone?) -> Void){
    //        let customZone = CKRecordZone(zoneName: run.ckRecordId.recordName)
    //        privateDB.save(customZone) { (zoneOptional, error) in
    //            if let error = error{
    //                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
    //                completion(nil)
    //                return
    //            }
    //            completion(zoneOptional)
    //            return
    //        }
    //    }
    //    func createAndPushRecordToZone(run:Run, zone:CKRecordZone, completion: @escaping (CKRecord?) -> Void){
    //        guard let recordToPush = CKRecord(run: run, recordZone: zone) else {completion(nil);return}
    //
    //        privateDB.save(recordToPush) { (recordRecieved, error) in
    //            if let error = error{
    //                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
    //                completion(nil)
    //                return
    //            }
    //            completion(recordRecieved)
    //            return
    //        }
    //    }
    //    func createShareProfile(run:Run, zone:CKRecordZone, completion: @escaping (UICloudSharingController?) -> Void){
    //        let query = CKQuery(recordType: RunKeys.runObjectKey, predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
    //        privateDB.perform(query, inZoneWith: zone.zoneID) { (recordArrayOptional, error) in
    //            if let error = error {
    //                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
    //                completion(nil)
    //                return
    //            }
    //            guard let recordlist = recordArrayOptional else {completion(nil);return}
    //            guard let record = recordlist.first else {completion(nil);return}
    //            let share = CKShare(rootRecord: record)
    //
    //            let sharingController = UICloudSharingController { (controller: UICloudSharingController , prepareCompletionHandler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
    //                let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record,share], recordIDsToDelete: nil)
    //                modifyOperation.modifyRecordsCompletionBlock = { (_,_,error) in
    //                    prepareCompletionHandler(share,CKContainer.default(),error)
    //                }
    //                self.privateDB.add(modifyOperation)
    //
    //
    //            }
    //            sharingController.availablePermissions = [.allowReadWrite]
    //            completion(sharingController)
    //            return
    //        }
    //    }
    //
    //
    //        func createShareAndPresentShareController(distance:Double,elevation:Double,Calories:Int,timeInSeconds:Int,coreLocationPoints:[CLLocation],completion: @escaping (CKRecordZone?,Error?, UICloudSharingController?) ->Void ){
    //            //create a root record and a share
    //            guard let user = user else {return}
    //            let run = Run(distance: distance, elevation: elevation, calories: Calories, totalTime: Double(timeInSeconds), coreLocationPoints: coreLocationPoints, user: user)
    //            let zoneToSend = CKRecordZone(zoneName: run.ckRecordId.recordName)
    //            privateDB.save(zoneToSend) { (recordZoneOptional, errorOptional) in
    //                if let error = errorOptional{
    //                    print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
    //                    completion(nil,error,nil)
    //                }
    //                guard let zoneRecieved = recordZoneOptional else {completion( nil,nil,nil);return}
    //
    //
    //                let predicate = NSPredicate(format: "TRUEPREDICATE", argumentArray: nil)
    //                let query = CKQuery(recordType: RunKeys.runObjectKey, predicate: predicate)
    //                self.privateDB.perform(query, inZoneWith: zoneRecieved.zoneID, completionHandler: { (records, error) in
    //                    if let error = error{
    //                        print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
    //                        completion(nil,error,nil)
    //                        return
    //                    }
    //                    guard let record = CKRecord(run: run, recordZone: zoneRecieved) else {return}
    //                    let share = CKShare(rootRecord: record)
    //                })
    //
    //
    //
    //                let sharingController = UICloudSharingController { (controller: UICloudSharingController , prepareCompletionHandler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
    //                    let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record,share], recordIDsToDelete: nil)
    //                    modifyOperation.modifyRecordsCompletionBlock = { (_,_,error) in
    //                        prepareCompletionHandler(share,CKContainer.default(),error)
    //                    }
    //                    self.privateDB.add(modifyOperation)
    //
    //
    //                }
    //                sharingController.availablePermissions = [.allowReadWrite]
    //                completion(zoneToSend,nil,sharingController)
    //                return
    //
    //            }
    //
    //            //set sharing options
    //
    //        }
    //    func shareARunTo(zone:CKRecordZone, run:Run ,completion: @escaping (Bool) -> Void){
    //        guard let record = CKRecord(run: run, recordZone: zone) else {completion(false);return}
    //        privateDB.save(record) { (record, error) in
    //            if let error = error{
    //                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
    //                completion(false)
    //                return
    //            }
    //            guard let recordToSave = record else {completion(false); return}
    //            guard let user = self.user else {completion(false); return}
    //            guard let newRun = Run(record: recordToSave, user: user) else {completion(false); return}
    //            user.runs.append(newRun)
    //            completion(true)
    //            print("run shared to zone succesfully")
    //            return
    //        }
    //
    //
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

