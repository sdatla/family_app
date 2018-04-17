//
//  SignUpImageView.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 1/14/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit

class SignUpImageView: UIView {
    var cameraIcon: UIImageView?
    var onCameraTouchCallback: ((Any) -> ())?
    private let grad = CAGradientLayer()
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var selectedImage: UIImageView! {
        didSet {
            selectedImage.mask = mv
            cameraIcon = UIImageView(image: UIImage(named: "edit photo"))
            selectedImage.addSubview(cameraIcon!)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            
            selectedImage.isUserInteractionEnabled = true
            selectedImage.addGestureRecognizer(tapGestureRecognizer)
            
        }
    }
    @IBAction func onCameraTouch(_ sender: UIButton) {
        
        self.onCameraTouchCallback!(sender)
    }
    var image: UIImage? {
        didSet {
            selectedImage.image = image
            grad.removeFromSuperlayer()
        }
    }
    
    var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    let mv: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "profileFrame")
        iv.contentMode = .scaleToFill
        
        return iv
    }()
    
    func removeGrad() {
        grad.removeFromSuperlayer()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "SignUpImageView", bundle: bundle).instantiate(withOwner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
    }
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.onCameraTouchCallback?(tapGestureRecognizer)
    }
    private func updateView() {
        if let img = selectedImage {
            grad.colors = [firstColor.cgColor, secondColor.cgColor]
            grad.frame = contentView.bounds
            grad.zPosition = -1
            img.layer.addSublayer(grad)
            cameraIcon!.frame = CGRect(x: contentView.bounds.width / 2 - (cameraIcon?.image?.size.width)! / 2, y: selectedImage.bounds.height / 2 - (cameraIcon?.image?.size.height)! / 2, width: (cameraIcon?.image?.size.width)!, height: (cameraIcon?.image?.size.height)!)
        }
    }
  
    public func setImage(_ img: UIImage) {
        selectedImage.image = img
        grad.removeFromSuperlayer()
        cameraIcon?.removeFromSuperview()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        mv.frame = contentView.bounds
        updateView()
    }
}
