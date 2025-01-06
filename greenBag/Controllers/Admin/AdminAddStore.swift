

import UIKit
import RealmSwift
import FirebaseFirestore  // Add this to use Firebase

// This screen is for administrators to add new stores to the system
class AdminAddStore: UIViewController {
    // Create our connection to the Firebase database
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Connect our text fields where admin types store information
    @IBOutlet weak var storeNameTextField: BlackBorderedTextField!       // Store's name
    @IBOutlet weak var storeEmailTextField: BlackBorderedTextField!      // Store's email
    @IBOutlet weak var storePasswordTextField: BlackBorderedTextField!   // Store's password
    @IBOutlet weak var storePhoneNumberTextField: BlackBorderedTextField! // Store's phone number
    
    // When the "Add Store" button is pressed
    @IBAction func addStoreButtonPressed(_ sender: Any) {
        // First, check if all required fields are filled out
        guard let storeName = storeNameTextField.text, !storeName.isEmpty else {
            showAlert(message: "Please enter store name.")
            return
        }
        guard let storeEmail = storeEmailTextField.text, !storeEmail.isEmpty else {
            showAlert(message: "Please enter store email.")
            return
        }
        guard let storePassword = storePasswordTextField.text, !storePassword.isEmpty else {
            showAlert(message: "Please enter store password.")
            return
        }
        guard let storePhoneNumber = storePhoneNumberTextField.text, !storePhoneNumber.isEmpty else {
            showAlert(message: "Please enter store Phone Number.")
            return
        }
        
        // Show a confirmation popup before adding the store
        showConfirmationAlert(
            title: "Submit",
            message: "Are you sure you want to add this Store",
            confirmTitle: "Yes"
        ) {
            // Create a new user object for the store
            let user = UserModel()
            user.email = storeEmail
            user.password = storePassword
            user.name = storeName
            user.phoneNumber = storePhoneNumber
            user.role = "store"
            
            // Prepare store data for Firebase
            let storeData: [String: Any] = [
                "email": storeEmail,
                "name": storeName,
                "phoneNumber": storePhoneNumber,
                "role": "store",
                "timestamp": FieldValue.serverTimestamp(),
                "password": storePassword
            ]
            
            do {
                // First save to local database (Realm)
                let realm = try Realm()
                try realm.write {
                    realm.add(user)
                }
                
                // Then save to cloud database (Firebase)
                self.db.collection("store").document(storeEmail).setData(storeData) { error in
                    if let error = error {
                        // If saving to Firebase fails, show error
                        print("Error saving to Firebase: \(error)")
                        self.showAlert(message: "Store saved locally but failed to sync to cloud.")
                        return
                    }
                    
                    // If everything worked, show success message and go back to admin home
                    self.showAlert(title: "Success", message: "Store Added", completion: {
                        let storyboard = UIStoryboard(name: "AdminScreens", bundle: nil)
                        if let homeViewController = storyboard.instantiateViewController(withIdentifier: "AdminTabBarVC") as? UITabBarController {
                            self.navigationController?.setViewControllers([homeViewController], animated: true)
                        }
                    })
                }
            } catch {
                // If saving to Realm fails, show error
                self.showAlert(message: "Failed to add new store. Please try again.")
            }
        }
    }
}

// Helper function to show alerts
extension AdminAddStore {
    func showAlert(title: String? = nil, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
