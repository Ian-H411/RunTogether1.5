//
//  User.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation
import CloudKit

class User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.recordID == rhs.recordID
    }
    
    
    let name:String
    
    let totalMiles: Double
    
    let racesWon: Int
    
    //in pounds
    var weight: Double
    
    //in inchs
    var height: Double
    
    var age: Int
    
    var recordID: CKRecord.ID
    
    var runs: [Run]
    
    var runsRecieved: [Run]
    
    var runsRecievedReferenceList:[CKRecord.Reference]?
    
    var friends:[User] = []
    
    var friendReferenceList: [CKRecord.Reference]?
    
    var runsReferenceList: [CKRecord.Reference]?
    
    var blockedByReferenceList: [CKRecord.Reference]?
    
    var userReference: String
    
    var gender: String
    
    var prefersMetric: Bool
    
    init(name: String, totalMiles: Double = 0.0, racesWon: Int = 0, height: Double, weight: Double, prefersMetric: Bool, age: Int, gender: String, userReference:String, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), runs: [Run] = [],recievedRuns: [Run] = []){
        self.name = name
        self.totalMiles = totalMiles
        self.racesWon = racesWon
        self.weight = weight
        self.age = age
        self.recordID = ckRecordId
        self.height = height
        self.runs = runs
        self.gender = gender
        self.prefersMetric = prefersMetric
        self.runsRecieved = recievedRuns
        self.userReference = userReference
    }
    
    init?(record: CKRecord){
        guard let name = record[UserKeys.nameKey] as? String,
            let totalMiles = record[UserKeys.totalMilesKey] as? Double,
            let racesWon = record[UserKeys.racesWonKey] as? Int,
            let weight = record[UserKeys.weightKey] as? Double,
            let age = record[UserKeys.ageKey] as? Int,
            let height = record[UserKeys.heightKey] as? Double,
            let gender = record[UserKeys.genderKey] as? String,
            let prefersMetric = record[UserKeys.preferedMeasureMent] as? Bool,
            let userReference = record[RunKeys.userReferenceKey] as? String
            else {return nil}
        let userFriendIds = record[UserKeys.friendReferenceIDKey] as? [CKRecord.Reference]
        let runsToDoIds = record[UserKeys.runsToDoReferenceIDs] as? [CKRecord.Reference]
        let runInboxs = record[UserKeys.runsReferenceList] as? [CKRecord.Reference]
        self.runs = []
        self.runsRecieved = []
        self.recordID = record.recordID
        self.name = name
        self.totalMiles = totalMiles
        self.weight = weight
        self.racesWon = racesWon
        self.age = age
        self.height = height
        self.gender = gender
        self.prefersMetric = prefersMetric
        self.friendReferenceList = userFriendIds
        self.runsRecievedReferenceList = runsToDoIds
        self.userReference = userReference
        self.runsReferenceList = runInboxs
    }
}

extension CKRecord {
    convenience init?(user: User){
        self.init(recordType: UserKeys.userObjectKey, recordID: user.recordID)
        self.setValue(user.name, forKey: UserKeys.nameKey)
        self.setValue(user.totalMiles, forKey: UserKeys.totalMilesKey)
        self.setValue(user.weight, forKey: UserKeys.weightKey)
        self.setValue(user.racesWon, forKey: UserKeys.racesWonKey)
        self.setValue(user.age, forKey: UserKeys.ageKey)
        self.setValue(user.height, forKey: UserKeys.heightKey)
        self.setValue(user.gender, forKey: UserKeys.genderKey)
        self.setValue(user.prefersMetric, forKey: UserKeys.preferedMeasureMent)
        self.setValue(user.userReference, forKey: RunKeys.userReferenceKey)
        
        if let friendList = user.friendReferenceList {
            if !friendList.isEmpty{
                self.setValue(user.friendReferenceList, forKey: UserKeys.friendReferenceIDKey)
                
            }
        }
        if let runsToDo = user.runsRecievedReferenceList{
            if !runsToDo.isEmpty{
                self.setValue(user.runsRecievedReferenceList, forKey: UserKeys.runsToDoReferenceIDs)
            }
            
        }
        if let runsReferences = user.runsReferenceList{
            if !runsReferences.isEmpty{
                self.setValue(user.runsReferenceList, forKey: UserKeys.runsReferenceList)
            }
        }
        if let blockedByReferences = user.blockedByReferenceList{
            if !blockedByReferences.isEmpty{
                self.setValue(user.blockedByReferenceList, forKey: UserKeys.blockedByUsers)
            }
        }
    }
}
