//
//  LandingViewController.swift
//  LiveAllIn
//
//  Created by madhatmedia on 19/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logginAction(_ sender: Any) {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        self.present(loginViewController, animated: true)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        
        self.present(registerViewController, animated: true)
    }
}
