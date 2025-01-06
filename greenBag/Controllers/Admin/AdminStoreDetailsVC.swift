

import UIKit
import RealmSwift
import FirebaseFirestore

// This screen lets administrators view and edit store details
class AdminStoreDetailsVC: UIViewController {
    
    // Store details passed from previous screen
    var storeDetails: UserModel?
    
    // Connect to our text fields for store information
    @IBOutlet weak var storeNameTextField: BlackBorderedTextField!
    @IBOutlet weak var storeEmailTextField: BlackBorderedTextField!
    @IBOutlet weak var storePasswordTextField: BlackBorderedTextField!
    @IBOutlet weak var storePhoneNumberTextField: BlackBorderedTextField!
    
    // Set up our database connections
    private let realm = try! Realm()
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fill in the text fields with current store details
        storeNameTextField.text = storeDetails?.name
        storeEmailTextField.text = storeDetails?.email
        storePasswordTextField.text = storeDetails?.password
        storePhoneNumberTextField.text = storeDetails?.phoneNumber
        
        // Don't allow changing email as it's used as the store's ID
        storeEmailTextField.isUserInteractionEnabled = false
    }
    
    // Handle back button press
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // Handle update button press
    @IBAction func updateStoreButtonPressed(_ sender: Any) {
        guard let store = storeDetails else { return }
        
        // Get the new values from text fields
        let newName = storeNameTextField.text ?? ""
        let newEmail = storeEmailTextField.text ?? ""
        let newPassword = storePasswordTextField.text ?? ""
        let newPhoneNumber = storePhoneNumberTextField.text ?? ""
        
        // Check if anything changed
        if newName == store.name &&
            newEmail == store.email &&
            newPassword == store.password &&
            newPhoneNumber == store.phoneNumber {
            // No changes detected
            showAlert(message: "No changes detected.")
            return
        }
        
        // Prepare the updated data for Firebase
        let storeData: [String: Any] = [
            "name": newName,
            "email": newEmail,
            "phoneNumber": newPhoneNumber,
            "role": "store",
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        // Update in Firebase first
        db.collection("store").document(store.email).updateData(storeData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error updating in Firebase: \(error)")
                self.showAlert(message: "Failed to update store in cloud. Please try again.")
                return
            }
            
            // If Firebase update successful, update in Realm
            do {
                try self.realm.write {
                    store.name = newName
                    store.email = newEmail
                    store.password = newPassword
                    store.phoneNumber = newPhoneNumber
                }
                
                // Show success alert and go back
                self.showAlert(title: "Success", message: "Store details updated successfully!") { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Error updating in Realm: \(error)")
                self.showAlert(message: "Store updated in cloud but failed to update locally. Please refresh the page.")
            }
        }
    }
    
    // Helper function to show alerts
    private func showAlert(title: String = "Error", message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}
