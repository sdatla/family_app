
import UIKit


class LoginActionSheetController: UIAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addAction(UIAlertAction(title: "Log in via phone", style: .default, handler: self.handlePhoneNumberLogin))
        self.addAction(UIAlertAction(title: "Log in via Email", style: .default, handler: self.handleEmailLogin))
        self.addAction(UIAlertAction(title: "Log in via Facebook", style: .default, handler: self.handleFacebookLogin))
        self.addAction(UIAlertAction(title: "Log in via Google", style: .default, handler: self.handleGoogleLogin))
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: self.goBack))
    }
    
    private func handlePhoneNumberLogin(action: UIAlertAction) {
        print("phone Log in")
    }
    
    private func handleEmailLogin(action: UIAlertAction) {
        print("email Log in")
    }
    
    private func handleFacebookLogin(action: UIAlertAction) {
        print("fb Log in")
    }
    
    private func handleGoogleLogin(action: UIAlertAction) {
        print("google Log in")
    }
    
    private func goBack(action: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
    }
}
