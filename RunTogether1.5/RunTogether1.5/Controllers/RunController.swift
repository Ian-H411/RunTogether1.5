//
//  RunController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/7/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation
import CloudKit

class RunController{
    //Singleton
    static let shared = RunController()
    //source of truth
    var user: User?
    //database local
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //used only on creation of a new profile
    func createNewUserAndPushWith(name: String, height: Double, weight: Double, age: Int, completion: @escaping (Bool) -> Void){
        //create a user
        let user = User(name: name, height: height, weight: weight, age: age)
        //convert to a record
        guard let record = CKRecord(user: user) else {return}
        privateDB.save(record) { (recordRecieved, error) in
            if let error = error {
                print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
                //TODO: - TELL USER IF THERE WAS A PROBLEM
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
    
}
