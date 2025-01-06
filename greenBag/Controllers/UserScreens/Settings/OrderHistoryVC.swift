import UIKit
import Firebase

class OrderHistoryVC: UIViewController {
    
    @IBOutlet weak var orderListTableView: UITableView!
    
    // Structure to hold grouped orders
    private struct OrderGroup {
        let orderID: String
        let totalAmount: Double
        let status: String
        let timestamp: Date
        var items: [(name: String, quantity: Int, price: Double)]
    }
    
    private var orderGroups: [OrderGroup] = []
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchOrders()
    }
    
    private func setupTableView() {
        orderListTableView.delegate = self
        orderListTableView.dataSource = self
        // Register both cells
        orderListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        orderListTableView.register(UINib(nibName: "CartListXibTableView", bundle: nil),
                                  forCellReuseIdentifier: "CartListXibTableView")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderGroup = orderGroups[indexPath.section]
        
        if indexPath.row == 0 {
            // Header cell stays the same
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: orderGroup.timestamp)
            
            // Enable multiline
                   cell.textLabel?.numberOfLines = 0
                   cell.textLabel?.lineBreakMode = .byWordWrapping
            
            cell.textLabel?.text = "Order #\(orderGroup.orderID)\nStatus:\(orderGroup.status)"
            cell.detailTextLabel?.text = "Total: $\(String(format: "%.2f", orderGroup.totalAmount))\nStatus: \(orderGroup.status)\nDate: \(dateString)"
            cell.backgroundColor = UIColor.systemGray6
            return cell
        } else {
            // Use CartListXibTableView for items
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartListXibTableView", for: indexPath) as! CartListXibTableView
            let item = orderGroup.items[indexPath.row - 1]
            
            // Configure cell and hide unused elements
            //cell.cartItemImage.isHidden = true
            cell.removeButton.isHidden = true
            cell.cartItemCategory.isHidden = true
            cell.cartItemName.text = item.name
            cell.cartItemTotalItems.text = "Qty: \(item.quantity)"
            cell.cartItemTotalPrice.text = "\(String(format: "%.2f", item.price))"
            cell.backgroundColor = .white
            
            return cell
        }
    }
    
    private func fetchOrders() {
        guard let userEmail = LoggedInUserManager.shared.getLoggedInUser()?.email else { return }
        
        db.collection("orders")
            .whereField("userEmail", isEqualTo: userEmail)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    if error.localizedDescription.contains("requires an index") {
                        self.showAlert(message: "Setting up database. Please try again in a few minutes.")
                    } else {
                        self.showAlert(message: "Error fetching orders: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.showAlert(message: "No orders found")
                    return
                }
                
                // Group orders by orderID
                let groupedOrders = Dictionary(grouping: documents) { doc in
                    doc.data()["orderID"] as? String ?? ""
                }
                
                // Convert to OrderGroup array
                self.orderGroups = groupedOrders.compactMap { (orderID, documents) in
                    guard let firstDoc = documents.first,
                          let timestamp = (firstDoc.data()["timestamp"] as? Timestamp)?.dateValue(),
                          let totalAmount = firstDoc.data()["totalOrderAmount"] as? Double,
                          let status = firstDoc.data()["status"] as? String
                    else { return nil }
                    
                    let items = documents.compactMap { doc -> (name: String, quantity: Int, price: Double)? in
                        guard let name = doc.data()["productName"] as? String,
                              let quantity = doc.data()["quantity"] as? Int,
                              let price = doc.data()["price"] as? Double
                        else { return nil }
                        return (name, quantity, price)
                    }
                    
                    return OrderGroup(
                        orderID: orderID,
                        totalAmount: totalAmount,
                        status: status,
                        timestamp: timestamp,
                        items: items
                    )
                }
                
                DispatchQueue.main.async {
                    self.orderListTableView.reloadData()
                }
            }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension OrderHistoryVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderGroups[section].items.count + 1  // +1 for header
    }
   
    
    
}
