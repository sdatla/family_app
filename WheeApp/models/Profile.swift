//
//  Profile.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 4/11/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
class Profile {
    var avatar: Data?
    var avatarUrl: String?
    var name: String?
    var email: String?
    var phone: String?
    var role: String?
    var familyId: String?
    var guid: String?
    var profileStatus: String?
    var isAnonymous: Bool?
    init() {
        
    }
    
    init(_ user: User) {
        name = user.displayName
        email = user.email
        isAnonymous = user.isAnonymous
        guid = user.uid
        phone = user.phoneNumber
        profileStatus = ProfileStatus.PENDING.rawValue
    }
    
    init(_ data: [String: Any?]) {
        name = data["name"] as? String ?? ""
        email = data["email"] as? String ?? ""
        phone = data["phone"] as? String ?? ""
        role = data["account_type"] as? String ?? ""
        familyId = data["family_id"] as? String ?? ""
        avatarUrl = data["profile_image_url"] as? String
        profileStatus = data["profile_status"] as? String ?? ProfileStatus.PENDING.rawValue
    }
    
    static func getCurrenetUser(completion: @escaping ((_ result: Profile?) ->Void)) {
        if Profile.isCurrentUserLoggedIn() {
            Profile.getProfile(id: Auth.auth().currentUser!.uid, complete: completion)
        }
    }
    
    func getProfileAsDictionary() -> [String: Any]{
        return [
            "name": self.name ?? "",
            "email": self.email ?? "",
            "phone": self.phone ?? "",
            "account_type": self.phone ?? "",
            "family_id": self.familyId ?? "",
            "profile_status": self.profileStatus ?? ProfileStatus.PENDING.rawValue
        ]
    }
    
    static func isCurrentUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func createProfileInDatabase() {
        guard let guid = self.guid else {return}
        let profile = Firestore.firestore().collection("profiles").document(guid)
        profile.setData(getProfileAsDictionary()) {err in
            if let err = err {
                print("error updating the document \(err)")
            } else {
                print("document updated")
            }
        }
    }
    
    func updateProfile(_ callback: (() -> Void)?) {
        guard let guid = self.guid else {return}
        let profile = Firestore.firestore().collection("profiles").document(guid)
        if let avatar = self.avatar {
            if self.avatarUrl == nil {
                let storageRef = Storage.storage().reference()
                let profileImageRef = storageRef.child("images/\(guid)_profile_image")
                profileImageRef.putData(avatar, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        print("something wrong with profile image upload\(error!)")
                        return
                    }
                    if let url = metadata.downloadURL()?.absoluteString {
                        profile.updateData(["profile_image_url": url]) {error in
                            if error != nil {
                                print("error with updating the profile image url \(error!)")
                                return
                            }
                            
                            print("added profile_image_url", url)
                        }
                    }
                }
            }
        }
        
        profile.updateData(getProfileAsDictionary()) {err in
            if let err = err {
                print("error updating the document \(err)")
            } else {
                print("document updated")
                guard let cb = callback else {return}
                cb()
            }
        }
    }
    
    static func getProfile(id: String, complete: @escaping (_ profile: Profile?) -> Void) {
        let db =  Firestore.firestore()
        db.collection("profiles").document(id).getDocument(completion: {(document, err) in
            if err != nil {
                print(err ?? "error")
                return
            }
            guard let document = document else {return}
            
            if document.exists {
                let profile = Profile(document.data())
                profile.guid = id
                complete(profile)
            } else {
                complete(nil)
            }
        })
    }
}
