//
//  ViewController.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 11/5/17.
//  Copyright © 2017 Leung Wai Chan. All rights reserved.
//

import CoreData
import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase

struct ImageDestination: Codable {
    let site_name: String
    let uri: String
}
struct GettyImage:Codable {
    let id: String
    let referral_destinations: [ImageDestination]
}
struct GettyImageResponse: Codable {
    let result_count: Int
    let images: [GettyImage]
}


class SignInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, communicationControllerQrScanner {
    var user: Profile?
    
    
//    let googlegSigninButton:GIDSignInButton = {
//        let signinButton = GIDSignInButton()
//        signinButton.contentVerticalAlignment = .center
//        return signinButton
//    }()
    private let logo: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "whee_on_dark"))
        return iv
    }()
    
    let logInButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 10)
        button.addTarget(self, action: #selector(onLogInClick), for: .touchUpInside)
        return button
    }()
    
    let scanQrCodeButton: UIButton = {
        let button = UIButton()
        let qrCodeImage = UIImage(named: "icon_barcode")
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.setImage(qrCodeImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.setTitle("Scan my family QR code", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 10)
        button.addTarget(self, action: #selector(onQrScanClick), for: .touchUpInside)
        return button
    }()
    
    let joinNowLabel: UILabel = {
        let label = UILabel()
        label.text = "Join Now"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var background: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "launch")
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        let googleUser = user
        if (error == nil) {
            guard let auth = user.authentication else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
            Auth.auth().signIn(with: credential) {(user, error) in
                if let error = error {
                    print(error)
                } else {
                    self.afterSignIn(googleUser!, firebaseUser: user)
//                    self.performSegue(withIdentifier: "sign_up_profile", sender: self)
                }
            }
           
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    @objc private func joinNowLabelTapped() {
        let actionsheet = SignUpActionSheetController()
        actionsheet.delegate = self
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    
    private func redirect() {
        if let uid = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            db.collection("profiles").document(uid).getDocument(completion: { (document, err) in
                if err != nil {
                    print("redirect erro", err ?? "error")
                    return
                }
                guard let document = document else {
                    print("no doucment")
                    return
                    
                }
                print("document exists", document.exists)
                if document.exists {
                    let data = document.data()
                    let user = Profile()
                    user.familyId = data["family_id"] as? String
                    user.guid = uid
                    user.name = data["name"] as? String
                    user.profileStatus = (data["profile_status"] as! String)
                    user.avatarUrl = data["profile_image_url"] as? String ?? ""
                    self.user = user
                    if user.profileStatus == ProfileStatus.DONE.rawValue {
                        self.performSegue(withIdentifier: "to_home_page", sender: nil)
                    } else if user.profileStatus == ProfileStatus.PENDING.rawValue {
                        self.performSegue(withIdentifier: "sign_up_profile", sender: nil)
                    }
                } else if let user = self.user {
                    user.updateProfile(nil)
                } else {
                    print("uid is invalid , logging the user out")
                    do {
                        try Auth.auth().signOut()
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                }
              
            })
           
        }
    }
    
    func qrCodeValueAcquired(_ profile: Profile) {
        self.user = profile
        print("family id", profile.familyId)
        self.performSegue(withIdentifier: "sign_up_profile", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let next = segue.destination as? customUITabBarViewController {
            next.viewControllers?.forEach({ controller in
                if let newFeed = controller as? NewFeedViewController {
                    newFeed.profile = self.user
                }
            })
//            next.profile = user
        } else if let next = segue.destination as? SignUpProfileViewController {
            next.adminProfile = user
        }
    }
    
    func afterSignIn(_ user: GIDGoogleUser, firebaseUser: User?) {
        guard let uid = firebaseUser?.uid else {return}
        let db = Firestore.firestore()
        let docRef = db.collection("profiles").document(uid)
        docRef.getDocument { (document, err) in
            if let document = document {
                if document.exists {
                    self.redirect()
                } else {
                    db.collection("families").document(uid).setData([
                        "members": [uid],
                        "name": "",
                        "profile_url": ""
                    ])
                    db.collection("profiles").document(uid).setData([
                        "name": user.profile.name,
                        "profile_status": ProfileStatus.PENDING.rawValue,
                        "account_type": "admin",
                        "guid": uid,
                        "email": firebaseUser?.email ?? "",
                        "family_id": uid
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            self.redirect()
                            print("Document successfully written!")
                        }
                    }
                }
              
            } else {
                print("error in getting document", err ?? "nil")
            }
        }
    }
    
    @objc private func onQrScanClick() {
        
        present(ScannerViewController(), animated: true, completion: nil)
    }
    
    @objc private func onLogInClick() {
        
        present(LoginActionSheetController(), animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if  Auth.auth().currentUser?.uid != nil{
//            self.redirect()
//        } else {
           self.render()
//        }
    }
    
    func render() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        self.view.addSubview(logInButton)
        self.view.addSubview(scanQrCodeButton)
        self.view.addSubview(logo)
        self.view.addSubview(joinNowLabel)
        self.view.addSubview(background)
        self.view.sendSubview(toBack: background)
        let margin = view.layoutMarginsGuide
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        logInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        logInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8, constant: 0).isActive = true
        logo.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3, constant: 0).isActive = true
        scanQrCodeButton.translatesAutoresizingMaskIntoConstraints = false
        scanQrCodeButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 40).isActive = true
        scanQrCodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scanQrCodeButton.heightAnchor.constraint(equalTo: logInButton.heightAnchor, multiplier: 1).isActive = true
        scanQrCodeButton.widthAnchor.constraint(equalTo: logInButton.widthAnchor, multiplier: 1).isActive = true
        
        joinNowLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinNowLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        joinNowLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        joinNowLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        joinNowLabel.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -20).isActive = true
        joinNowLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(joinNowLabelTapped)))
        
        background.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        background.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        background.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
    
    
    

    
}

