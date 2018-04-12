import UIKit
import MessageUI
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseStorage

class Profile {
    var avatar: Data?
    var avatarUrl: String?
    var name: String?
    var email: String?
    var phone: String?
    var role: String?
    var familyId: String?
    var guid: String?
    var profileStatus: String?
    var isAnonymous: Bool?
    init() {
        
    }
    
    init(_ user: User) {
        name = user.displayName
        email = user.email
        isAnonymous = user.isAnonymous
        guid = user.uid
        phone = user.phoneNumber
        profileStatus = ProfileStatus.PENDING.rawValue
    }
    
    static func getCurrenetUser(completion: @escaping ((_ result: Profile) ->Void)) {
        if Profile.isCurrentUserLoggedIn() {
            Profile.getProfile(id: Auth.auth().currentUser!.uid, complete: completion)
        }
    }
    
    static func isCurrentUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func createProfileInDatabase() {
        guard let guid = self.guid else {return}
        let profile = Firestore.firestore().collection("profiles").document(guid)
        
        let data = [
            "name": self.name ?? "",
            "email": self.email ?? "",
            "phone": self.phone ?? "",
            "account_type": self.phone ?? "",
            "family_id": self.familyId ?? "",
            "profile_status": self.profileStatus ?? ProfileStatus.PENDING.rawValue
        ]
        profile.setData(data) {err in
            if let err = err {
                print("error updating the document \(err)")
            } else {
                print("document updated")
            }
        }
    }
    
    func updateProfile(_ callback: (() -> Void)?) {
        guard let guid = self.guid else {return}
        let profile = Firestore.firestore().collection("profiles").document(guid)
        if let avatar = self.avatar {
            let storageRef = Storage.storage().reference()
            let profileImageRef = storageRef.child("images/\(guid)_profile_image")
            profileImageRef.putData(avatar, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("something wrong with profile image upload\(error!)")
                    return
                }
                if let url = metadata.downloadURL()?.absoluteString {
                    profile.updateData(["profile_image_url": url])
                }
            }
        }
        
        let data = [
            "name": self.name ?? "",
            "email": self.email ?? "",
            "phone": self.phone ?? "",
            "account_type": self.phone ?? "",
            "family_id": self.familyId ?? "",
            "profile_status": self.profileStatus ?? ProfileStatus.PENDING.rawValue
        ]
        
