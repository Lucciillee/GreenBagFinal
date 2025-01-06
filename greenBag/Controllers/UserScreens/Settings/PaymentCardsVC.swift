

import UIKit
class PaymentCardsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func deleteCardButtonPressed(_ sender: Any) {
        showConfirmationAlert(
            title: "Submit Review",
            message: "Are you sure you want to delete this Card",
            confirmTitle: "Yes"
        ) {
            let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
            if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeVCTabBar") as? UITabBarController {
                self.navigationController?.setViewControllers([homeViewController], animated: true) }
        }
    }
    
    
    
    @IBAction func addNewCardButtonPressed(_ sender: Any) {
        let addCardVC: AddNewCardVC = AddNewCardVC.instantiate(appStoryboard: .user)
        navigationController?.pushViewController(addCardVC, animated: true)
    }
    
}
