import UIKit
import Firebase

class CheckoutVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var cashOnDeliveryButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    @IBOutlet weak var orderTotal: UILabel!
    
    @IBOutlet weak var orderNotes: CustomTextView!
    // MARK: - Properties
    
    /// Enum to track payment method selection
    private enum PaymentMethod {
        case card
        case cashOnDelivery
    }
    
    /// Currently selected payment method
    private var selectedPaymentMethod: PaymentMethod?
    
    /// Array to store cart items with their document IDs and quantities
    private var cartItems: [(documentId: String, productId: String, quantity: Int)] = []
    
    /// Dictionary to store product details indexed by product ID
    private var productDetails: [String: (name: String, price: Double, category: String)] = [:]
    
    /// Firebase Firestore reference
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        fetchCartItems()
    }
    
    // MARK: - UI Setup
    
    /// Sets up the initial UI state
    private func setupInitialUI() {
        // Initialize order total to zero
        orderTotal.text = "Total: BHD 0.000"
        
        // Setup payment buttons
        setupPaymentButtons()
    }
    
    /// Configures the payment button appearances
    private func setupPaymentButtons() {
        // Set initial button states
        [cashOnDeliveryButton, cardButton].forEach { button in
            button?.tintColor = .gray
            button?.layer.cornerRadius = 8
            button?.layer.borderWidth = 1
            button?.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    // MARK: - Data Fetching
    
    /// Fetches cart items from Firebase for the current user
    private func fetchCartItems() {
        let userEmail = LoggedInUserManager.shared.getLoggedInUser()?.email ?? ""
        
        db.collection("cart")
            .whereField("userEmail", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else {
                    print("Error fetching cart: \(error?.localizedDescription ?? "")")
                    return
                }
                
                // Clear existing items
                self.cartItems.removeAll()
                self.productDetails.removeAll()
                
                // Store cart items
                self.cartItems = documents.map { doc in
                    return (
                        documentId: doc.documentID,
                        productId: doc.data()["productId"] as? String ?? "",
                        quantity: doc.data()["quantity"] as? Int ?? 0
                    )
                }
                
                // Fetch product details for each cart item
                self.fetchProductDetails()
            }
    }
    
    /// Fetches detailed product information for each cart item
    private func fetchProductDetails() {
        let group = DispatchGroup()
        
        for cartItem in cartItems {
            group.enter()
            
            db.collection("product").document(cartItem.productId).getDocument { [weak self] snapshot, error in
                defer { group.leave() }
                
                guard let self = self,
                      let data = snapshot?.data() else { return }
                
                let name = data["name"] as? String ?? ""
                let priceString = data["price"] as? String ?? "0"
                let category = data["category"] as? String ?? ""
                let price = Double(priceString) ?? 0.0
                
                self.productDetails[cartItem.productId] = (name, price, category)
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.updateOrderTotal()
            print("Fetched all cart items and their details")
        }
    }
    
    // MARK: - Button Actions
    
    /// Handles the back button press
    @IBAction func backbuttonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /// Handles the card payment button selection
    @IBAction func cardButtonPressed(_ sender: UIButton) {
        updatePaymentSelection(.card)
    }
    
    /// Handles the cash on delivery button selection
    @IBAction func cashOnDeliveryButtonPressed(_ sender: UIButton) {
        updatePaymentSelection(.cashOnDelivery)
    }
    
    /// Handles the place order button press
    @IBAction func placeOrderButtonPressed(_ sender: Any) {
        guard let paymentMethod = selectedPaymentMethod else {
            showAlert(message: "Please select a payment method")
            return
        }
        
        switch paymentMethod {
        case .card:
            navigateToCardVC()
        case .cashOnDelivery:
            showOrderConfirmation()
        }
    }
    
    // MARK: - Payment Handling
    
    /// Updates the UI for payment method selection
    private func updatePaymentSelection(_ method: PaymentMethod) {
        selectedPaymentMethod = method
        
        // Reset both buttons
        [cashOnDeliveryButton, cardButton].forEach { button in
            button?.backgroundColor = .clear
            button?.tintColor = .gray
        }
        
        // Highlight selected button
        let selectedButton = method == .card ? cardButton : cashOnDeliveryButton
        selectedButton?.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        selectedButton?.tintColor = .systemBlue
    }
    
    /// Shows order confirmation alert for cash on delivery
    private func showOrderConfirmation() {
        showConfirmationAlert(
            title: "Place Order",
            message: "Are you sure you want to place this order?",
            confirmTitle: "Yes"
        ) {
            self.processOrder()
        }
    }
    
    /// Navigates to the card addition screen
    private func navigateToCardVC() {
        let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
        if let cardVC = storyboard.instantiateViewController(withIdentifier: "AddNewCardVC") as? AddNewCardVC {
            cardVC.onCardAdded = { [weak self] in
                self?.processOrder()
            }
            navigationController?.pushViewController(cardVC, animated: true)
        }
    }
    
    // MARK: - Order Processing
    
    /// Processes the order with selected payment method
    private func processOrder() {
        guard let paymentMethod = selectedPaymentMethod else { return }
        addToOrderHistory(paymentMethod: paymentMethod)
        navigateToHome()
    }
    
    /// Adds the order to Firebase and removes items from cart
    private func addToOrderHistory(paymentMethod: PaymentMethod) {
        guard let userEmail = LoggedInUserManager.shared.getLoggedInUser()?.email else {
            showAlert(message: "No logged-in user found.")
            return
        }
        
        let group = DispatchGroup()
        
        // Generate a unique order ID (timestamp + random string)
        let orderID = "\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString.prefix(8))"
        let totalAmount = cartItems.reduce(0.0) { result, cartItem in
            guard let details = productDetails[cartItem.productId] else { return result }
            return result + (details.price * Double(cartItem.quantity))
        }
        
        for cartItem in cartItems {
            group.enter()
            
            guard let details = productDetails[cartItem.productId] else {
                group.leave()
                continue
            }
            
            let orderData: [String: Any] = [
                "orderID": orderID,  // Add order ID to group items
                "userEmail": userEmail,
                "productId": cartItem.productId,
                "productName": details.name,
                "quantity": cartItem.quantity,
                "price": details.price,
                "category": details.category,
                "timestamp": FieldValue.serverTimestamp(),
                "paymentMethod": paymentMethod == .card ? "card" : "cashOnDelivery",
                "totalOrderAmount": totalAmount,  // Add total cart amount
                "status": "pending",  // Add order status
                "orderNotes" : orderNotes.text ?? "none"
            ]
            
            // Add to orders collection
            db.collection("orders").addDocument(data: orderData) { error in
                if let error = error {
                    print("Error adding to order history: \(error)")
                }
                
                // Update product quantity
                self.updateProductQuantity(productId: cartItem.productId, orderedQuantity: cartItem.quantity)
                
                group.leave()
            }
            
            // Remove from cart
            db.collection("cart").document(cartItem.documentId).delete()
        }
        
        group.notify(queue: .main) { [weak self] in
            print("All orders processed with Order ID: \(orderID)")
            self?.showAlert(message: "Order #\(orderID.prefix(8)) placed successfully!")
        }
    }
    
    /// Updates the product quantity after an order
    private func updateProductQuantity(productId: String, orderedQuantity: Int) {
        let productRef = db.collection("product").document(productId)
        
        productRef.getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(),
                  let currentQuantityString = data["quantity"] as? String,
                  let currentQuantity = Int(currentQuantityString) else {
                print("Error fetching product quantity")
                return
            }
            
            let newQuantity = max(0, currentQuantity - orderedQuantity)
            
            // Update the quantity in Firebase
            productRef.updateData([
                "quantity": String(newQuantity)
            ]) { error in
                if let error = error {
                    print("Error updating product quantity: \(error.localizedDescription)")
                } else {
                    print("Successfully updated product quantity to \(newQuantity)")
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    /// Navigates back to the home screen
    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
        if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeVCTabBar") as? UITabBarController {
            navigationController?.setViewControllers([homeViewController], animated: true)
        }
    }
    
    // MARK: - Helpers
    
    /// Updates the total order amount display
    private func updateOrderTotal() {
        let total = cartItems.reduce(0.0) { result, cartItem in
            guard let details = productDetails[cartItem.productId] else { return result }
            return result + (details.price * Double(cartItem.quantity))
        }
        orderTotal.text = String(format: "Total: BHD %.2f", total)
    }
}
