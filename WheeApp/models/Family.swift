//
//  Family.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 4/11/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import Foundation
import Firebase
class Family {
    var members: [Profile]
    var name: String
    var id: String
    var profilePic: Data?
    var profileUrl: String?
    init(_ members: [Profile]?, _ name: String?, _ id: String?) {
        self.members = members ?? []
        self.name = name ?? ""
        self.id = id ?? UUID().uuidString
    }
    static func getFamily(familyId : String, complete: @escaping ((_ family: Family) -> Void)) {
        let family = Firestore.firestore().collection("families").document(familyId)
        family.getDocument { (document, err) in
            if let document = document {
                if !document.exists {return}
                let name = document.data()["name"] as! String
                var members = [Profile]()
                let profiles = Firestore.firestore().collection("profiles").whereField("family_id", isEqualTo: familyId)
                profiles.getDocuments(completion: { (snapshots, err) in
                    guard let snapshots = snapshots else {return}
                    if !snapshots.isEmpty {
                        snapshots.documents.forEach({ (document) in
                            if document.exists {
                                let data = document.data()
                                let profile = Profile()
                                profile.name = data["name"] as? String ?? ""
                                profile.email = data["email"] as? String ?? ""
                                profile.phone = data["phone"] as? String ?? ""
                                profile.role = data["account_type"] as? String ?? ""
                                profile.familyId = data["family_id"] as? String ?? ""
                                members.append(profile)
                            }
                        })
                    } else {
                        
                    }
                    let family = Family(members, name, familyId)
                    print(family.members.count)
                    complete(family)
                })
            }
        }
    }
    func update() {
        let family = Firestore.firestore().collection("families").document(self.id)
        
        family.updateData([
            "name": self.name,
            "members": self.members,
            ]) {err in
                if let err = err {
                    print("error updating the document \(err)")
                } else {
                    print("document updated")
                }
        }
    }
}
