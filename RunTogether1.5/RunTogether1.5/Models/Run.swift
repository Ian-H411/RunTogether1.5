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
    
    //average pace held by the race during the race in mph
    var averagePace: Double {
        return distance / totalTime
    }
    
    
    
    // calories burnt throughout the run
    var calories: Int
    
    // specific timestamp for when the user hit the start button
    var date: Date {
        return coreLocationPoints[0].timestamp
    }
    
    // amount of distance run by the racer in miles
    let distance: Double
    
    //in feet
    let elevationGained: Double
    
    // time from begining to end
    let totalTime: Double
    
    let coreLocationPoints: [CLLocation]
    //cloudkit stuff below
    weak var user: User?
    
    let ckRecordId: CKRecord.ID
    
    //now some variables for a point system
    
    var elevationPoints: Int = 0
    
    var consistencyPoints: Int = 0
    
    var timePoints: Int = 0
    
    var totalPoints: Int {
        return timePoints + consistencyPoints + elevationPoints
    }
    
    var opponentsName = ""
    
    var opponentsPoints = 0
    
    var didWin: Bool? {
        if totalPoints == opponentsPoints {
            return nil
        } else if totalPoints > opponentsPoints {
            return true
        } else {
            return false
        }
    }
    //creates a reference to the user
    var userReference: CKRecord.Reference?{
        guard let user  = user else {return nil}
        return CKRecord.Reference(recordID: user.recordID, action: .deleteSelf)
    }
    
    init(distance: Double, elevation: Double, calories: Int, totalTime: Double, coreLocationPoints: [CLLocation], user: User, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.distance = distance
        self.totalTime = totalTime
        self.coreLocationPoints = coreLocationPoints
        self.user = user
        self.ckRecordId = ckRecordId
        self.calories = calories
        self.elevationGained = elevation
        
    }
    
    
    init?(record: CKRecord, user: User){
        guard let distance =  record[RunKeys.dateKey] as? Double,
            let totalTime = record[RunKeys.totalTimeKey] as? Double,
            let coreLocationPoints = record[RunKeys.coreLocationsKey] as? [CLLocation],
            let calories = record[RunKeys.calorieKey] as? Int,
            let elevationPoints = record[RunKeys.elevationPoints] as? Int,
        let consistencyPoints = record[RunKeys.consistencyPointsKey] as? Int,
        let timePoints = record[RunKeys.consistencyPointsKey] as? Int,
        let opponentsName = record[RunKeys.opponentName] as? String,
        let opponentsPoints = record[RunKeys.opponentPoints] as? Int,
        let elevationGained = record[RunKeys.elevationGained] as? Double
            else {return nil}
        self.distance = distance
        self.totalTime = totalTime
        self.coreLocationPoints = coreLocationPoints
        self.user = user
        self.ckRecordId = record.recordID
        self.calories = calories
        self.elevationPoints = elevationPoints
        self.consistencyPoints = consistencyPoints
        self.timePoints = timePoints
        self.opponentsName = opponentsName
        self.opponentsPoints = opponentsPoints
        self.elevationGained = elevationGained
    }
}
extension CKRecord{
    convenience init?(run: Run){
        self.init(recordType: RunKeys.runObjectKey, recordID: run.ckRecordId)
        self.setValue(run.distance, forKey: RunKeys.distanceKey)
        self.setValue(run.totalTime, forKey: RunKeys.totalTimeKey)
        self.setValue(run.coreLocationPoints, forKey: RunKeys.coreLocationsKey)
        self.setValue(run.userReference, forKey: RunKeys.userReferenceKey)
        self.setValue(run.consistencyPoints, forKey: RunKeys.consistencyPointsKey)
        self.setValue(run.elevationPoints, forKey: RunKeys.elevationPoints)
        self.setValue(run.timePoints, forKey: RunKeys.timePointsKey)
        self.setValue(run.calories, forKey: RunKeys.calorieKey)
        self.setValue(run.opponentsName, forKey: RunKeys.opponentName)
        self.setValue(run.opponentsPoints, forKey: RunKeys.opponentPoints)
        self.setValue(run.elevationGained, forKey: RunKeys.elevationGained)
    }
}
