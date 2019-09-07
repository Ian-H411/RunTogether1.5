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
    
    init(name: String, totalMiles: Double = 0.0, racesWon: Int = 0, height: Double, weight: Double, age: Int, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), runs: [Run] = []){
        self.name = name
        self.totalMiles = totalMiles
        self.racesWon = racesWon
        self.weight = weight
        self.age = age
        self.recordID = ckRecordId
        self.height = height
        self.runs = runs
    }
    
    init?(record: CKRecord){
        guard let name = record[UserKeys.nameKey] as? String,
        let totalMiles = record[UserKeys.totalMilesKey] as? Double,
        let racesWon = record[UserKeys.racesWonKey] as? Int,
        let weight = record[UserKeys.weightKey] as? Double,
        let age = record[UserKeys.ageKey] as? Int,
        let height = record[UserKeys.heightKey] as? Double
            else {return nil}
        self.runs = []
        self.recordID = record.recordID
        self.name = name
        self.totalMiles = totalMiles
        self.weight = weight
        self.racesWon = racesWon
        self.age = age
        self.height = height
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
    }
}
