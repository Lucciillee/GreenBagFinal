

import UIKit
import RealmSwift
class SigninVC: UIViewController {
    
    
    @IBOutlet weak var emailTextField: CustomTextField!
    
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    @IBAction func signinAsUserPressed(_ sender: Any) {
        checkEmptyFields()
        authenticateUser(role: "user", storyboardName: "UserScreens", viewControllerIdentifier: "HomeVCTabBar")
    }
    
    @IBAction func signinAsStorePressed(_ sender: Any) {
        checkEmptyFields()
        authenticateUser(role: "store", storyboardName: "StoreScreens", viewControllerIdentifier: "StoreTabBarVC")
    }
    
    @IBAction func signinAsAdminPressed(_ sender: Any) {
        checkEmptyFields()
        authenticateUser(role: "admin", storyboardName: "AdminScreens", viewControllerIdentifier: "AdminTabBarVC")
    }
    
    
    @IBAction func createAccountPressed(_ sender: Any) {
        let signupVC: SignupVC = SignupVC.instantiate(appStoryboard: .main)
        self.navigationController?.setViewControllers([signupVC], animated: true)

    }
    
    func checkEmptyFields(){
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter your password.")
            return
        }
    }
    
    private func authenticateUser(role: String, storyboardName: String, viewControllerIdentifier: String) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }

        do {
            let realm = try Realm()
            if let user = realm.objects(UserModel.self).filter("email == %@ AND password == %@ AND role == %@", email, password, role).first {
                
                UserModel.loggedInUserInfo = (email: user.email, name: user.name)
                
                LoggedInUserManager.shared.createLoggedInUser(email: emailTextField.text!)
                let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
                if let homeViewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? UITabBarController {
                    self.navigationController?.setViewControllers([homeViewController], animated: true)
                }
            } else {
                showAlert(message: "Invalid credentials or role. Please try again.")
            }
        } catch {
            showAlert(message: "An error occurred while accessing the database. Please try again.")
        }
    }
    
}
