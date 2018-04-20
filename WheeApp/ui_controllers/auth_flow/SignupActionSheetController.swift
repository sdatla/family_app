
import UIKit
import Firebase
import FirebaseDatabase

protocol SignupActionsheetDelegate {}
class SignUpActionSheetController: UIAlertController, GIDSignInDelegate, GIDSignInUIDelegate {
    var delegate: SignInViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.addAction(UIAlertAction(title: "Sign up via phone", style: .default, handler: self.handlePhoneNumberSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Email", style: .default, handler: self.handleEmailSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Facebook", style: .default, handler: self.handleFacebookSignUp))
        self.addAction(UIAlertAction(title: "Sign up via Google", style: .default, handler: self.handleGoogleSignUp))
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: self.goBack))
         GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
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
        GIDSignIn.sharedInstance().signIn()
    }
    
    private func goBack(action: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            guard let auth = user.authentication else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
            Auth.auth().signIn(with: credential) {(user, error) in
                if let error = error {
                    print(error)
                } else {
                        guard let user = user else {return}
                        Profile.getProfile(id: user.uid, complete: { profile in
                            if let existingProfile = profile {
                                // redirect home page or profile sign up page
                                if existingProfile.profileStatus == ProfileStatus.PENDING.rawValue {
                                    self.goToProfileSignUpPage(existingProfile)
                                } else {
                                    print("user shoudl go to home page")
                                }
                            } else {
                                let newProfile = Profile(user)
                                newProfile.familyId = user.uid
                                let newFamily = Family([newProfile], "", newProfile.familyId!)
                                newProfile.updateProfile() {[weak self] in self?.goToProfileSignUpPage(newProfile)}
                                newFamily.update()
                            }
                        })
                }
            }
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    private func goToProfileSignUpPage(_ profile: Profile) {
        let profieSignupPage = SignUpProfileViewController()
        profieSignupPage.profile = profile
        delegate?.present(profieSignupPage, animated: true, completion: nil)
    }
    
    private func goToHomePage(_ profile: Profile) {
        let homePage = NewFeedViewController()
        homePage.profile = profile
        delegate?.present(homePage, animated: true, completion: nil)
    }
}
