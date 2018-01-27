//
//  profileInput.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 11/15/17.
//  Copyright © 2017 Leung Wai Chan. All rights reserved.
//

import Foundation

@IBDesignable
class ProfileTextField: UITextField {
    @IBInspectable var bottomBorder: Bool = true {
        didSet {
            if bottomBorder {
                setBottomBorder()
            } else {
                self.layer.shadowOpacity = 0
            }
        }
    }
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0);
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func setBottomBorder() {
        self.backgroundColor = UIColor.white
        self.layer.shadowColor = #colorLiteral(red: 0.8784313725, green: 0.8941176471, blue: 0.9137254902, alpha: 1)
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
}
