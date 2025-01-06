

import UIKit
class DeliveryAddressesVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func editAddressPressed(_ sender: Any) {
        let addNewAddressVC: AddNewAddressVC = AddNewAddressVC.instantiate(appStoryboard: .user)
        navigationController?.pushViewController(addNewAddressVC, animated: true)
    }
    @IBAction func deleteAddressPressed(_ sender: Any) {
        showConfirmationAlert(
            title: "Submit Review",
            message: "Are you sure you want to delete this Address",
            confirmTitle: "Yes"
        ) {
            let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
            if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeVCTabBar") as? UITabBarController {
                self.navigationController?.setViewControllers([homeViewController], animated: true) }
        }
    }
    
    @IBAction func addNewAddressPressed(_ sender: Any) {
        let addNewAddressVC: AddNewAddressVC = AddNewAddressVC.instantiate(appStoryboard: .user)
        navigationController?.pushViewController(addNewAddressVC, animated: true)
    }
}
