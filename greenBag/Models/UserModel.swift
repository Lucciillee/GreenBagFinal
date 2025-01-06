

import Foundation
import RealmSwift

class UserModel: Object {
    static var loggedInUserInfo: (email: String, name: String) = ("", "")
    
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var email: String = ""
    @Persisted var password: String = ""
    @Persisted var name: String = ""
    @Persisted var phoneNumber: String = ""
    @Persisted var role: String = ""
    @Persisted var orderHistoryCarts: List<CartItemRealm> = List<CartItemRealm>()
}

