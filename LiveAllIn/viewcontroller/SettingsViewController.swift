//
//  SettingsViewController.swift
//  LiveAllIn
//
//  Created by madhatmedia on 20/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameValue: UILabel!
    @IBOutlet weak var emailValue: UILabel!
    @IBOutlet weak var subscriptionValue: UILabel!
    
    var userName: String = ""
    var userEmail: String = ""
    
    var alert:UIAlertController?
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName = KeychainWrapper.standard.string(forKey: KeychainString.userName) ?? ""
        userEmail = KeychainWrapper.standard.string(forKey: KeychainString.userEmail) ?? ""
        
        print(userName)
        print(userEmail)
        
        loadingOverlay()
        
        initializeFirebase()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("settings disappear")
    }
    
    func loadingOverlay(){
        alert = UIAlertController(title: nil, message: "Loading profile...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        DispatchQueue.main.async {
            self.alert!.view.addSubview(loadingIndicator)
            self.present(self.alert!, animated: true, completion: nil)
        }
    }
    
    func dismissAlert() {
        DispatchQueue.main.async {
            self.alert?.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initializeFirebase(){
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        if Auth.auth().currentUser == nil {
            let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.present(registerViewController, animated: true)
        } else {
            getUserProfile()
        }
    }
    
    @IBAction func liveallinAction(_ sender: Any) {
        guard let url = URL(string: "http://liveallintoday.com/") else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        
        let dialogMessage = UIAlertController(title: "Live All In", message: "Are you sure you want to Logout?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            
            KeychainWrapper.standard.removeObject(forKey: KeychainString.userEmail)
            KeychainWrapper.standard.removeObject(forKey: KeychainString.userName)
            
            //let songsIn = [nil] as [Any?]
            
            //let encoded = NSKeyedArchiver.archivedData(withRootObject: songsIn)
            //UserDefaults.standard.set(encoded, forKey: "encodedData")
            
            //let domain = Bundle.main.bundleIdentifier!
            //UserDefaults.standard.removePersistentDomain(forName: domain)
            //self.resetDefaults()
            //UserDefaults.standard.synchronize()
            
            try! Auth.auth().signOut()
            
            //self.clearAllFile()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(rootVC, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
            dialogMessage.dismiss(animated: true, completion: nil)
        }
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    func clearAllFile() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try fileManager.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
    
    func getUserProfile() {
        db.collection(FirebaseCollection.Users)
            .document(self.userEmail).getDocument { (document, error) in
            if let document = document, document.exists {
                
                self.dismissAlert()
                
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                print("Document data: \(dataDescription)")
                
                //var plan = document.data()?["planName"] as! String
                var plan:[String]
                plan = document.data()?["planName"] as! [String]

                var plans = ""

                for child in plan {
                    plans = "\(plans) \(child)"
                }
                
                let firstName = document.data()?["firstName"] ?? ""
                let lastName = document.data()?["lastName"] ?? ""
                
                self.userName = "\(firstName) \(lastName)"
                self.nameValue.text = self.userName
                self.subscriptionValue.text = plans
                
                self.emailValue.text = self.userEmail
            } else {
                print("Document does not exist")
            }
        }
    }
}
