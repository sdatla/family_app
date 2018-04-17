//
//  Avatar.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 1/13/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit

class AvatarView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "AvatarView", bundle: bundle).instantiate(withOwner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        button.imageView?.layer.cornerRadius = (button.imageView?.frame.width)! / 2
    }
}
