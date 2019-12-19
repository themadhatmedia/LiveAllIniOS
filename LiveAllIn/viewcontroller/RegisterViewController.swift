//
//  RegisterViewController.swift
//  LiveAllIn
//
//  Created by madhatmedia on 19/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD


class RegisterViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var notFoundLabel: UILabel!
    @IBOutlet weak var allInSiteButton: UIButton!
    
    var db: Firestore!
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFirebase()
    }
    
    func initializeFirebase(){
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        hud.textLabel.text = ""
        hud.show(in: self.view)
        
        self.notFoundLabel.isHidden = true
        self.allInSiteButton.isHidden = true
        
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let confirmPassword = confirmPasswordField.text ?? ""
        
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            let alertController = UIAlertController(title: "Live All In", message: "Please provide your account information", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        } else {
            
            if password.elementsEqual(confirmPassword) {
                let docRef = db.collection(FirebaseCollection.Users)
                    .document(email)

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        //self.hud.dismiss()
                        //self.notFoundLabel.isHidden = true
                        //self.allInSiteButton.isHidden = true
                        
                        Auth.auth().createUser(withEmail: email, password: password){
                            (user,error) in
                            
                            if error == nil{
                                self.hud.dismiss()
                                
                                let alertController = UIAlertController(title: "Live All In", message: "Successfully Registered!", preferredStyle: .alert)
                                
                                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                                    self.dismiss(animated: false, completion: nil)
                                }
                                alertController.addAction(OKAction)
                                self.present(alertController, animated: true, completion:nil)
                            } else {
                                if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                                    self.hud.dismiss()
                                }
                            }
                        }
                        
                    } else {
                        print("Document does not exist")
                        self.hud.dismiss()
                        self.notFoundLabel.isHidden = false
                        self.allInSiteButton.isHidden = false
                        
                        let alertController = UIAlertController(title: "Live All In", message: "Account Not Found!", preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        }
                        
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                }
            } else {
                self.hud.dismiss()
                
                let alertController = UIAlertController(title: "Live All In", message: "Confirm password doesn't match", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    self.confirmPasswordField.text = ""
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func allInAction(_ sender: Any) {
        guard let url = URL(string: "http://liveallintoday.com/") else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
