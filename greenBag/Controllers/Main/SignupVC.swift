

import UIKit
import RealmSwift
class SignupVC: UIViewController {
    
    @IBOutlet weak var emailTextField: CustomTextField!
    
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    @IBOutlet weak var nameTextField: CustomTextField!
    
    @IBOutlet weak var phoneNumberTextField: CustomTextField!
    @IBOutlet weak var roleTextField: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        
    }
    
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        // Validate all fields
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter your password.")
            return
        }

        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter your name.")
            return
        }

        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else {
            showAlert(message: "Please enter your phone number.")
            return
        }

        guard let role = roleTextField.text, !role.isEmpty else {
            showAlert(message: "Please enter your role.")
            return
        }

        // Store data in Realm
        let user = UserModel()
        user.email = email
        user.password = password
        user.name = name
        user.phoneNumber = phoneNumber
        user.role = role

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user)
            }
            showAlert(title: "Success", message: "Signup successful!", completion: {
                let signinVC: SigninVC = SigninVC.instantiate(appStoryboard: .main)
                self.navigationController?.setViewControllers([signinVC], animated: true)
            })
        } catch {
            showAlert(message: "Failed to save user data. Please try again.")
        }
    }
    
    @IBAction func signinButtonPressed(_ sender: Any) {
        let signinVC: SigninVC = SigninVC.instantiate(appStoryboard: .main)
        self.navigationController?.setViewControllers([signinVC], animated: true)

    }
    
}
