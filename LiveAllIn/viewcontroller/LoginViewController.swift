//
//  LoginViewController.swift
//  LiveAllIn
//
//  Created by madhatmedia on 19/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import JGProgressHUD
import SwiftKeychainWrapper

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        hud.textLabel.text = ""
        hud.show(in: self.view)
        
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email.isEmpty {
            let alertController = UIAlertController(title: "Live All In", message: "Please provide your email", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
        
        if password.isEmpty {
            let alertController = UIAlertController(title: "Live All In", message: "Please provide your password", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
        
        Auth.auth().signIn(withEmail: email, password: password){
            (user,error) in
            
            if error == nil {
                let username = Auth.auth().currentUser?.displayName ?? ""
                let userEmail = Auth.auth().currentUser?.email ?? ""
                
                print("username: " + username)
                print("userEmail: " + userEmail)
                
                KeychainWrapper.standard.set(Auth.auth().currentUser?.displayName ?? "", forKey: KeychainString.userName)
                
                KeychainWrapper.standard.set(Auth.auth().currentUser?.email ?? "", forKey: KeychainString.userEmail)
                
                self.hud.dismiss()
                let alertController = UIAlertController(title: "Live All In", message: "Successfully Logged In!", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    
                    let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                    
                    self.present(loginViewController, animated: true)
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            } else {
                if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    self.hud.dismiss()
                    
                    let alertController = UIAlertController(title: "Live All In", message: "Please try again later", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        print("Ok button tapped");
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion:nil)
                }
            }
        }
    }
    
    @IBAction func forgotAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Live All In", message: "Reset password via email", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            let resetEmail = alertController.textFields?[0].text ?? ""
            
            self.hud.textLabel.text = ""
            self.hud.show(in: self.view)
            
            print("resetEmail: \(resetEmail)" )
            Auth.auth().sendPasswordReset(withEmail: resetEmail, completion: { (error) in
                
                if error != nil {
                    self.hud.dismiss()
                    
                    print("error \(error)")
                    
                    let alertController = UIAlertController(title: "Live All In", message: "Error Sending Password Recovery", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion:nil)
                } else {
                    self.hud.dismiss()
                    
                    let alertController = UIAlertController(title: "Live All In", message: "Successfully Sent Password Recovery", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion:nil)
                    
                }
            })
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func firstTimeAction(_ sender: Any) {
        let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        
        self.present(registerViewController, animated: true)
    }
}
