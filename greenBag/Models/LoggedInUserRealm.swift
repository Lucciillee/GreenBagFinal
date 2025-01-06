import Foundation
import RealmSwift

class LoggedInUserRealm: Object {
    @Persisted(primaryKey: true) var email: String = ""
    @Persisted var carts: List<CartItemRealm> = List<CartItemRealm>() // A list of cart items
}
