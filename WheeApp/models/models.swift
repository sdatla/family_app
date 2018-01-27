//
//  models.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 4/7/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import Foundation
import Firebase
struct Message {
    let type: String
    let sender: String
    let html: String
    let title: String
    
    init(_ data: DocumentSnapshot) {
        self.type = data["type"] as! String
        self.sender = data["sender"] as! String
        self.html = data["html"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
    }
}