        profile.updateData(data) {err in
            if let err = err {
                print("error updating the document \(err)")
            } else {
                print("document updated")
                guard let cb = callback else {return}
                cb()
            }
        }
    }
    
    static func getProfile(id: String, complete: @escaping (_ profile: Profile) -> Void) {
        let db =  Firestore.firestore()
        db.collection("profiles").document(id).getDocument(completion: {(document, err) in
            if err != nil {
                print(err ?? "error")
                return
            }
            guard let document = document else {return}
            
            if document.exists {
                let data = document.data()
                let profile = Profile()
                profile.name = data["name"] as? String ?? ""
                profile.email = data["email"] as? String ?? ""
                profile.phone = data["phone"] as? String ?? ""
                profile.role = data["account_type"] as? String ?? ""
                profile.familyId = data["family_id"] as? String ?? ""
                profile.guid = id
                complete(profile)
            }
        })
    }
}

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
class SignUpProfileViewController: UIViewController,
    MFMessageComposeViewControllerDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.sexOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.sexOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            sex.text = sexOptions[row]
            self.view.endEditing(false)
        }
       
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var name: ProfileTextField!
    @IBOutlet weak var birthDate: UITextField!
    @IBOutlet weak var sex: DropdownSelection!
    @IBOutlet weak var role: UITextField!
    @IBOutlet weak var phone: InputIconView!
    @IBOutlet weak var email: InputIconView!
    @IBOutlet weak var profileTopSection: SignUpImageView! {
        didSet {
//            profileTopSection.selectedImage.image = #imageLiteral(resourceName: "profile_placeholder")
        }
    }
    
    @IBOutlet weak var doneButtonContainer: UIView!
    @IBOutlet weak var sv: UIScrollView!
    let picker = UIDatePicker()
    let itemPicker = UIPickerView()
    var sexOptions = ["-- Select --", "Male", "Female"]
    var inviteView : Bool = false
    var profile: Profile? {
        didSet {
            if profile?.avatar != nil {
                profileTopSection.selectedImage.image = UIImage(data: profile!.avatar!)
            }
            name.text = profile?.name ?? ""
            phone.input.text = profile?.phone ?? ""
            email.input.text = profile?.email ?? ""
        }
    }
    var adminProfile: Profile?
    var guid = NSUUID().uuidString
    var activeField: UITextField?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTopSection.onCameraTouchCallback = self.setAvatar
        doneButtonContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        doneButtonContainer.layer.shadowRadius = 5
        doneButtonContainer.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        doneButtonContainer.layer.shadowOpacity = 0.7
        createItemPicker()
        createDatePicker()
        hideKeyboardWhenTappedAround()
        observeKeyboardNotifications()
        if !inviteView {
            if let profile = adminProfile {
                self.profile = profile
            } else {
               setProfileFromDeviceOwner()
            }
         
        } else {
            setProfileFromInvite()
        }
        
    }
    
    func save() {
        if let profile = profile {
            profile.name = name.text ?? ""
            profile.phone = phone.input.text ?? ""
            profile.email = email.input.text ?? ""
            profile.role = role.text ?? ""
            if let avatar = profileTopSection.selectedImage.image {
                if let imageData = UIImageJPEGRepresentation(avatar, 1) {
                      profile.avatar = imageData
                }
            }
            
            if inviteView {
//                adminProfile!.family?.addToProfiles(profile)
            }
            
            profile.updateProfile(nil)
        }
    }
    
    func setProfileFromDeviceOwner() {
        Profile.getCurrenetUser {[unowned self] Profile in
            self.profile = Profile
            self.adminProfile = Profile
        }
    }
    
    func setProfileFromInvite() {
        let inviteButton = UIButton()
        inviteButton.setTitle("Invite", for: .normal)
        inviteButton.setTitleColor(UIColor.white, for: .normal)
        inviteButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        inviteButton.addTarget(self, action: #selector(sendInvite), for: .touchUpInside)
        self.view.addSubview(inviteButton)
        _ = inviteButton.anchor(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 50)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: true)
        birthDate.inputAccessoryView = toolbar
        birthDate.inputView = picker
        picker.datePickerMode = .date
    }
    
    // for the pickers
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: picker.date)
        birthDate.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    private func createItemPicker() {
        itemPicker.delegate = self
        itemPicker.dataSource = self
        sex.inputView = itemPicker
    }
    
    
    
    func setAvatar(_ sender: Any) {
        let imagePickerView = UIImagePickerController()
        
        imagePickerView.delegate = self
        imagePickerView.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerView.allowsEditing = true
        self.present(imagePickerView, animated: true) {}
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileTopSection.setImage(image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileTopSection.setImage(image)
        }
        self.dismiss(animated: false)
    }
    
    @objc func sendInvite(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            controller.body = "Hi guys, I found an awesome app for our faily called Whee!. Use this family code: XXXXXX to log in. http://itunes.apple.com/us/app/wheeapp/id123456"
            //            controller.recipients = [(profile?.phone)!]
            self.present(controller, animated: true, completion:  nil)
        } else {
            let errorAlert = UIAlertController(title: "Cannot send mesesage", message: "Your device doesn't support SMS", preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil)
            errorAlert.addAction(okAction)
            self.present(errorAlert, animated: true, completion: nil)
            
        }
    }
    
    private func onDone(_ sender: Any) {
        performSegue(withIdentifier: "to_family_profile", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.save()
        if let next = segue.destination as? SignUpFamilyProfileViewController {
            next.profile = adminProfile
        }
    }
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardHide(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, -20, 0)
        self.sv.contentInset = contentInsets
        self.sv.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardShow(notification: NSNotification) {
        let keyboardHeight = getKeyboardHeight(notification: notification)
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 20, 0)
        self.sv.contentInset = contentInsets
        self.sv.scrollIndicatorInsets = contentInsets
        var aRect = self.view.frame
        if let activeFieldPresent = activeField {
            if (!aRect.contains(activeFieldPresent.frame.origin)) {
                self.sv.scrollRectToVisible(aRect, animated: true)
            }
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    @IBAction func onDoneClick(_ sender: Any) {
        self.onDone(sender)
    }
}
