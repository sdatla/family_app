//
//  NewFeedViewController.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 2/3/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit
import CoreData
import Firebase
class NewFeedViewController:
UIViewController, UITableViewDelegate, UITableViewDataSource, statusUpdateModalDelegate{
    
    @IBOutlet weak var feedsTableView: UITableView!
    
    var mocks = [Message]()
    let cellId = "card_table_cell"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mocks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! FeedCell
        let m = mocks[indexPath.row]
        cell.title.text = m.title
        cell.content.text = m.html
        return cell
    }
    
    let logoutButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 50, width: 150, height: 50))
        btn.setTitle("Log out", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        return btn;
    }()
    var profile: Profile? = nil
    
    @IBOutlet weak var postStatusButton: UIButton!
    
    @IBAction func onStatusUpdateClick(_ sender: Any) {
        openStatusUpdateModal()
    }
    @IBOutlet weak var todayDate: UILabel! {
        didSet {
            todayDate.text = getTodayDate()
        }
    }
    @IBOutlet weak var greet: UILabel! {
        didSet {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "cccc"
            greet.text = "Happy " +  dateformatter.string(from: Date()) + "!"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoutButton)
        
        logoutButton.addTarget(self, action: #selector(self.logBtnTouched), for: .touchUpInside)
        
        feedsTableView.delegate = self
        feedsTableView.dataSource = self
        feedsTableView.register(FeedCell.self, forCellReuseIdentifier: cellId)
        syncData()
        
        postStatusButton.backgroundColor = UIColor.white
        postStatusButton.setTitleColor(UIColor.gray, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    func syncData() {
        if Auth.auth().currentUser?.uid == nil {
            signout()
        } else {
            guard let profile = self.profile else {
                print("profile is not set")
                return
            }
            let db = Firestore.firestore()
            let feeds = db.collection("messages")
                .whereField("sender_family", isEqualTo: profile.familyId!)
                .whereField("type", isEqualTo: "FEED")
            feeds.addSnapshotListener { (querySnapshots, error) in
                guard let documents = querySnapshots?.documents else {
                    print("Error fetching the documents \(error!)")
                    return
                }
                self.mocks = documents.reduce([Message](), { (res, data) -> [Message] in
                   return  res + [Message(data)]
                })
                self.feedsTableView.reloadData()
            }
        }
    }

    @objc func logBtnTouched() {
      signout()
    }
    
    private func signout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        performSegue(withIdentifier: "to_login", sender: nil)
    }
    
    private func getTodayDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter.string(from: date)
    }
    

    func openStatusUpdateModal() {
        let modal = StatusUpdateModalViewController()
        modal.delegate = self
        modal.modalPresentationStyle = .overCurrentContext
        present(modal, animated: true, completion: nil)
    }
    func onPostingStatus(_ content: String) {
        let msg = Firestore.firestore().collection("messages")
        
        msg.addDocument(data: [
            "html": content,
            "title": getTodayDate(),
            "sender_family": profile!.familyId ?? "",
            "type": "FEED",
            "sender": profile!.guid ?? ""
        ])
    }
}

class FeedCell: UITableViewCell {
    lazy var avatar: UIImageView = {
        let img = UIImage(named: "avatar_template")
        let imgView = UIImageView(image: img)
        imgView.layer.cornerRadius = 20
        imgView.layer.masksToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var content: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(avatar)
        avatar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        avatar.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        avatar.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addSubview(title)
        title.leftAnchor.constraint(equalTo: avatar.rightAnchor, constant: 8).isActive = true
        title.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        title.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 8).isActive = true
        addSubview(content)
        content.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8).isActive = true
        content.leftAnchor.constraint(equalTo: avatar.rightAnchor, constant: 8).isActive = true
        content.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
protocol statusUpdateModalDelegate {
    func onPostingStatus(_ content: String)
}
class StatusUpdateModalViewController : UIViewController {
    lazy var cameraButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "icon_camera"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    lazy var saveButton : UIButton = {
        let button = UIButton();
        button.setTitle("save name", for: .normal);
        button.backgroundColor = UIColor.blue;
        // add 'click event' to button
        return button;
    }();
    lazy var status: UITextField = {
        let input = UITextField()
        input.placeholder = "How about a Sunday picnic?"
        input.translatesAutoresizingMaskIntoConstraints = false
        input.backgroundColor = UIColor.white
        return input
    }()
    lazy var avatar: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar_template"))
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var lineDivider: UIView = {
        let hr = UIView()
        hr.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        hr.translatesAutoresizingMaskIntoConstraints = false
        return hr
    }()
    
    lazy var postButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Post", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(onPostButtonClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(avatar)
        v.addSubview(status)
        v.addSubview(lineDivider)
        v.addSubview(cameraButton)
        v.addSubview(postButton)
        return v
    }()
    
    
    var delegate : statusUpdateModalDelegate?
    
    override func viewDidLayoutSubviews() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = container.frame
        rectShape.position = container.center
        rectShape.path = UIBezierPath(roundedRect: container.bounds, byRoundingCorners: [.topRight , .topLeft], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        container.layer.mask = rectShape
    }
    
    override func viewDidLoad() {
        let padding = CGFloat(8)
        let height = CGFloat(40)
        super.viewDidLoad()
       
          self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.3)
        self.view.addSubview(container)
      
        let margins = view.layoutMarginsGuide
        
        container.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
//        container.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.2).isActive = true
        container.heightAnchor.constraint(greaterThanOrEqualTo: self.view.heightAnchor, multiplier: 0.2, constant: 0).isActive = true
       
        avatar.leftAnchor.constraint(equalTo: container.leftAnchor, constant: (padding)).isActive = true
        avatar.topAnchor.constraint(equalTo: container.topAnchor, constant: (padding)).isActive = true
        avatar.widthAnchor.constraint(equalToConstant: (height)).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: (height)).isActive = true

        status.topAnchor.constraint(equalTo: container.topAnchor, constant: padding).isActive = true
        status.leftAnchor.constraint(equalTo: avatar.rightAnchor, constant: padding).isActive = true
        status.rightAnchor.constraint(equalTo: container.rightAnchor, constant: padding).isActive = true
        status.heightAnchor.constraint(greaterThanOrEqualTo: avatar.heightAnchor).isActive = true

        lineDivider.topAnchor.constraint(equalTo: status.bottomAnchor, constant: padding).isActive = true
        lineDivider.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: 0).isActive = true
        lineDivider.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1).isActive = true
        lineDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true

        cameraButton.topAnchor.constraint(equalTo: lineDivider.bottomAnchor, constant: padding).isActive = true
        cameraButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: (padding)).isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        postButton.centerYAnchor.constraint(equalTo: cameraButton.centerYAnchor).isActive = true
        postButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding).isActive = true
         setupBack()
        observeKeyboardNotifications()
    }
    
    @objc func onPostButtonClick() {
        if var text = status.text {
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.count > 0 {
                self.delegate?.onPostingStatus(text)
            }
        }
    }
    func setupBack() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(back)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    @objc func keyboardHide(notification: NSNotification) {
       self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    @objc func keyboardShow(notification: NSNotification) {
        let keyboardHeight = getKeyboardHeight(notification: notification)
        var aRect = self.view.frame
        self.view.frame = CGRect(x: 0, y: -keyboardHeight, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
