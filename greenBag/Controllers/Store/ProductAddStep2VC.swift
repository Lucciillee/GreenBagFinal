

// Import necessary features for our app
import UIKit               // For creating the screen and interface
import FirebaseFirestore  // For saving data to the cloud

// This is the second screen where store owners add eco-friendly details about their products
class ProductAddStep2VC: UIViewController {
    
    // These connect to the switches (toggle buttons) on our screen
    // Switches are those sliding buttons that can be ON or OFF
    @IBOutlet weak var isFairTrade: UISwitch!      // For marking if product is fair trade
    @IBOutlet weak var isRecycled: UISwitch!       // For marking if product is made from recycled materials
    @IBOutlet weak var isOrganic: UISwitch!        // For marking if product is organic
    
    // These connect to the text boxes where users type information
    @IBOutlet weak var productMaterial: BlackBorderedTextField!    // Where user types what the product is made of
    @IBOutlet weak var productDescription: BlackBorderedTextField! // Where user types product description
    
    // Create our connection to the cloud database (Firebase)
    // Think of this like having a special phone line to talk to our internet storage
    private let db = Firestore.firestore()
    
    // This will store the ID of the product we're adding details to
    // It's like a unique label that helps us find the right product
    var productID = ""
    
    // This runs when the screen first appears
    override func viewDidLoad() {
        super.viewDidLoad()
        // Currently empty, but we could add more setup code here if needed
    }
    
    // This happens when the user taps the "Add" button
    @IBAction func addButtonClicked(_ sender: Any) {
        // First, check if the user filled out all the required text fields
        // guard let is like a safety check - if information is missing, show an error
        guard let material = productMaterial.text, !material.isEmpty,
              let description = productDescription.text, !description.isEmpty else {
            showAlert(message: "Please fill all fields")
            return
        }
        
        // Prepare all the eco-friendly information to be saved
        // This is like filling out a form with all the green features
        let updateData: [String: Any] = [
            "isFairTrade": isFairTrade.isOn,    // Is the switch ON or OFF for fair trade?
            "isRecycled": isRecycled.isOn,      // Is the switch ON or OFF for recycled?
            "isOrganic": isOrganic.isOn,        // Is the switch ON or OFF for organic?
            "material": material,                // What material was typed in
            "description": description           // What description was typed in
        ]
        
        // Try to save this information to our cloud database
        // We use the productID to find the right product to update
        db.collection("product").document(productID).updateData(updateData) { [weak self] error in
            guard let self = self else { return }
            
            // If something goes wrong while saving
            if let error = error {
                print("Error updating product: \(error)")
                self.showAlert(message: "Failed to update product details")
                return
            }
            
            // If everything worked successfully:
            // 1. Show a success message
            // 2. Go back to the store's main screen
            self.showAlert(title: "Success", message: "Product details added successfully!") {
                let storyboard = UIStoryboard(name: "StoreScreens", bundle: nil)
                if let homeViewController = storyboard.instantiateViewController(withIdentifier: "StoreTabBarVC") as? UITabBarController {
                    self.navigationController?.setViewControllers([homeViewController], animated: true)
                }
            }
        }
    }
}
