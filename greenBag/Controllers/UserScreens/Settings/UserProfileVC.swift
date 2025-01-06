

import UIKit
import RealmSwift
class UserProfileVC: UIViewController {
    
    
    @IBOutlet weak var nameTextField: BlackBorderedTextField!
    @IBOutlet weak var phoneNumberTextField: BlackBorderedTextField!
    @IBOutlet weak var emailTextField: BlackBorderedTextField!
    
    private let realm = try! Realm()
    private var loggedInUser: LoggedInUserRealm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.isUserInteractionEnabled = false
        fetchUserProfile()
        
    }
    
    private func fetchUserProfile() {
        // Get the logged-in user's email
        if let loggedInUser = LoggedInUserManager.shared.getLoggedInUser() {
            let email = loggedInUser.email

            // Search for the user in the UserModel using the email
            if let user = realm.objects(UserModel.self).filter("email == %@", email).first {
                emailTextField.text = user.email
                nameTextField.text = user.name
                phoneNumberTextField.text = user.phoneNumber
            } else {
                print("User not found in UserModel.")
            }
        } else {
            print("No logged-in user found.")
        }
    }

    
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func updateInfoButtonPressed(_ sender: Any) {
        guard let loggedInUser = LoggedInUserManager.shared.getLoggedInUser() else {
            showAlert(message: "No logged-in user found.")
            return
        }

        // Fetch the user from UserModel using the logged-in user's email
        guard let user = realm.objects(UserModel.self).filter("email == %@", loggedInUser.email).first else {
            showAlert(message: "User not found in the database.")
            return
        }

        let newName = nameTextField.text ?? ""
        let newPhoneNumber = phoneNumberTextField.text ?? ""

        // Check if any value has changed
        if newName == user.name && newPhoneNumber == user.phoneNumber {
            showAlert(message: "No changes detected.")
            return
        }

        // Show confirmation alert
        showConfirmationAlert(
            title: "Review Info",
            message: "Are you sure you want to update info?",
            confirmTitle: "Submit"
        ) { [weak self] in
            guard let self = self else { return }

            // Update user data in Realm
            try? self.realm.write {
                user.name = newName
                user.phoneNumber = newPhoneNumber
            }

            // Show success alert and navigate to the home screen
            self.showAlert(title: "Success", message: "Profile updated successfully!") {
                let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
                if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeVCTabBar") as? UITabBarController {
                    self.navigationController?.setViewControllers([homeViewController], animated: true)
                }
            }
        }
    }
    
}
