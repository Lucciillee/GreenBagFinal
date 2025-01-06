

import UIKit

class AdminSettings: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        showConfirmationAlert(
            title: "Submit Review",
            message: "Are you sure you want to lotout",
            confirmTitle: "Logout"
        ) {
            LoggedInUserManager.shared.logoutUser()
            let signinVC: SigninVC = SigninVC.instantiate(appStoryboard: .main)
            self.navigationController?.setViewControllers([signinVC], animated: true)
        }
    }
}
