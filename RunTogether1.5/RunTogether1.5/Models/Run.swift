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
    var calories: Double {
        guard let user = user else {return -1}
        if user.gender == GenderKeys.male {
            //calc male calories
            return (((Double(user.age) * 0.2017) + (user.weight * 0.09036) + (150 * 0.6309) - 55.0969) * totalTime) / 4.184
        } else if user.gender == GenderKeys.female {
            //calc female calories
            return (((Double(user.age) * 0.074) - (user.weight * 0.05741) + (150 * 0.4472) - 20.4022) * totalTime) / 4.184
        } else{
            return ((((Double(user.age) * 0.2017) + (user.weight * 0.09036) + (150 * 0.6309) - 55.0969) * totalTime) / 4.184) * ((((Double(user.age) * 0.074) - (user.weight * 0.05741) + (150 * 0.4472) - 20.4022) * totalTime) / 4.184) / 2
        }
    }
    
    // specific timestamp for when the user hit the start button
    var date: Date {
        return coreLocationPoints[0].timestamp
    }
    
    // amount of distance run by the racer in miles
    let distance: Double
    
    // time from begining to end
    let totalTime: Double
    
    let coreLocationPoints: [CLLocation]
    //cloudkit stuff below
    weak var user: User?
    
    let ckRecordId: CKRecord.ID
    
    //now some variables for a point system
    
    let elevationPoints: Int
    
    let consistencyPoints: Int
    
    let timePoints: Int
    
    var totalPoints: Int {
        return timePoints + consistencyPoints + elevationPoints
    }
    
    //creates a reference to the user
    var userReference: CKRecord.Reference?{
        guard let user  = user else {return nil}
        return CKRecord.Reference(recordID: user.recordID, action: .deleteSelf)
    }
    
    init(distance: Double, totalTime: Double, coreLocationPoints: [CLLocation], user: User, elevationPoints: Int, consistencyPoints: Int, timePoints: Int, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.distance = distance
        self.totalTime = totalTime
        self.coreLocationPoints = coreLocationPoints
        self.user = user
        self.ckRecordId = ckRecordId
        self.elevationPoints = elevationPoints
        self.consistencyPoints = consistencyPoints
        self.timePoints = timePoints
    }
    
    
    init?(record: CKRecord, user: User){
        guard let distance =  record[RunKeys.dateKey] as? Double,
        let totalTime = record[RunKeys.totalTimeKey] as? Double,
        let coreLocationPoints = record[RunKeys.coreLocationsKey] as? [CLLocation],
        let elevationPoints = record[RunKeys.elevationPoints] as? Int,
        let consistencyPoints = record[RunKeys.consistencyPointsKey] as? Int,
        let timePoints = record[RunKeys.timePointsKey] as? Int
            else {return nil}
        self.distance = distance
        self.totalTime = totalTime
        self.coreLocationPoints = coreLocationPoints
        self.user = user
        self.ckRecordId = record.recordID
        self.elevationPoints = elevationPoints
        self.timePoints = timePoints
        self.consistencyPoints = consistencyPoints
        
    }
}
extension CKRecord{
    convenience init?(run: Run){
        self.init(recordType: RunKeys.runObjectKey, recordID: run.ckRecordId)
        self.setValue(run.averagePace, forKey: RunKeys.averagePaceKey)
        self.setValue(run.distance, forKey: RunKeys.distanceKey)
        self.setValue(run.totalTime, forKey: RunKeys.totalTimeKey)
        self.setValue(run.coreLocationPoints, forKey: RunKeys.coreLocationsKey)
        self.setValue(run.userReference, forKey: RunKeys.userReferenceKey)
        self.setValue(run.consistencyPoints, forKey: RunKeys.consistencyPointsKey)
        self.setValue(run.elevationPoints, forKey: RunKeys.elevationPoints)
        self.setValue(run.timePoints, forKey: RunKeys.timePointsKey)
    
    }
}
