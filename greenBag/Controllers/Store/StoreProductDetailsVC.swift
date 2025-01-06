
import UIKit
import RealmSwift
import Firebase

class StoreProductDetailsVC: UIViewController {
   
   // MARK: - Properties
   var productDetails: ProductModelRealm?
   private let realm = try! Realm()
   private let db = Firestore.firestore()
   
   // MARK: - Outlets
   @IBOutlet weak var productNameTextField: BlackBorderedTextField!
   @IBOutlet weak var productCategoryTextField: BlackBorderedTextField!
   @IBOutlet weak var productPriceTextField: BlackBorderedTextField!
   @IBOutlet weak var productQuantityTextField: BlackBorderedTextField!
   
   // MARK: - Lifecycle
   override func viewDidLoad() {
       super.viewDidLoad()
       setupFields()
   }
   
   // MARK: - Setup
   private func setupFields() {
       productNameTextField.text = productDetails?.name
       productCategoryTextField.text = productDetails?.category
       productPriceTextField.text = productDetails?.price
       productQuantityTextField.text = productDetails?.quantity
   }
   
   // MARK: - Actions
   @IBAction func backButtonPressed(_ sender: Any) {
       navigationController?.popViewController(animated: true)
   }
   
   @IBAction func updateProductButtonPressed(_ sender: Any) {
       guard let product = productDetails else { return }
       
       // Get new values
       let newName = productNameTextField.text ?? ""
       let newCategory = productCategoryTextField.text ?? ""
       let newPrice = productPriceTextField.text ?? ""
       let newQuantity = productQuantityTextField.text ?? ""
       
       // Check if values changed
       if newName == product.name &&
           newCategory == product.category &&
           newPrice == product.price &&
           newQuantity == product.quantity {
           showAlert(message: "No changes detected.")
           return
       }
       
       // Update in both Realm and Firebase
       do {
           // Update Realm
           try realm.write {
               product.name = newName
               product.category = newCategory
               product.price = newPrice
               product.quantity = newQuantity
           }
   //----------------------------------
           // Update Firebase
           let documentId = product.id.stringValue
           db.collection("product").document(documentId).updateData([
               "name": newName,
               "category": newCategory,
               "price": newPrice,
               "quantity": newQuantity
           ]) { [weak self] error in
               guard let self = self else { return }
               
               if let error = error {
                   // If Firebase update fails, show error
                   self.showAlert(message: "Failed to update product: \(error.localizedDescription)")
                   return
               }
               
               // Show success and pop view controller
               self.showAlert(title: "Success",
                            message: "Product updated successfully!") { [weak self] in
                   self?.navigationController?.popViewController(animated: true)
               }
           }
           
       } catch {
           // If Realm update fails
           showAlert(message: "Failed to update product. Please try again.")
       }
   }
   
   // MARK: - Helper Methods
   private func showAlert(title: String = "Alert",
                        message: String,
                        completion: (() -> Void)? = nil) {
       let alert = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
       
       alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
           completion?()
       })
       
       present(alert, animated: true)
   }
}
