

import UIKit
class StoreSettingsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func orderHistoryPressed(_ sender: Any) {
        let trackerVC: OrderTrackerVC = OrderTrackerVC.instantiate(appStoryboard: .store)
        self.navigationController?.pushViewController(trackerVC, animated: true)
    }
    @IBAction func logoutPressed(_ sender: Any) {
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
