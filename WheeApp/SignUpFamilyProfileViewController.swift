//
//  SignUpFamilyProfileViewController.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 11/18/17.
//  Copyright © 2017 Leung Wai Chan. All rights reserved.
//

import UIKit
import CoreData

struct presetAvatar {
    let Spouse = "spouse"
    let Kid = "kid"
    let Pet = "pet"
}

let AVATAR_ID = presetAvatar()

class SignUpFamilyProfileViewController:
    UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
//    @IBOutlet weak var currentUserName: UILabel!
//    @IBOutlet weak var spouseName: UILabel!
//    @IBOutlet weak var kidName: UILabel!
//    @IBOutlet weak var petName: UILabel!
    var guid: String?
    var familyId: String?
    var constraints = [NSLayoutConstraint]()
    var profileStatus = "PENDING"
    var family: Family?
    @IBOutlet weak var familyName: UITextField!
    
    @IBOutlet weak var doneButtonContainer: UIView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileTopSection: SignUpImageView! {
        didSet {
            if let profile = profile {
//                if let imageData = profile.family?.image {
//                    let image = UIImage(data: imageData)
//                    profileTopSection?.image = image
//                }
            }
        }
    }
    @IBOutlet weak var iconQRCode: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(createQrCode))
            iconQRCode.isUserInteractionEnabled = true
            iconQRCode.addGestureRecognizer(tapGestureRecognizer)
            
        }
    }
    
    var profile: Profile? {
        didSet {
            if let family = self.family {
                familyName?.text = family.name
//                if let imageData = profile.family?.image {
//                    let image = UIImage(data: imageData)
//                    profileTopSection?.setImage(image!)
//                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        profileTopSection.onCameraTouchCallback = self.setAvatar
        hideKeyboardWhenTappedAround()
        print(profile!.familyId!)
        Family.getFamily(familyId: profile!.familyId!) { [unowned self] family in
            self.family = family
            self.collectionView.reloadData()
        }
    }
    
    func onDone(_ sender: Any) {
        self.addUserInputs()
        self.performSegue(withIdentifier: "to_home_page", sender: sender)
    }
    
    func setAvatar(_ sender: Any) {
        let imagePickerView = UIImagePickerController()
        
        imagePickerView.delegate = self
        imagePickerView.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerView.allowsEditing = false
        self.present(imagePickerView, animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileTopSection.setImage(image)
        }
        self.dismiss(animated: false)
    }
    
    
    @IBAction func onPlusButtonTouch(_ sender: Any) {
        self.performSegue(withIdentifier: "invite_member", sender: sender)
    }
    
    private func addUserInputs() {
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setupCollectionView()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (family?.members.count ?? 0) + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "avatar_cell", for: indexPath) as! AvatarCollectionCell
        cell.awakeFromNib()
        // plus icons
        if indexPath.row == (family?.members.count ?? 0) {
            cell.avatarView.button.setImage(UIImage(named: "plus_icon"), for: .normal)
            cell.avatarView.textLabel.text = "more"
            cell.avatarView.button.addTarget(self, action: #selector(onPlusButtonTouch), for: .touchUpInside)
            return cell
        }
        let data = family?.members ?? []
        let user: Profile = data[indexPath.row]
        if let avatarData = user.avatar {
            cell.avatarView.button.setImage(UIImage(data: avatarData), for: .normal)
        }

        cell.avatarView.textLabel.text = user.name ?? ""
        
        return cell
    }
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AvatarCollectionCell.self, forCellWithReuseIdentifier: "avatar_cell")
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        collectionView.layer.removeAllAnimations()
        collectionViewHeightConstraint.constant = collectionView.contentSize.height
        UIView.animate(withDuration: 0.5) {
            self.collectionView.updateConstraints()
            self.collectionView.layoutIfNeeded()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let next = segue.destination as? SignUpProfileViewController {
            next.inviteView = true
            next.adminProfile = profile
        } else if let next = segue.destination as? customUITabBarViewController {
            profile?.profileStatus = ProfileStatus.DONE.rawValue
            if let barVC = segue.destination as? UITabBarController {
                barVC.viewControllers?.forEach {
                    if let vc = $0 as? NewFeedViewController {
                        print("new feed view controller")
                        vc.profile = self.profile
                    }
                }
            }
        }
        self.profile?.updateProfile(nil)
//        self.family?.update()
    }
    
    func _setupCircleButton(button: UIView) {
    
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        button.layer.cornerRadius = button.frame.width / 2
       
    }
    @IBAction func onDoneClick(_ sender: Any) {
        self.onDone(sender)
    }
    
    @objc func createQrCode(tapGestureRecognizer: UITapGestureRecognizer) {
        let modalViewController = ModalViewController()
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.name = profile?.name
        modalViewController.familyId = "whee_" + self.family!.id
        present(modalViewController, animated: true, completion: nil)
    }
}
class ModalViewController: UIViewController {
    var familyId: String?
    let qrCodeImage: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = UIColor.white
        return img
        
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: "HelveticaNeue", size: 26)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ask your family memebers to scan this QR Code to join"
        label.textColor = UIColor.white
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(nameLabel)
        view.addSubview(qrCodeImage)
        view.addSubview(descriptionLabel)
        setQRCode()
            qrCodeImage.translatesAutoresizingMaskIntoConstraints = false
            qrCodeImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            qrCodeImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            qrCodeImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        qrCodeImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        nameLabel.anchorWithConstantsToTop(nil, left: view.leftAnchor, bottom: qrCodeImage.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20)
        descriptionLabel.anchorWithConstantsToTop(qrCodeImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goBack))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
//
    }
    private func setQRCode() {
        qrCodeImage.image = generateQRCode(from: self.familyId!)
    }
    @objc private func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
