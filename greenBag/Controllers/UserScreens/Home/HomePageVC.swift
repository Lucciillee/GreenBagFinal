import UIKit
import FirebaseFirestore

// This is the main home page screen where users can:
// 1. See all products sorted by their ratings
// 2. Search for specific products
// 3. Click on products to see more details
class HomePageVC: UIViewController {
    
    // Connect our UI elements
    @IBOutlet weak var productSearchField: CustomTextField!    // Search box for filtering products
    @IBOutlet weak var productsTableView: UITableView!        // List showing all products
    
    // Set up our database and product lists
    private let db = Firestore.firestore()
    
    // We keep track of products in two lists:
    // 1. productsList: All products from the database (master list)
    // 2. filteredProductsList: Products that match the search (what we show to user)
    // Each product in these lists has three pieces of information:
    // - documentId: unique ID in the database
    // - product: all product information (name, price, etc.)
    // - rating: average rating from reviews
    private var productsList: [(documentId: String, product: [String: Any], rating: Double)] = []
    private var filteredProductsList: [(documentId: String, product: [String: Any], rating: Double)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()                // Set up our product list display
        productSearchField.delegate = self  // Connect search box to our code
        fetchProductsWithRatings()      // Get products from database
    }
    
    // Set up our table view with basic settings
    private func setupTableView() {
        productsTableView.delegate = self
        productsTableView.dataSource = self
        productsTableView.rowHeight = 120
        
        // Register our custom cell design
        productsTableView.register(UINib(nibName: "ProductXibTableView", bundle: nil),
                                 forCellReuseIdentifier: "ProductXibTableView")
    }
    
    // Get all products and their ratings from the database
    private func fetchProductsWithRatings() {
        // First, get all products
        db.collection("product").getDocuments { [weak self] snapshot, error in
            guard let self = self,
                  let documents = snapshot?.documents else {
                print("Error fetching products: \(error?.localizedDescription ?? "")")
                return
            }
            
            // Use a dispatch group to handle multiple async calls (one for each product's reviews)
            let group = DispatchGroup()
            var productsWithRatings: [(documentId: String, product: [String: Any], rating: Double)] = []
            
            // For each product, get its reviews and calculate average rating
            for document in documents {
                group.enter()
                let productData = document.data()
                let documentId = document.documentID
                
                // Get all reviews for this product
                self.db.collection("reviews")
                    .whereField("productId", isEqualTo: documentId)
                    .getDocuments { reviewSnapshot, reviewError in
                        defer { group.leave() }
                        
                        // Calculate average rating
                        let reviews = reviewSnapshot?.documents ?? []
                        let totalRating = reviews.reduce(0.0) { sum, review in
                            sum + (review.data()["rating"] as? Double ?? 0.0)
                        }
                        let averageRating = reviews.isEmpty ? 0.0 : totalRating / Double(reviews.count)
                        
                        // Store product with its rating
                        productsWithRatings.append((
                            documentId: documentId,
                            product: productData,
                            rating: averageRating
                        ))
                    }
            }
            
            // When all products and ratings are fetched
            group.notify(queue: .main) {
                // Sort products by rating (highest rated first)
                self.productsList = productsWithRatings.sorted { $0.rating > $1.rating }
                // Initially, show all products (no filter)
                self.filteredProductsList = self.productsList
                // Update the display
                self.productsTableView.reloadData()
            }
        }
    }
}

// MARK: - Search Field Handling
extension HomePageVC: UITextFieldDelegate {
    // This function is called every time the user types in the search box
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Calculate what the new text will be after this change
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        // Filter products based on this new text
        filterProducts(with: updatedText)
        return true
    }
    
    // Filter products based on search text
    private func filterProducts(with searchText: String) {
        if searchText.isEmpty {
            // If search is empty, show all products
            filteredProductsList = productsList
        } else {
            // Otherwise, only show products whose names contain the search text
            filteredProductsList = productsList.filter { item in
                let name = item.product["name"] as? String ?? ""
                // Case-insensitive search (converts both to lowercase)
                return name.lowercased().contains(searchText.lowercased())
            }
        }
        // Update the display with filtered results
        productsTableView.reloadData()
    }
}

// MARK: - Handle Product Selection
extension HomePageVC: UITableViewDelegate {
    // When a product is tapped, show its details
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productDetailsVC: ProductDetailsVC = ProductDetailsVC.instantiate(appStoryboard: .user)
        let selectedProduct = filteredProductsList[indexPath.row]
        productDetailsVC.productId = selectedProduct.documentId
        navigationController?.pushViewController(productDetailsVC, animated: true)
    }
}

// MARK: - Table View Setup
extension HomePageVC: UITableViewDataSource {
    // Tell the table view how many products to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProductsList.count
    }
    
    // Set up each product row in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductXibTableView", for: indexPath) as? ProductXibTableView else {
            return UITableViewCell()
        }
        
        // Get data for this product
        let productData = filteredProductsList[indexPath.row].product
        
        // Create a temporary product model to configure the cell
        let product = ProductModelRealm()
        product.name = productData["name"] as? String ?? ""
        product.price = productData["price"] as? String ?? ""
        product.category = productData["category"] as? String ?? ""
        
        // Configure the cell with product data
        cell.addCellDatawithProductData(productsListModel: product)
        cell.selectionStyle = .none
        return cell
    }
}
