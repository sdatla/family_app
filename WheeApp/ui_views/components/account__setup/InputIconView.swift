//
//  InputIconView.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 2/25/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit

@IBDesignable
class InputIconView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let inputHeight = CGFloat(80.0)
    let iconHeight = CGFloat(32.0)
    let paddingBetween = CGFloat(20.0)
    var input: UITextField = {
        let inputfield = UITextField()
        inputfield.isUserInteractionEnabled = true
      
        return inputfield
    }()
    @objc func test() {
        print("test")
    }
    var icon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "icon_phoneInfo"))
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        border.frame = CGRect(x: 0, y: iv.frame.width - width, width: iv.frame.width, height: iv.frame.height)
        border.borderWidth = width
        iv.layer.addSublayer(border)
        iv.layer.masksToBounds = true
        return iv
    }()
    @IBInspectable var image: UIImage? {
        didSet {
            icon.image = image
        }
    }
    @IBInspectable var placeholder: String? {
        didSet {
            input.placeholder = placeholder
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    func addBottomBorderLayer() {
        self.layer.shadowColor = #colorLiteral(red: 0.8784313725, green: 0.8941176471, blue: 0.9137254902, alpha: 1)
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func addLeftBorderLayer() {
        let border = CALayer()
        let width = CGFloat(1.0)
        
        border.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        border.frame = CGRect(x: -paddingBetween / 2, y: (self.frame.height - iconHeight) / 2, width: width, height: iconHeight )
        border.borderWidth = width
        input.layer.addSublayer(border)
    }
    func load() {
        addSubview(icon)
        addSubview(input)
        
        let margin = layoutMarginsGuide
        _ = icon.anchor(margin.centerYAnchor, left: margin.leftAnchor, bottom: nil, right: input.leftAnchor, topConstant: -16, leftConstant: 0, bottomConstant: 0, rightConstant: paddingBetween, widthConstant: 32, heightConstant: 32)
        _ = input.anchor(margin.centerYAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: -(inputHeight / 2), leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: inputHeight)
        self.addBottomBorderLayer()
         self.addLeftBorderLayer()
    }
}
