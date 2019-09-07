//
//  Run.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/6/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation
import CloudKit

class Run {
    
    //average pace held by the race during the race
    var averagePace: Double
    
    // calories burnt throughout the run
    var calories:Int
    
    // specific timestamp for when the user hit the start button
    let date: Date
    
    // amount of distance run by the racer
    let distance: Double
    
    // time from begining to end
    let totalTime: Double
    
    let coreLocationPoints: [CLLocation]
    //cloudkit stuff below
    weak var user: User?
    
    let ckRecordId: CKRecord.ID
    
    //creates a reference to the user
    var userReference: CKRecord.Reference?{
        guard let user  = user else {return nil}
        return CKRecord.Reference(recordID: user.recordID, action: .deleteSelf)
    }
    
    init(averagePace: Double, calories: Int, date: Date = Date(), distance: Double, totalTime: Double, coreLocationPoints: [CLLocation], user: User, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.averagePace = averagePace
        self.calories = calories
        self.date = date
        self.distance = distance
        self.totalTime = totalTime
        self.coreLocationPoints = coreLocationPoints
        self.user = user
        self.ckRecordId = ckRecordId
    }
    
    
    init?(record: CKRecord, user: User){
        guard let averagePace = record[RunKeys.averagePaceKey] as? Double,
        let calories = record[RunKeys.calorieKey] as?  Int,
        let date = record[RunKeys.dateKey] as? Date,
        let distance =  record[RunKeys.dateKey] as? Double,
        let totalTime = record[RunKeys.totalTimeKey] as? Double,
        let coreLocationPoints = record[RunKeys.coreLocationsKey] as? [CLLocation]
            else {return nil}
        self.averagePace = averagePace
        self.calories = calories
        self.date = date
        self.distance = distance
        self.totalTime = totalTime
        self.coreLocationPoints = coreLocationPoints
        self.user = user
        self.ckRecordId = record.recordID
    }
}
extension CKRecord{
    convenience init?(run: Run){
        self.init(recordType: RunKeys.runObjectKey, recordID: run.ckRecordId)
        self.setValue(run.averagePace, forKey: RunKeys.averagePaceKey)
        self.setValue(run.calories, forKey: RunKeys.calorieKey)
        self.setValue(run.date, forKey: RunKeys.dateKey)
        self.setValue(run.distance, forKey: RunKeys.distanceKey)
        self.setValue(run.totalTime, forKey: RunKeys.totalTimeKey)
        self.setValue(run.coreLocationPoints, forKey: RunKeys.coreLocationsKey)
        self.setValue(run.userReference, forKey: RunKeys.userReferenceKey)
    
    }
}
