import UIKit
import Firebase

class EmailSignInController: UIViewController {
    lazy var email: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .emailAddress
        textField.placeholder = "Email"
        textField.borderStyle = .line
        return textField
    }()
    
    lazy var password: UITextField = {
        let pw = UITextField()
        pw.placeholder = "Password here"
        pw.borderStyle = .line
        pw.isSecureTextEntry = true
        return pw
    }()
    
    lazy var signupButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign up", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor(displayP3Red: 0, green: 172, blue: 237, alpha: 1)
        btn.addTarget(self, action: #selector(onSignupButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var container: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor.blue
        stackView.addArrangedSubview(email)
        stackView.addArrangedSubview(password)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        render()
        hideKeyboardWhenTappedAround()
    }
    
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 120))
        let navItem = UINavigationItem(title: "Log in")
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    private func render() {
        
        
        let textFieldHeight = 40
        let textFieldSpacing = 20
        let totalHeightForContainer: CGFloat = CGFloat(container.arrangedSubviews.count * (textFieldHeight + textFieldSpacing) - textFieldSpacing)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(container)
        self.view.addSubview(signupButton)
        let margin = view.layoutMarginsGuide
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        
        container.heightAnchor.constraint(equalToConstant: totalHeightForContainer).isActive = true
        container.arrangedSubviews.forEach { (textField) in
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.heightAnchor.constraint(equalToConstant: CGFloat(textFieldHeight)).isActive = true
            textField.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1).isActive = true
        }
        signupButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        signupButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        signupButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -20).isActive = true
        
    }
    
    @objc private func onSignupButtonTapped() {
        if validateInput() {
            signupWithFirebase()
        }
    }
    
    private func validateInput() -> Bool {
        let alert = UIAlertController(title: "Incorrect input", message: "Email can't be empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        if email.text?.trimmingCharacters(in: .alphanumerics).count == 0 {
            self.present(alert, animated: true, completion: nil)
            return false
        } else if password.text?.count == 0 {
            alert.message = "Password can't be empty"
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    private func signupWithFirebase() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            if let error = error {
                self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true, completion: nil)
                return
            }
            // continue the signup flow for the user
        }
    }
}
