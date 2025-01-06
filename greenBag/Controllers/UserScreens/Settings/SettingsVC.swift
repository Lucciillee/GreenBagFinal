

import UIKit
class SettingsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func userProfileButtonPressed(_ sender: Any) {
        let userProfileVC: UserProfileVC = UserProfileVC.instantiate(appStoryboard: .user)
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    @IBAction func paymentCardsButtonPressed(_ sender: Any) {
        let paymentCardsVC: PaymentCardsVC = PaymentCardsVC.instantiate(appStoryboard: .user)
        navigationController?.pushViewController(paymentCardsVC, animated: true)
    }
    
    @IBAction func deliveryAddressButtonPressed(_ sender: Any) {
        let deliveryAddressesVC: DeliveryAddressesVC = DeliveryAddressesVC.instantiate(appStoryboard: .user)
        navigationController?.pushViewController(deliveryAddressesVC, animated: true)
    }
    
    
    @IBAction func viewOrderHistoryButtonPressed(_ sender: Any) {
        let orderHistoryVC: OrderHistoryVC = OrderHistoryVC.instantiate(appStoryboard: .user)
        navigationController?.pushViewController(orderHistoryVC, animated: true)
    }
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
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
