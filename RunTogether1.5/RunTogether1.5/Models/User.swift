//
//  User.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation
import CloudKit

class User{
    
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
    
    var runsRecievedReferenceList:[CKRecord.Reference]? = []
    
    var friends:[User] = []
    
    var friendReferenceList: [CKRecord.Reference]? = []
    
    var userReference: String?
    
    var gender: String
    
    var prefersMetric: Bool
    
    init(name: String, totalMiles: Double = 0.0, racesWon: Int = 0, height: Double, weight: Double, prefersMetric: Bool, age: Int, gender: String, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), runs: [Run] = [],recievedRuns: [Run] = []){
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
    }
    
    init?(record: CKRecord){
        guard let name = record[UserKeys.nameKey] as? String,
        let totalMiles = record[UserKeys.totalMilesKey] as? Double,
        let racesWon = record[UserKeys.racesWonKey] as? Int,
        let weight = record[UserKeys.weightKey] as? Double,
        let age = record[UserKeys.ageKey] as? Int,
        let height = record[UserKeys.heightKey] as? Double,
        let gender = record[UserKeys.genderKey] as? String,
        let prefersMetric = record[UserKeys.preferedMeasureMent] as? Bool
            else {return nil}
        let userFriendIds = record[UserKeys.friendReferenceIDKey] as? [CKRecord.Reference]
        let runsToDoIds = record[UserKeys.runsToDoReferenceIDs] as? [CKRecord.Reference]
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
        
        guard let friendList = user.friendReferenceList,
        let runsToDo = user.runsRecievedReferenceList
        else {return}
        if !friendList.isEmpty{
        self.setValue(user.friendReferenceList, forKey: UserKeys.friendReferenceIDKey)
        
        } else {
            self.setValue(nil, forKey: UserKeys.friendReferenceIDKey)
        }
        if !runsToDo.isEmpty{
            self.setValue(user.runsRecieved, forKey: UserKeys.runsToDoReferenceIDs)
        } else {
            self.setValue(nil, forKey: UserKeys.runsToDoReferenceIDs)
        }
    }
}
