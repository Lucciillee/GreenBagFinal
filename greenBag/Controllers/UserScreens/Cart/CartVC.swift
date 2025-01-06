import UIKit
import Firebase

// This screen shows the user's shopping cart
// It displays all items they've added, their quantities, and the total price
class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CartListXibTableViewDelegate {
    
    // Connect our UI elements
    @IBOutlet weak var cartTotal: UILabel!              // Shows the total price of all items
    @IBOutlet weak var cartListTableView: UITableView!  // The list of items in the cart
    @IBOutlet weak var checkoutButton: CustomRoundedButton!  // Button to proceed to checkout
    
    // Keep track of cart information
    // We store three pieces of info for each cart item:
    // 1. documentId: unique ID in the database
    // 2. productId: which product it is
    // 3. quantity: how many the user wants to buy
    private var cartItems: [(documentId: String, productId: String, quantity: Int)] = []
    
    // Store details about each product
    // The key is the productId, and the value is a tuple with:
    // - name: product name
    // - price: product price
    // - category: product category
    private var productDetails: [String: (name: String, price: Double, category: String)] = [:]
    
    // Set up our connection to the cloud database
    private let db = Firestore.firestore()
    
    // When the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()    // Set up our list view
        fetchCartItems()    // Get items from the database
    }
    
    // Set up our table view with basic settings
    private func setupTableView() {
        cartListTableView.delegate = self
        cartListTableView.dataSource = self
        cartListTableView.rowHeight = 140  // Height of each row
        
        // Register our custom cell design
        cartListTableView.register(UINib(nibName: "CartListXibTableView", bundle: nil),
                                 forCellReuseIdentifier: "CartListXibTableView")
        
        // Start with zero total
        cartTotal.text = "Total: BHD 0.000"
    }
    
    // Get all cart items from the database
    private func fetchCartItems() {
        // Get the current user's email
        let userEmail = LoggedInUserManager.shared.getLoggedInUser()?.email ?? ""
        
        // Find all cart items that belong to this user
        db.collection("cart")
            .whereField("userEmail", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else {
                    print("Error fetching cart: \(error?.localizedDescription ?? "")")
                    return
                }
                
                // Clear existing items before adding new ones
                self.cartItems.removeAll()
                self.productDetails.removeAll()
                
                // Store information about each cart item
                self.cartItems = documents.map { doc in
                    return (
                        documentId: doc.documentID,
                        productId: doc.data()["productId"] as? String ?? "",
                        quantity: doc.data()["quantity"] as? Int ?? 0
                    )
                }
                
                // Get detailed information about each product
                self.fetchProductDetails()
            }
    }
    
    // Get detailed information about each product in the cart
    private func fetchProductDetails() {
        // Use a dispatch group to handle multiple async calls
        let group = DispatchGroup()
        
        // For each item in the cart
        for cartItem in cartItems {
            group.enter()
            
            // Get the product details from the database
            db.collection("product").document(cartItem.productId).getDocument { [weak self] snapshot, error in
                defer { group.leave() }
                
                guard let self = self,
                      let data = snapshot?.data() else { return }
                
                // Get product information
                let name = data["name"] as? String ?? ""
                let priceString = data["price"] as? String ?? "0"
                let category = data["category"] as? String ?? ""
                let price = Double(priceString) ?? 0.0
                
                // Store the details using productId as the key
                self.productDetails[cartItem.productId] = (name, price, category)
            }
        }
        
        // When all product details are fetched
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.cartListTableView.reloadData()     // Refresh the display
            self.updateCartTotal()                  // Update the total price
            self.checkoutButton.isHidden = self.cartItems.isEmpty  // Hide checkout if cart is empty
        }
    }
    
    // Tell the table view how many items to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    // Set up each row in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartListXibTableView", for: indexPath) as! CartListXibTableView
        
        // Get the cart item and its details
        let cartItem = cartItems[indexPath.row]
        if let details = productDetails[cartItem.productId] {
            // Create a temporary model to configure the cell
            let cartItemModel = CartItemRealm()
            cartItemModel.productName = details.name
            cartItemModel.totalPrice = "\(details.price)"
            cartItemModel.quantity = cartItem.quantity
            cartItemModel.productCategory = details.category
            
            cell.addDataToCartCell(cartModel: cartItemModel)
        }
        
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    // Remove an item from the cart
    func removeCartItem(cell: CartListXibTableView) {
        guard let indexPath = cartListTableView.indexPath(for: cell) else { return }
        
        let itemToRemove = cartItems[indexPath.row]
        
        // Remove from the database
        db.collection("cart").document(itemToRemove.documentId).delete { [weak self] error in
            if let error = error {
                print("Error removing item: \(error.localizedDescription)")
                return
            }
            
            // If successful, update our local data
            self?.cartItems.remove(at: indexPath.row)
            self?.cartListTableView.deleteRows(at: [indexPath], with: .fade)
            self?.updateCartTotal()
            self?.checkoutButton.isHidden = self?.cartItems.isEmpty ?? true
        }
    }
    
    // Calculate and update the total price of all items
    private func updateCartTotal() {
        let total = cartItems.reduce(0.0) { result, cartItem in
            guard let details = productDetails[cartItem.productId] else { return result }
            return result + (details.price * Double(cartItem.quantity))
        }
        cartTotal.text = String(format: "Total: BHD %.2f", total)
    }
    
    // Go to checkout screen when checkout button is pressed
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "UserScreens", bundle: nil)
        if let checkoutVC = storyboard.instantiateViewController(withIdentifier: "CheckoutVC") as? CheckoutVC {
            navigationController?.pushViewController(checkoutVC, animated: true)
        }
    }
}
