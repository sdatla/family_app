//
//  credential.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 2/3/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import Foundation
import CoreData
import Firebase

//extension Credential {
//    static func isUserLoggedIn() -> Bool {
//        return Auth.auth().currentUser?.uid != nil
//    }
//    
//
//    
//    public func saveGoogleOauthData(_ moc: NSManagedObjectContext,_ user: GIDGoogleUser) {
//        
////        print("google", user.authentication.idTokenExpirationDate)
////        print("now", Date())
////        print(user.authentication.idTokenExpirationDate > Date())
//        
//        self.setValue(user.userID, forKey: "guid")
//        self.setValue(user.authentication.accessToken, forKey: "access_token")
//        self.setValue(user.authentication.accessTokenExpirationDate as NSDate, forKey: "access_token_expired_date")
//        self.setValue(user.authentication.idToken, forKey: "id_token")
//        self.setValue(user.authentication.idTokenExpirationDate as NSDate, forKey: "id_token_expired_date")
//        self.setValue(user.authentication.refreshToken, forKey: "refresh_token")
//        self.setValue("google", forKey: "type")
//    }
//    
//    static public func signout(_ moc: NSManagedObjectContext) {
//        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Credential")
//        let credentials = try! moc.fetch(req) as! [Credential]
//        
//        if credentials.count > 0{
//            for c in credentials {
//                moc.delete(c)
//            }
//        }
//        
//        do {
//            try moc.save()
//        } catch let error as NSError {
//            print("Could not save on #logout. \(error)")
//        }
//    }
//    
//}

