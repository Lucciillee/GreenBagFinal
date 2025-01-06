import UIKit
import FirebaseFirestore

// This screen shows detailed information about a product to the user
// Users can view product details, badges (like Fair Trade), and add items to their cart
class ProductDetailsVC: UIViewController {
    
    // Connect our labels that show product information
    @IBOutlet weak var badgesLabel: UILabel!          // Shows eco-friendly badges (Fair Trade, Organic, etc.)
    @IBOutlet weak var productinformation: UILabel!   // Shows product description and material
    @IBOutlet weak var numberOfProducts: UILabel!     // Shows how many items user wants to buy
    @IBOutlet weak var productCategory: UILabel!      // Shows product category
    @IBOutlet weak var productName: UILabel!          // Shows product name
    @IBOutlet weak var productQuantity: UILabel!      // Shows how many items are in stock
    @IBOutlet weak var productPrice: UILabel!         // Shows product price
    
    // Set up our database connection and tracking variables
    private let db = Firestore.firestore()           // Connection to our cloud database
    var productId: String = ""                       // ID of the product we're viewing
    private var currentNumberOfProducts: Int = 1     // How many items user wants to buy
    private var totalPrice: Double = 0.0             // Total price for all items
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProductDetails()  // Get product information when screen loads
    }
    
    // Get all product details from the database
    private func fetchProductDetails() {
        // Find the product in our database using its ID
        db.collection("product").document(productId).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data() else {
                print("Error fetching product: \(error?.localizedDescription ?? "")")
                return
            }
            
            // Get basic product information
            let name = data["name"] as? String ?? ""
            let category = data["category"] as? String ?? ""
            let price = data["price"] as? String ?? "0.0"
            let quantity = data["quantity"] as? String ?? "0"
            
            // Get eco-friendly details
            let material = data["material"] as? String ?? ""
            let description = data["description"] as? String ?? ""
            let isFairTrade = data["isFairTrade"] as? Bool ?? false
            let isRecycled = data["isRecycled"] as? Bool ?? false
            let isOrganic = data["isOrganic"] as? Bool ?? false
            
            // Update all our labels with the product information
            self.productName.text = name
            self.productCategory.text = category
            self.productPrice.text = "\(price) BHD"
            
            // Show how many items are in stock
            if let quantityInt = Int(quantity) {
                self.productQuantity.text = "In Stock - \(quantityInt) Remaining"
            }
            
            // Create a list of eco-friendly badges this product has earned
            var badges: [String] = []
            if isFairTrade { badges.append("• Fair Trade") }
            if isRecycled { badges.append("• Recycled") }
            if isOrganic { badges.append("• Organic") }
            
            // Set up the badges label to show multiple lines
            self.badgesLabel.numberOfLines = 0
            self.badgesLabel.lineBreakMode = .byWordWrapping
            
            // Show the badges (or "No badges" if none)
            self.badgesLabel.text = badges.isEmpty ? "No badges" : badges.joined(separator: "\n")
            
            // Create and show the product information section
            let info = """
            Description:
            \(description)
            
            Material:
            \(material)
            """
            self.productinformation.text = info
            
            // Calculate initial total price
            if let priceValue = Double(price) {
                self.totalPrice = priceValue * Double(self.currentNumberOfProducts)
            }
            
            // Update the quantity selector
            self.updateNumberOfProductsLabel()
        }
    }
    
    // Update the label showing how many items user wants to buy
    private func updateNumberOfProductsLabel() {
        numberOfProducts.text = "\(currentNumberOfProducts)"
    }
    
    // When the + button is pressed
    @IBAction func addButtonPressed(_ sender: Any) {
        // Check if we have enough items in stock
        guard let quantityText = productQuantity.text,
              let maxQuantity = Int(quantityText.components(separatedBy: " ")[3]),
              maxQuantity > 0 else {
            showAlert(message: "No stock available.")
            return
        }
        
        // Only allow adding if we haven't reached max stock
        if currentNumberOfProducts < maxQuantity {
            currentNumberOfProducts += 1
            updateNumberOfProductsLabel()
        } else {
            showAlert(message: "You can't add more than the available stock.")
        }
    }
    
    // When the - button is pressed
    @IBAction func subtractButtonPressed(_ sender: Any) {
        // Don't allow less than 1 item
        if currentNumberOfProducts > 1 {
            currentNumberOfProducts -= 1
            updateNumberOfProductsLabel()
        } else {
            showAlert(message: "You must have at least one product.")
        }
    }
    
    // When the "Reviews" button is pressed
    @IBAction func productReviewButtonPressed(_ sender: Any) {
        let productReviewsVC: ProductReviewsVC = ProductReviewsVC.instantiate(appStoryboard: .user)
        productReviewsVC.productId = productId
        navigationController?.pushViewController(productReviewsVC, animated: true)
    }
    
    // When "Add to Cart" button is pressed
    @IBAction func addProductToCartPressed(_ sender: Any) {
        // Get the current user's email
        let userId = LoggedInUserManager.shared.getLoggedInUser()?.email ?? ""
        
        // Prepare to add to Firebase cart
        let cartRef = db.collection("cart")
        
        // Create the cart item information
        let cartItemData: [String: Any] = [
            "userEmail": userId,
            "quantity": currentNumberOfProducts,
            "productId": productId,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // Add item to Firebase cart
        cartRef.addDocument(data: cartItemData) { error in
            if let error = error {
                print("Error adding item to Firebase cart: \(error.localizedDescription)")
            } else {
                print("Successfully added item to Firebase cart")
            }
        }
        
        // Also add to local cart manager
        LoggedInUserManager.shared.addItemToCart(
            productName: productName.text ?? "",
            totalPrice: "\(totalPrice)",
            quantity: currentNumberOfProducts,
            productCategory: productCategory.text ?? ""
        )
        
        // Show success message and go back to home screen
        showAlert(message: "Product Added to Cart") {
            let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
            if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeVCTabBar") as? UITabBarController {
                self.navigationController?.setViewControllers([homeViewController], animated: true)
            }
        }
    }
    
    // When back button is pressed
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
