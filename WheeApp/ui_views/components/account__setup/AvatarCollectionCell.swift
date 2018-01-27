//
//  AvatarCollectionCell.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 1/14/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit

class AvatarCollectionCell: UICollectionViewCell {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var avatarView: AvatarView!
    
    override func awakeFromNib() {
        avatarView = AvatarView(frame: contentView.frame)
        contentView.addSubview(avatarView)
    }
    
}
