
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginActionSheetController: UIAlertController, GIDSignInDelegate {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addAction(UIAlertAction(title: "Email and Password", style: .default, handler: self.handleEmailLogin))
        self.addAction(UIAlertAction(title: "Log in with Facebook", style: .default, handler: self.handleFacebookLogin))
        self.addAction(UIAlertAction(title: "Log in with Google", style: .default, handler: self.handleGoogleLogin))
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: self.goBack))
        GIDSignIn.sharedInstance().delegate = self
    }
    
    private func handleEmailLogin(action: UIAlertAction) {
        print("email Log in")
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
                        print("hello")
                    }
                }
            }
        }
        
        func getFBUserData(){
            if((FBSDKAccessToken.current()) != nil){
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        //everything works print the user data
                        print(result)
                    }
                })
            }
        }
        
    
    private func handleGoogleLogin(action: UIAlertAction) {
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    private func goBack(action: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
       print("signed")
    }
}
