import Foundation
import RealmSwift

class LoggedInUserManager {
    private let realm = try! Realm()

    /// Singleton instance for centralized access
    static let shared = LoggedInUserManager()

    private init() {}

    /// Creates or overwrites the logged-in user
    func createLoggedInUser(email: String) {
        try? realm.write {
            // Delete the existing logged-in user, if any
            if let existingUser = realm.objects(LoggedInUserRealm.self).first {
                realm.delete(existingUser)
            }
            
            // Create a new logged-in user
            let loggedInUser = LoggedInUserRealm()
            loggedInUser.email = email
            realm.add(loggedInUser)
        }
    }

    /// Logs out the currently logged-in user
    func logoutUser() {
        try? realm.write {
            if let loggedInUser = realm.objects(LoggedInUserRealm.self).first {
                realm.delete(loggedInUser)
            }
        }
    }

    /// Adds an item to the logged-in user's cart
    func addItemToCart(productName: String, totalPrice: String, quantity: Int, productCategory: String) {
        guard let loggedInUser = realm.objects(LoggedInUserRealm.self).first else {
            print("No logged-in user found.")
            return
        }

        let cartItem = CartItemRealm()
        cartItem.productName = productName
        cartItem.totalPrice = totalPrice
        cartItem.quantity = quantity
        cartItem.productCategory = productCategory

        try? realm.write {
            loggedInUser.carts.append(cartItem)
        }
    }

    /// Fetches the current logged-in user
    func getLoggedInUser() -> LoggedInUserRealm? {
        return realm.objects(LoggedInUserRealm.self).first
    }
    
    func getUserCarts() -> [CartItemRealm] {
        guard let loggedInUser = realm.objects(LoggedInUserRealm.self).first else {
            print("No logged-in user found.")
            return []
        }
        return Array(loggedInUser.carts)
    }
    
    func removeItemFromCart(productName: String) {
        guard let loggedInUser = realm.objects(LoggedInUserRealm.self).first else {
            print("No logged-in user found.")
            return
        }
        
        if let cartItem = loggedInUser.carts.first(where: { $0.productName == productName }) {
            try? realm.write {
                realm.delete(cartItem)
            }
        } else {
            print("Product not found in cart.")
        }
    }
    
    func emptyAllCarts() {
        guard let loggedInUser = realm.objects(LoggedInUserRealm.self).first else {
            print("No logged-in user found.")
            return
        }
        
        try? realm.write {
            loggedInUser.carts.removeAll()
        }
        
        print("All items removed from the cart list.")
    }

    
}


