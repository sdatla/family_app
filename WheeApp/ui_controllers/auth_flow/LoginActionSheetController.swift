//
//  LoginActionSheetController.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 4/16/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginActionSheetController: UIAlertController, GIDSignInUIDelegate  {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.addAction(UIAlertAction(title: "Log in via phone", style: .default, handler: self.handlePhoneNumberLogin))
        self.addAction(UIAlertAction(title: "Email and Password", style: .default, handler: self.handleEmailLogin))
        self.addAction(UIAlertAction(title: "Log in with Facebook", style: .default, handler: self.handleFacebookLogin))
        self.addAction(UIAlertAction(title: "Log in with Google", style: .default, handler: self.handleGoogleLogin))
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: self.goBack))
    }
    
    private func handlePhoneNumberLogin(action: UIAlertAction) {
        print("phone Log in")
    }
    
    private func handleEmailLogin(action: UIAlertAction) {
        print("email Log in")
    }
    
    private func handleFacebookLogin(action: UIAlertAction) {
        print("fb Log in")
    }
    
    private func handleGoogleLogin(action: UIAlertAction) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    private func goBack(action: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
    }
}
