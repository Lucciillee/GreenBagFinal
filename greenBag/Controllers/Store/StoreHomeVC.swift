import UIKit
import Firebase
import RealmSwift

class StoreHomeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var productsListTableView: UITableView!
    
    // MARK: - Properties
    private var productsList: [ProductModelRealm] = [] // the model realm object gets saved in the array
    private let db = Firestore.firestore()
    private let storeEmail = LoggedInUserManager.shared.getLoggedInUser()?.email ?? ""
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchProductsFromFirebase()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        productsListTableView.delegate = self
        productsListTableView.dataSource = self
        productsListTableView.rowHeight = 160
        productsListTableView.register(UINib(nibName: "StoreProductListXibTableView", bundle: nil),
                                     forCellReuseIdentifier: "StoreProductListXibTableView")
    }
    
    // MARK: - Data Fetching
    private func fetchProductsFromFirebase() {
        guard !storeEmail.isEmpty else { return }
        
        db.collection("product")
            .whereField("storeEmail", isEqualTo: storeEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      error == nil,
                      let documents = snapshot?.documents else { return }
                
                // all gets saved in the productlist array
                self.productsList = documents.compactMap { document -> ProductModelRealm? in
                    let data = document.data()
                    
                    // Instead of directly assigning properties, let's create a dictionary first
                    let productDict: [String: Any] = [
                        "name": data["name"] as? String ?? "",
                        "category": data["category"] as? String ?? "",
                        "material": data["material"] as? String ?? "",
                        "price": data["price"] as? String ?? "",
                        "quantity": data["quantity"] as? String ?? "",
                        "isOrganic": data["isOrganic"] as? Bool ?? false,
                        "isFairTrade": data["isFairTrade"] as? Bool ?? false,
                        "isRecycled": data["isRecycled"] as? Bool ?? false,
                        "storeEmail": data["storeEmail"] as? String ?? "",
                        "productDescription": data["description"] as? String ?? "" // Use a different key for description
                    ]
                    
                    // Create the Realm object
                    let product = ProductModelRealm(value: productDict)
                    
                    // Handle the ID and timestamp separately
                    if let objectId = try? ObjectId(string: document.documentID) {
                        product.id = objectId
                    }
                  
                    return product
                }
                
                DispatchQueue.main.async {
                    self.productsListTableView.reloadData()
                }
            }
    }
    // MARK: - Actions
    @IBAction func reloadButtonPressed(_ sender: Any) {
        fetchProductsFromFirebase()
    }
}

// MARK: - TableView Data Source & Delegate
extension StoreHomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreProductListXibTableView",
                                               for: indexPath) as! StoreProductListXibTableView
        cell.configureWithStoreData(productModelRealm: productsList[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = productsList[indexPath.row]
        navigateToProductDetails(product: product)
    }
    
    private func navigateToProductDetails(product: ProductModelRealm) {
        let storeProductDetailsVC: StoreProductDetailsVC = StoreProductDetailsVC.instantiate(appStoryboard: .store)
        storeProductDetailsVC.productDetails = product
        navigationController?.pushViewController(storeProductDetailsVC, animated: true)
    }
}

// MARK: - StoreProductListXibTableView Delegate
extension StoreHomeVC: StoreProductListXibTableViewDelegate {
    
    func deleteProduct(cell: StoreProductListXibTableView) {
        guard let indexPath = productsListTableView.indexPath(for: cell) else { return }
        let productToDelete = productsList[indexPath.row]
        
        showConfirmationAlert(
            title: "Delete Product",
            message: "Are you sure you want to delete this product?",
            confirmTitle: "Yes"
        ) {
            // Convert ObjectId back to string for Firebase
            let documentId = productToDelete.id.stringValue
            self.db.collection("product").document(documentId).delete { [weak self] error in
                guard let self = self, error == nil else { return }
                
                self.productsList.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.productsListTableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    func showProductDetails(cell: StoreProductListXibTableView) {
        guard let indexPath = productsListTableView.indexPath(for: cell) else { return }
        let selectedProduct = productsList[indexPath.row]
        navigateToProductDetails(product: selectedProduct)
    }
}
