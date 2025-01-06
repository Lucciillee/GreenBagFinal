
import UIKit
class CardsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addCardButtonPressed(_ sender: Any) {
        let addCardVC: AddNewCardVC = AddNewCardVC.instantiate(appStoryboard: .user)
        navigationController?.pushViewController(addCardVC, animated: true)
    }
}
