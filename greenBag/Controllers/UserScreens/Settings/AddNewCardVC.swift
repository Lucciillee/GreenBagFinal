import UIKit
import Firebase

class AddNewCardVC: UIViewController, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    
    // MARK: - Properties
    var onCardAdded: (() -> Void)?
    private let db = Firestore.firestore()
    private var existingCardData: [String: Any]?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkForExistingCard()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup text field delegates and formatting
        [cardNumberTextField, expiryDateTextField, cvvTextField].forEach { textField in
            textField?.delegate = self
        }
    }
    
    // MARK: - Firebase Operations
    private func checkForExistingCard() {
        guard let userEmail = LoggedInUserManager.shared.getLoggedInUser()?.email else { return }
        
        db.collection("user_card")
            .whereField("userEmail", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents,
                      let cardData = documents.first?.data() else { return }
                
                self.existingCardData = cardData
                self.populateExistingCardData(cardData)
            }
    }
    
    private func populateExistingCardData(_ cardData: [String: Any]) {
        DispatchQueue.main.async {
            self.cardNumberTextField.text = cardData["cardNumber"] as? String ?? ""
            self.expiryDateTextField.text = cardData["expiryDate"] as? String ?? ""
            // Note: For security, we typically don't pre-fill CVV
        }
    }
    
    private func saveCardDetails() {
        guard let userEmail = LoggedInUserManager.shared.getLoggedInUser()?.email,
              let cardNumber = cardNumberTextField.text,
              let expiryDate = expiryDateTextField.text else { return }
        
        let cardData: [String: Any] = [
            "userEmail": userEmail,
            "cardNumber": cardNumber,
            "expiryDate": expiryDate,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("user_card").addDocument(data: cardData) { [weak self] error in
            if let error = error {
                print("Error saving card: \(error.localizedDescription)")
                self?.showAlert(message: "Failed to save card details")
                return
            }
            
            self?.cardAddedSuccessfully()
        }
    }
    
    // MARK: - Button Actions
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewCardPressed(_ sender: Any) {
        guard validateCardDetails() else { return }
        
        if existingCardData == nil {
            // No existing card, ask if user wants to save
            showConfirmationAlert(
                title: "Save Card",
                message: "Would you like to save this card for future use?",
                confirmTitle: "Yes",
                cancelTitle: "No"
            ) { [weak self] in
                // User wants to save card
                self?.saveCardDetails()
            } cancelHandler: { [weak self] in
                // User doesn't want to save, just process and continue
                self?.cardAddedSuccessfully()
            }
        } else {
            // Existing card, just process
            cardAddedSuccessfully()
        }
    }
    
    // MARK: - Helpers
    private func validateCardDetails() -> Bool {
        guard let cardNumber = cardNumberTextField.text, !cardNumber.isEmpty else {
            showAlert(message: "Please enter card number")
            return false
        }
        
        guard let expiryDate = expiryDateTextField.text, !expiryDate.isEmpty else {
            showAlert(message: "Please enter expiry date")
            return false
        }
        
        guard let cvv = cvvTextField.text, !cvv.isEmpty else {
            showAlert(message: "Please enter CVV")
            return false
        }
        
        // Add more validation as needed (card number format, expiry date format, etc.)
        return true
    }
    
    private func cardAddedSuccessfully() {
        onCardAdded?()
        showAlert(message: "Card processed successfully") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}



// MARK: - Alert Helper
extension AddNewCardVC {
    private func showConfirmationAlert(title: String, message: String, confirmTitle: String, cancelTitle: String, confirmHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            confirmHandler()
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            cancelHandler()
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
