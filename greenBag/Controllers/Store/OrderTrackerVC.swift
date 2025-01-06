import UIKit
import Firebase

// This screen helps store owners track and manage their orders
// Think of it like a dashboard where you can see all orders and their status
class OrderTrackerVC: UIViewController {
    
    // Connect our screen buttons and list view
    @IBOutlet weak var backButton: UIButton!      // Button to go back to previous screen
    @IBOutlet weak var tableView: UITableView!    // The list that shows all orders
    
    // This is like a form that organizes all the information about an order
    // It keeps track of what was ordered, how much it cost, and its current status
    private struct OrderGroup {
        let orderID: String           // Unique number for each order (like a receipt number)
        let totalAmount: Double       // Total cost of everything in the order
        var status: String           // Current status (like "Pending" or "In Progress")
        let timestamp: Date          // When the order was placed
        let userEmail: String        // Customer's email address
        var items: [(name: String, quantity: Int, price: Double)]  // List of items ordered
        
        // Automatically calculates the total cost for this store's items
        // (Some orders might include items from multiple stores)
        var storeTotalAmount: Double {
            return items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        }
    }
    
    // Keep track of all orders in a list
    private var orderGroups: [OrderGroup] = []
    
    // Set up connection to our cloud database
    private let db = Firestore.firestore()
    
    // Get the email of the currently logged-in store
    private let storeEmail = LoggedInUserManager.shared.getLoggedInUser()?.email ?? ""
    
