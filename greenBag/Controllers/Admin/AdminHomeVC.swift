

import UIKit
import RealmSwift
import FirebaseFirestore  // Add Firebase

// This screen shows the admin a list of all stores and lets them manage stores
class AdminHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, StoreXibTableViewDelegate {
    
    // Create connection to Firebase database
    private let db = Firestore.firestore()
    
    // When the reload button is pressed, refresh the store list
    @IBAction func reloadButtonPressed(_ sender: Any) {
        fetchStores()
    }
    
    // Connect to our table view that shows the list of stores
    @IBOutlet weak var storesListTableView: UITableView!
    
    // Keep track of our list of stores
    private var storesList: [UserModel] = []
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the table view
        storesListTableView.delegate = self
        storesListTableView.dataSource = self
        storesListTableView.rowHeight = 160
        
        // Register our custom cell design
        storesListTableView.register(UINib(nibName: "StoresListXibTableView", bundle: nil),
                                   forCellReuseIdentifier: "StoresListXibTableView")
        
        // Get the initial list of stores
        fetchStores()
    }
    
    // Fetch stores from both Realm and Firebase
    private func fetchStores() {
        // Clear existing list
        storesList.removeAll()
        
        // Fetch from Firebase
        db.collection("store").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching stores: \(error)")
                self.showAlert(message: "Error fetching stores from cloud")
                return
            }
            
            // Get stores from Firebase
            if let documents = snapshot?.documents {
                do {
                    // First, clear existing stores in Realm
                    try self.realm.write {
                        let existingStores = self.realm.objects(UserModel.self).filter("role == 'store'")
                        self.realm.delete(existingStores)
                    }
                    
                    // Add each store from Firebase to Realm
                    for document in documents {
                        let data = document.data()
                        
                        // Create new UserModel
                        let store = UserModel()
                        store.email = data["email"] as? String ?? ""
                        store.name = data["name"] as? String ?? ""
                        store.phoneNumber = data["phoneNumber"] as? String ?? ""
                        store.role = "store"
                        
                        // Save to Realm
                        try self.realm.write {
                            self.realm.add(store, update: .modified)
                        }
                    }
                    
                    // Update our list with all stores from Realm
                    let stores = self.realm.objects(UserModel.self).filter("role == 'store'")
                    self.storesList = Array(stores)
                    
                    // Refresh the display
                    DispatchQueue.main.async {
                        self.storesListTableView.reloadData()
                    }
                } catch {
                    print("Error updating local database: \(error)")
                    self.showAlert(message: "Error updating local store data")
                }
            }
        }
    }
    
    // Delete a store
    func deleteStore(cell: StoresListXibTableView) {
        guard let indexPath = self.storesListTableView.indexPath(for: cell) else { return }
        let storeToDelete = self.storesList[indexPath.row]
        
        showConfirmationAlert(
            title: "Delete Store",
            message: "Are you sure you want to delete this store?",
            confirmTitle: "Yes"
        ) {
            // Delete from Firebase first
            self.db.collection("store").document(storeToDelete.email).delete { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error deleting from Firebase: \(error)")
                    self.showAlert(message: "Error deleting store from cloud")
                    return
                }
                
                // If Firebase delete successful, delete from Realm
                do {
                    try self.realm.write {
                        self.realm.delete(storeToDelete)
                    }
                    // Remove from local list and update table view
                    self.storesList.remove(at: indexPath.row)
                    self.storesListTableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    print("Error deleting from Realm: \(error)")
                    self.showAlert(message: "Error deleting store locally")
                }
            }
        }
    }
    
    // Show store details when clicked
    func showStoreDetails(cell: StoresListXibTableView) {
        guard let indexPath = storesListTableView.indexPath(for: cell) else { return }
        let selectedStore = storesList[indexPath.row]
        
        let adminStoreDetailsVC: AdminStoreDetailsVC = AdminStoreDetailsVC.instantiate(appStoryboard: .admin)
        adminStoreDetailsVC.storeDetails = selectedStore // Pass the selected store details
        navigationController?.pushViewController(adminStoreDetailsVC, animated: true)
    }
}

// Handle table view setup
extension AdminHomeVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoresListXibTableView", for: indexPath) as! StoresListXibTableView
        cell.configureWithStoreData(userModel: storesList[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
}

// Handle table view selection
extension AdminHomeVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Currently empty, but could be used for additional selection handling
    }
}

// Helper functions
extension AdminHomeVC {
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
