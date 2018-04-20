
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase

class LoginActionSheetController: UIAlertController, GIDSignInDelegate, GIDSignInUIDelegate {
    var delegate: SignInViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addAction(UIAlertAction(title: "Email and Password", style: .default, handler: self.handleEmailLogin))
        self.addAction(UIAlertAction(title: "Log in with Facebook", style: .default, handler: self.handleFacebookLogin))
        self.addAction(UIAlertAction(title: "Log in with Google", style: .default, handler: self.handleGoogleLogin))
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: self.goBack))
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    private func handleEmailLogin(action: UIAlertAction) {
        print("email Log in")
        delegate?.present(EmailSignInController(), animated: true, completion: nil)
        
    }
    
    private func handleFacebookLogin(action: UIAlertAction) {
        print("fb Log in")
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    
    func getFBUserData(){
        let accessToken = FBSDKAccessToken.current()
        
        if((accessToken) != nil){
            
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken!.tokenString)
            
            Auth.auth().signIn(with: credentials, completion: {(user, error) in
                if error != nil {
                    print("someting when wrong with facebook auth", error ?? "")
                    return
                }
                
                print("Successfully logged into facebook", user ?? "")
            })
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print("working!")
                }
            })
        }
    }
    
    private func handleGoogleLogin(action: UIAlertAction) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    private func goBack(action: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            guard let auth = user.authentication else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
            Auth.auth().signIn(with: credential) {(user, error) in
                if let error = error {
                    print(error)
                } else {
                    print("Successfully logged via google", user ?? "")
//                    guard let user = user else {return}
//                    Profile.getProfile(id: user.uid, complete: { profile in
//                        if let existingProfile = profile {
//                        // redirect home page or profile sign up page
//                            if existingProfile.profileStatus == ProfileStatus.PENDING.rawValue {
//                                self.goToProfileSignUpPage(existingProfile)
//                            } else {
//                                print("user shoudl go to home page")
//                            }
//                        } else {
//                            let newProfile = Profile(user)
//                            newProfile.familyId = user.uid
//                            let newFamily = Family([newProfile], "", newProfile.familyId!)
//                            newProfile.updateProfile() {[weak self] in self?.goToProfileSignUpPage(newProfile)}
//                            newFamily.update()
//                        }
//                    })
                }
            }
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
}