    // MARK: - When the screen loads
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()         // Prepare the list view
        fetchStoreOrders()       // Get all orders from the database
    }
    
    // MARK: - Button Actions
    
    // What happens when someone taps the back button
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Set up our list view (table view) with all the necessary settings
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register the different types of cells we'll use to display order information
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "CartListXibTableView", bundle: nil),
                         forCellReuseIdentifier: "CartListXibTableView")
    }
    
    // Get all orders from the database that belong to this store
    private func fetchStoreOrders() {
        // Make sure we have the store's email
        guard let storeEmail = LoggedInUserManager.shared.getLoggedInUser()?.email else { return }
        
        // Ask the database for all orders, sorted by newest first
        db.collection("orders")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                // If something went wrong, show an error message
                if let error = error {
                    self.showAlert(message: "Error fetching orders: \(error.localizedDescription)")
                    return
                }
                
                // If no orders found, let the user know
                guard let documents = snapshot?.documents else {
                    self.showAlert(message: "No orders found")
                    return
                }
                
                // Group orders by their order ID (because one order might have multiple items)
                let groupedOrders = Dictionary(grouping: documents) { doc in
                    doc.data()["orderID"] as? String ?? ""
                }
                
                // Use groups to manage our async database calls
                let group = DispatchGroup()
                var orderGroups: [OrderGroup] = []
                
                // Go through each order group
                for (orderID, documents) in groupedOrders {
                    group.enter()
                    
                    // Get the basic order information
                    guard let firstDoc = documents.first,
                          let timestamp = (firstDoc.data()["timestamp"] as? Timestamp)?.dateValue(),
                          let totalAmount = firstDoc.data()["totalOrderAmount"] as? Double,
                          let status = firstDoc.data()["status"] as? String,
                          let userEmail = firstDoc.data()["userEmail"] as? String
                    else {
                        group.leave()
                        continue
                    }
                    
                    // Use another group for fetching product details
                    let productGroup = DispatchGroup()
                    var storeItems: [(name: String, quantity: Int, price: Double)] = []
                    
                    // Go through each item in the order
                    for doc in documents {
                        guard let productID = doc.data()["productId"] as? String,
                              let orderQuantity = doc.data()["quantity"] as? Int
                        else { continue }
                        
                        productGroup.enter()
                        
                        // Get the product details from the database
                        self.db.collection("product").document(productID).getDocument { productSnapshot, error in
                            defer { productGroup.leave() }
                            
                            if let error = error { return }
                            
                            // Make sure this product belongs to our store
                            guard let productData = productSnapshot?.data(),
                                  let productStoreEmail = productData["storeEmail"] as? String,
                                  productStoreEmail == storeEmail,
                                  let name = productData["name"] as? String,
                                  let priceString = productData["price"] as? String,
                                  let price = Double(priceString)
                            else { return }
                            
                            storeItems.append((name: name, quantity: orderQuantity, price: price))
                        }
                    }
                    
                    // When we have all product details for this order
                    productGroup.notify(queue: .main) {
                        if !storeItems.isEmpty {
                            let orderGroup = OrderGroup(
                                orderID: orderID,
                                totalAmount: totalAmount,
                                status: status,
                                timestamp: timestamp,
                                userEmail: userEmail,
                                items: storeItems
                            )
                            orderGroups.append(orderGroup)
                        }
                        group.leave()
                    }
                }
                
                // When all orders are processed, update our list
                group.notify(queue: .main) {
                    self.orderGroups = orderGroups.sorted { $0.timestamp > $1.timestamp }
                    self.tableView.reloadData()
                }
            }
    }
    
    // Show a menu for changing an order's status
    private func showStatusChangeAlert(for orderGroup: OrderGroup, at section: Int) {
        let alert = UIAlertController(title: "Update Order Status",
                                    message: "Select new status for Order #\(orderGroup.orderID)",
                                    preferredStyle: .actionSheet)
        
        // List of possible status options
        let statuses = ["Pending", "In Progress", "Out for Delivery"]
        
        // Add a button for each status
        for status in statuses {
            let action = UIAlertAction(title: status, style: .default) { [weak self] _ in
                self?.updateOrderStatus(orderID: orderGroup.orderID,
                                     newStatus: status,
                                     at: section)
            }
            alert.addAction(action)
        }
        
        // Add a cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // Update an order's status in the database
    private func updateOrderStatus(orderID: String, newStatus: String, at section: Int) {
        // Create a batch to update all items in the order at once
        let batch = db.batch()
        
        // Find all items in this order
        db.collection("orders")
            .whereField("orderID", isEqualTo: orderID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                // Show error if something went wrong
                if let error = error {
                    self.showAlert(message: "Error updating status: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Update each item's status
                for doc in documents {
                    batch.updateData([
                        "status": newStatus
                    ], forDocument: doc.reference)
                }
                
                // Save all changes
                batch.commit { [weak self] error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.showAlert(message: "Error saving changes: \(error.localizedDescription)")
                        return
                    }
                    
                    // Update our local list and refresh the display
                    self.orderGroups[section].status = newStatus
                    DispatchQueue.main.async {
                        self.tableView.reloadSections(IndexSet(integer: section),
                                                    with: .automatic)
                    }
                    
                    self.showAlert(message: "Order status updated successfully")
                }
            }
    }
}

// MARK: - Table View Setup

// This extension handles how our list of orders looks and behaves
extension OrderTrackerVC: UITableViewDataSource, UITableViewDelegate {
    
    // How many sections (orders) we have
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderGroups.count
    }
    
    // How many rows in each section (order header + items)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderGroups[section].items.count + 1
    }
    
    // Set up each row in our list
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderGroup = orderGroups[indexPath.section]
        
        // If it's the first row, show order summary
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.numberOfLines = 0
            
            // Format the date nicely
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: orderGroup.timestamp)
            
            // Set up the cell's information
            cell.textLabel?.text = "Order #\(orderGroup.orderID)\nStatus: \(orderGroup.status)"
            cell.detailTextLabel?.text = "Customer: \(orderGroup.userEmail)\nStore Total: $\(String(format: "%.2f", orderGroup.storeTotalAmount))\nDate: \(dateString)"
            cell.backgroundColor = UIColor.systemGray6
            
            return cell
        } else {
            // For other rows, show individual items
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartListXibTableView",
                                                   for: indexPath) as! CartListXibTableView
            let item = orderGroup.items[indexPath.row - 1]
            
            cell.removeButton.setTitle("Update", for: .normal)
            cell.cartItemCategory.isHidden = true
            cell.cartItemName.text = item.name
            cell.cartItemTotalItems.text = "Qty: \(item.quantity)"
            cell.cartItemTotalPrice.text = "\(String(format: "%.2f", item.price))"
            cell.delegate = self
            
            return cell
        }
    }
}

// MARK: - Handle Update Button Taps

extension OrderTrackerVC: CartListXibTableViewDelegate {
    // When someone taps the "Update" button on an order
    func removeCartItem(cell: CartListXibTableView) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let orderGroup = orderGroups[indexPath.section]
        showStatusChangeAlert(for: orderGroup, at: indexPath.section)
        cell.removeButton.titleLabel?.text = "Update"
    }
}

// MARK: - Show Alert Messages

extension OrderTrackerVC {
    // Helper function to show alert messages to the user
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
