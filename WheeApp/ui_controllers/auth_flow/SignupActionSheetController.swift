
import UIKit
protocol SignupActionsheetDelegate {}
class SignUpActionSheetController: UIAlertController {
    var delegate: SignInViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addAction(UIAlertAction(title: "Sign up via phone", style: .default, handler: self.handlePhoneNumberSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Email", style: .default, handler: self.handleEmailSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Facebook", style: .default, handler: self.handleFacebookSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Google", style: .default, handler: self.handleGoogleSignUp))
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: self.goBack))
    }
    
    private func handlePhoneNumberSignUp(action: UIAlertAction) {
        print("phone sign up")
    }
    
    private func handleEmailSignUp(action: UIAlertAction) {
        delegate?.present(EmailSignUpController(), animated: true, completion: nil)
    }
    
    private func handleFacebookSignUp(action: UIAlertAction) {
        print("fb sign up")
    }
    
    private func handleGoogleSignUp(action: UIAlertAction) {
        print("google sign up")
    }
    
    private func goBack(action: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
    }
}
