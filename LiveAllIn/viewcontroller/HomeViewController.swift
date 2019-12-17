//
//  HomeViewController.swift
//  LiveAllIn
//
//  Created by madhatmedia on 20/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class HomeViewController: UIViewController {

    var db: Firestore!
    var store: Storage!
    var storeRef: StorageReference!
    var usersList: [UsersModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initializeFirebase()
    }
    
    func initializeFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        store = Storage.storage()
        storeRef = store.reference()
        
        getUsersList()
    }
    
    var counter: Int = 0
    
    func getUsersList(){
        db.collection("users")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.documents.count != 0 {
                    for document in document.documents {
                        //var docID = document.documentID
                        
                        //print("docID: \(docID)")
                        var emailStr = ""
                        var firstName = ""
                        var lastName = ""
                        var planType = ""
                        var planID = ""
                        var signUpDate = ""
                        var status = ""
                        
                        if document.get("email") != nil {
                            
                            emailStr = document.get("email") as! String
                            
                            if document.get("planName") != nil {
                            
                                let planName = document.get("planName") as! String
                                var plans:[String] = []
                                plans.append(planName)
                                
                                if document.get("firstName") != nil {
                                    firstName =  document.get("firstName") as! String
                                }
                                
                                if document.get("lastName") != nil {
                                    lastName =  document.get("lastName") as! String
                                }
                                
                                if document.get("planType") != nil {
                                    planType =  document.get("planType") as! String
                                }
                                
                                if document.get("planID") != nil {
                                    planID =  document.get("planID") as! String
                                }
                                
                                if planID.isEmpty {
                                    if document.get("planId") != nil {
                                        planID =  document.get("planId") as! String
                                    }
                                }
                                
                                if document.get("signUpDate") != nil {
                                    signUpDate =  document.get("signUpDate") as! String
                                }
                                
                                if document.get("status") != nil {
                                    status =  document.get("status") as! String
                                }
                                
                                self.setNewPlan(userEmail: emailStr, firstName:firstName,lastName:lastName,planID: planID, planType:planType, signUpDate:signUpDate, status:status, plansList: plans)
                                
                                print("counter: \(self.counter)")
                                print("userEmail: \(emailStr)")
                                print("firstName: \(firstName)")
                                print("lastName: \(lastName)")
                                print("planID: \(planID)")
                                print("planType: \(planType)")
                                print("signUpDate: \(signUpDate)")
                                
                                print("-------------------------------")
                                
                                self.counter+=1
                            }
                        }
                    }
                }
        }
    }

    var successCount: Int = 0
    
    func setNewPlan(userEmail: String, firstName:String,lastName:String,planID: String, planType:String, signUpDate:String, status:String, plansList: [String]){
        
        print("users2")
        
        db.collection("users2")
            .document(userEmail).setData([
            "email":userEmail,
            "firstName": firstName,
            "lastName": lastName,
            "planID": planID,
            "planName":plansList,
            "planType":planType,
            "signUpDate": signUpDate,
            "status": status
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
                print("successCount: \(self.successCount)")
                print("userEmail: \(userEmail)")
                print("firstName: \(firstName)")
                print("lastName: \(lastName)")
                print("planID: \(planID)")
                print("planType: \(planType)")
                print("signUpDate: \(signUpDate)")
                
                print("-------------------------------")
                
                self.successCount+=1
            }
        }
    }
    
    func updatePlane(userEmail: String, plansList: [String]){
        db.collection("newUserPlan")
            .document(userEmail)
            .updateData([
                "planName":plansList
            ]){ err in
                if let err = err {
                    print("err\(err)")
                } else {
                    print("successCount: \(self.successCount)")
                    self.successCount+=1
                }
        }
    }
    
    func updatePlane11(userEmail: String){
        db.collection("newUserPlan")
            .document(userEmail)
            .updateData([
                "planName":""
            ]){ err in
                if let err = err {
                    print("err\(err)")
                } else {
                    print("successCount: \(self.successCount)")
                    self.successCount+=1
                }
        }
    }
}
