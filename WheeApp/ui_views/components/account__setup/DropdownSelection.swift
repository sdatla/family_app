//
//  DropdownSelection.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 2/25/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit

class DropdownSelection: ProfileTextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let arrow: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "icon_arrow"))
        imageView.frame = CGRect(x: imageView.frame.midX, y: imageView.frame.midY, width: 12, height: 8)
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    private func render() {
        self.rightViewMode = .always
        self.rightView = arrow
    }
}
