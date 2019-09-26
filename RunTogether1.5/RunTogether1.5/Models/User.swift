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
        return lhs.recordID.recordName == rhs.recordID.recordName
    }
    
    
    let name:String
    
    let totalMiles: Double
    
    var racesWon: Int{
        var total = 0
        for run in runs{
            if let runwin = run.didWin {
                if runwin{
                    total = total + 1
                }
            }
        }
        return total
    }
    
    var recordID: CKRecord.ID
    
    var runs: [Run]
    
    var runsRecieved: [Run]
    
    var runsRecievedReferenceList:[CKRecord.Reference]?
    
    var friends:[User] = []
    
    var friendReferenceList: [CKRecord.Reference]?
    
    var runsReferenceList: [CKRecord.Reference]?
    
    var blockedByReferenceList: [CKRecord.Reference]?
    
    var userReference: String
    
    var prefersMetric: Bool
    
    init(name: String, totalMiles: Double = 0.0, prefersMetric: Bool, userReference:String, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), runs: [Run] = [],recievedRuns: [Run] = []){
        self.name = name
        self.totalMiles = totalMiles
        self.recordID = ckRecordId
        self.runs = runs
        self.prefersMetric = prefersMetric
        self.runsRecieved = recievedRuns
        self.userReference = userReference
    }
    
    init?(record: CKRecord){
        guard let name = record[UserKeys.nameKey] as? String,
            let totalMiles = record[UserKeys.totalMilesKey] as? Double,
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
        self.setValue(user.racesWon, forKey: UserKeys.racesWonKey)
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
