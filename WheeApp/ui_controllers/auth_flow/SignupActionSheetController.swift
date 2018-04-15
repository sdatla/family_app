//
//  SignupActionSheetController.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 4/16/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit

class SignUpActionSheetController: UIAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addAction(UIAlertAction(title: "Sign up via phone", style: .default, handler: self.handlePhoneNumberSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Email", style: .default, handler: self.handleEmailSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Facebook", style: .default, handler: self.handleFacebookSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Google", style: .default, handler: self.handleGoogleSignUp))
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: self.goBack))
    }
    
    private func handlePhoneNumberSignUp(action: UIAlertAction) {
        print("phone sign up")
    }
    
    private func handleEmailSignUp(action: UIAlertAction) {
        print("email sign up")
    }
    
    private func handleFacebookSignUp(action: UIAlertAction) {
        print("fb sign up")
    }
    
    private func handleGoogleSignUp(action: UIAlertAction) {
        print("google sign up")
    }
    
    private func goBack(action: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
    }
}
