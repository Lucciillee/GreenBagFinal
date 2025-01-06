import Foundation
import RealmSwift

class CartItemRealm: Object {
    @Persisted var productName: String = ""
    @Persisted var totalPrice: String = "" // Storing as String for consistency with other fields
    @Persisted var quantity: Int = 0
    @Persisted var productCategory: String = ""
}
