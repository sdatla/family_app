import UIKit
import MessageUI
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseStorage




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
    
    
    lazy var name: ProfileTextField = {
        let textField = ProfileTextField()
        textField.borderStyle = .line
        return textField
    }()
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: picker.date)
        birthDate.text = "\(dateString)"
        self.view.endEditing(true)
    }
    let picker = UIDatePicker()
    lazy var birthDate: UITextField = {
        // for the pickers
      
        let textField = UITextField()
         textField.borderStyle = .line
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: true)
        textField.inputAccessoryView = toolbar
        textField.inputView = picker
        picker.datePickerMode = .date
        return textField
    }()
    lazy var role: UITextField = {
        let textField = UITextField()
         textField.borderStyle = .line
        return textField
    }()
    
    let sexOptions = ["-- Select --", "Male", "Female"]
    lazy var sex: DropdownSelection = {
        let dropdown = DropdownSelection()
        let itemPicker = UIPickerView()
        itemPicker.delegate = self
        itemPicker.dataSource = self
        dropdown.inputView = itemPicker
        return dropdown
    }()
    
    lazy var phone: InputIconView = {
       let iconView = InputIconView()
        return iconView
    }()
    
    lazy var email: InputIconView = {
        let iconView = InputIconView()
        return iconView
    }()
    
    lazy var profileTopSection: SignUpImageView = {
        let topSection = SignUpImageView()
        topSection.onCameraTouchCallback = self.setAvatar
        topSection.backgroundColor = UIColor.blue
        topSection.translatesAutoresizingMaskIntoConstraints = false
        return topSection
    }()
    
    
    lazy var nextStep: UIButton = {
        let container = UIButton()
        container.layer.shadowOffset = CGSize(width: 2, height: 2)
        container.layer.shadowRadius = 5
        container.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        container.layer.shadowOpacity = 0.7
        container.setTitle("Next", for: .normal)
        container.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        container.setTitleColor(UIColor.white, for: .normal)
        container.addTarget(self, action: #selector(onDoneClick(_:)), for: .touchUpInside)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var firstGroup: UIStackView = {
        let container = UIStackView(arrangedSubviews: [name, birthDate, role])
        container.axis = .vertical
        container.distribution = .equalSpacing
        container.alignment = .fill
        container.spacing = 20
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var sv: UIScrollView = {
       let scrollView =  UIScrollView()
        scrollView.addSubview(profileTopSection)
        scrollView.addSubview(firstGroup)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.white
        return scrollView
    }()
    
    var inviteView : Bool = false
    var profile: Profile? {
        didSet {
            if profile?.avatar != nil {
                profileTopSection.selectedImage.image = UIImage(data: profile!.avatar!)
                if let img = UIImage(data: profile!.avatar!) {
                   profileTopSection.setImage(img)
                }
            } else if let profileImageUrl = profile?.avatarUrl {
                profileTopSection.selectedImage.loadImageUsingCacheWithUrlString(profileImageUrl) { [weak self] profileImage in
                    self?.profileTopSection.setImage(profileImage)
                }
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
        render()
    }
    private func render() {
        let margin = view.safeAreaLayoutGuide
        view.addSubview(sv)
        view.addSubview(nextStep)
        sv.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        sv.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        sv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sv.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        profileTopSection.topAnchor.constraint(equalTo: sv.topAnchor).isActive = true
        profileTopSection.widthAnchor.constraint(equalTo: sv.widthAnchor, multiplier: 1).isActive = true
        profileTopSection.centerXAnchor.constraint(equalTo: sv.centerXAnchor).isActive = true
        profileTopSection.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        firstGroup.topAnchor.constraint(equalTo: profileTopSection.bottomAnchor, constant: 20).isActive = true
        firstGroup.widthAnchor.constraint(equalTo: sv.widthAnchor, multiplier: 0.9).isActive = true
        firstGroup.centerXAnchor.constraint(equalTo: sv.centerXAnchor).isActive = true
        firstGroup.arrangedSubviews.forEach { $0.heightAnchor.constraint(equalToConstant: 40).isActive = true}
        
        nextStep.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        nextStep.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: 0).isActive = true
        nextStep.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextStep.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
        if let activeFieldPresent = activeField {
            let aRect = self.view.frame
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
    @objc func onDoneClick(_ sender: Any) {
        self.onDone(sender)
    }
}
