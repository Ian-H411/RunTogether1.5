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
    
    init(name: String, totalMiles: Double = 0.0, racesWon: Int = 0, height: Double, weight: Double, age: Int, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.name = name
        self.totalMiles = totalMiles
        self.racesWon = racesWon
        self.weight = weight
        self.age = age
        self.recordID = ckRecordId
        self.height = height
    }
}
