

import UIKit
class AddNewAddressVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func confirmAddressPressed(_ sender: Any) {
        showConfirmationAlert(
            title: "Submit Review",
            message: "Are you sure you want to add this Address",
            confirmTitle: "Yes"
        ) {
            let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
            if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeVCTabBar") as? UITabBarController {
                self.navigationController?.setViewControllers([homeViewController], animated: true) }
        }
    }
}
