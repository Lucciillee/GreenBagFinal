

// These tell our app what features we want to use
import UIKit                // This lets us create iPhone/iPad screens
import RealmSwift          // This helps us save data on the phone
import FirebaseFirestore   // This helps us save data to the internet (cloud)

// This is the screen where store owners can add new products to sell
class StoreAddProductVC: UIViewController {
    
    // Create a connection to our internet database (Firebase)
    // Think of this like creating a telephone line to talk to our cloud storage
    private let db = Firestore.firestore()
    
    // These connect to the text boxes on our screen where users type information
    // They're like empty containers waiting to be filled with product details
    @IBOutlet weak var productNameTextField: BlackBorderedTextField!      // Where user types product name
    @IBOutlet weak var productCategoryTextField: BlackBorderedTextField!  // Where user types product category
    @IBOutlet weak var productPriceTextField: BlackBorderedTextField!     // Where user types product price
    @IBOutlet weak var productQuantityTextField: BlackBorderedTextField!  // Where user types how many items are in stock
    
    // Create a connection to save data locally on the phone
    // This is like having a notebook to write things down
    private let realm = try! Realm()
    
    // This runs when the screen first appears
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // This happens when the user taps the "Add Product" button
    @IBAction func addProductButtonPressed(_ sender: Any) {
        // First, we check if the user filled out all the required information
        // Like checking if someone filled out all parts of a form
        
        // Check if product name is not empty
        guard let name = productNameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter the product name.")
            return
        }

        // Check if category is not empty
        guard let category = productCategoryTextField.text, !category.isEmpty else {
            showAlert(message: "Please enter the product category.")
            return
        }

        // Check if price is not empty
        guard let price = productPriceTextField.text, !price.isEmpty else {
            showAlert(message: "Please enter the product price.")
            return
        }

        // Check if quantity is not empty
        guard let quantity = productQuantityTextField.text, !quantity.isEmpty else {
            showAlert(message: "Please enter the product quantity.")
            return
        }

        // Ask the user if they're sure they want to add the product
        // This is like a "Are you sure?" popup
        showConfirmationAlert(
            title: "Add Product",
            message: "Are you sure you want to add this product?",
            confirmTitle: "Yes"
        ) { [weak self] in
            guard let self = self else { return }
            // If they say yes, save the product and go back to the main screen
            self.addProductToRealm(name: name, category: category, price: price, quantity: quantity)
            let storyboard = UIStoryboard(name: "StoreScreens", bundle: nil)
            if let homeViewController = storyboard.instantiateViewController(withIdentifier: "StoreTabBarVC") as? UITabBarController {
                self.navigationController?.setViewControllers([homeViewController], animated: true)
            }
        }
    }
    
    // This function saves the product information both on the phone and in the cloud
    private func addProductToRealm(name: String, category: String, price: String, quantity: String) {
        // Create a new product with all its information
        let newProduct = ProductModelRealm()
        newProduct.name = name
        newProduct.category = category
        newProduct.price = price
        newProduct.quantity = quantity

        // Prepare the product information to be saved in the cloud (Firebase)
        // This is like writing down all the details on a piece of paper
        let productData: [String: Any] = [
            "id": newProduct.id.stringValue,
            "name": name,
            "category": category,
            "price": price,
            "quantity": quantity,
            "storeEmail": UserModel.loggedInUserInfo.email,
            "timestamp": FieldValue.serverTimestamp()  // Adds the current time
        ]
        
        // Try to save the product locally (on the phone)
        do {
            try realm.write {
                realm.add(newProduct)
            }
            
            // After saving locally, try to save to the cloud (Firebase)
            db.collection("product").document(newProduct.id.stringValue).setData(productData) { [weak self] error in
                guard let self = self else { return }
                
                // If there's an error saving to the cloud, show an error message
                if let error = error {
                    print("Error saving to Firebase: \(error)")
                    self.showAlert(message: "Product saved locally but failed to sync to cloud.")
                    return
                }
            }
            
            // If everything worked, show a success message
            showAlert(title: "Success", message: "Product added successfully!") { [weak self] in
                guard let self = self else { return }
                
                // Go to the next screen to add more product details
                let storyboard = UIStoryboard(name: "StoreScreens", bundle: nil)
                if let productAddStep2VC = storyboard.instantiateViewController(withIdentifier: "ProductAddStep2VC") as? ProductAddStep2VC {
                    productAddStep2VC.productID = newProduct.id.stringValue
                    self.navigationController?.pushViewController(productAddStep2VC, animated: true)
                }
            }
        } catch {
            // If something goes wrong while saving, show an error message
            showAlert(message: "Failed to add product. Please try again.")
            print("Error saving product to Realm: \(error)")
        }
    }
}
